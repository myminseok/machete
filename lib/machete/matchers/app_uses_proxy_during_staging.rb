# encoding: utf-8
require 'rspec/matchers'
require 'erb'
require 'yaml'
require 'socket'

RSpec::Matchers.define :use_proxy_during_staging do
  dockerfile = <<-DOCKERFILE
FROM cloudfoundry/cflinuxfs2

ENV CF_STACK cflinuxfs2
<%= docker_env_vars %>

ADD <%= fixture_path %> /tmp/staged/
ADD ./<%= cached_buildpack_path %> /tmp/

RUN mkdir -p /buildpack
RUN mkdir -p /tmp/cache

RUN unzip /tmp/<%= cached_buildpack_path %> -d /buildpack
RUN (sudo tcpdump -n -i eth0 not udp port 53 and ip -c 1 -t | sed -e 's/^[^$]/internet traffic: /' 2>&1 &) && /buildpack/bin/detect /tmp/staged && /buildpack/bin/compile /tmp/staged /tmp/cache && /buildpack/bin/release /tmp/staged /tmp/cache
  DOCKERFILE

  match do |app|
    begin
      cached_buildpack_path = Dir['*_buildpack-v*.zip'].fetch(0)
      fixture_path = "./#{app.src_directory}"

      dockerfile_path = "Dockerfile.#{$PROCESS_ID}.#{Time.now.to_i}"
      docker_image_name = 'proxy_staging_test'

      manifest_search = Dir.glob("#{fixture_path}/**/manifest.yml")
      manifest_location = ''
      manifest_hash = {}
      unless manifest_search.empty?
        manifest_location = File.expand_path(manifest_search[0])
        manifest_hash = YAML.load_file(manifest_location)
      end
      docker_env_vars = ''
      if manifest_hash.key?('env')
        manifest_hash['env'].each do |key, value|
          docker_env_vars << "ENV #{key} #{value}\n"
        end
      end

      # setting proxy env vars
      proxy_ip = Socket.ip_address_list.last.ip_address
      proxy_port = '8080'
      docker_env_vars << "ENV http_proxy http://#{proxy_ip}:#{proxy_port}\n"
      docker_env_vars << "ENV https_proxy https://#{proxy_ip}:#{proxy_port}\n"

      # boot up proxy in background
      web_proxy_io = IO.popen("ruby -rwebrick -rwebrick/httpproxy -e \"proxy = WEBrick::HTTPProxyServer.new Port: #{proxy_port};trap 'TERM' do proxy.shutdown end;proxy.start\"")

      dockerfile_contents = ERB.new(dockerfile).result binding
      File.write(dockerfile_path, dockerfile_contents)

      docker_exitstatus = 0

      docker_output = Dir.chdir(File.dirname(dockerfile_path)) do
        output = `docker build --rm --no-cache -t #{docker_image_name} -f #{dockerfile_path} .`
        docker_exitstatus = $CHILD_STATUS.exitstatus.to_i
        output
      end

      unless docker_exitstatus == 0
        puts '=========================================='
        puts "docker_output: #{docker_output}"
        puts '=========================================='
      end

      @traffic_lines = docker_output.split("\n").grep(/^(\e\[\d+m)?internet traffic:/)
    ensure
      unless `docker images | grep #{docker_image_name}`.strip.empty?
        `docker rmi -f #{docker_image_name}`
      end
      FileUtils.rm(dockerfile_path)
      Process.kill("TERM", web_proxy_io.pid)
    end

    fail "docker didn't successfully build" unless docker_exitstatus == 0

    #check all traffic lines hit proxy
    return @traffic_lines.all? do |traffic_line|
      /internet traffic: P ([\d+\.]+) > ([\d+\.]+)\.(\d+)/.match(traffic_line)
      source_ip_port = $1
      destination_ip = $2
      destination_port = $3
      #ignore screening of traffic that comes from proxy
      if source_ip_port == "#{proxy_ip}.#{proxy_port}"
        true
      else
        destination_ip == proxy_ip && destination_port == proxy_port
      end
    end
  end

  failure_message do
    "Proxy was not used for internet traffic during staging\n\n" +
      @traffic_lines.join("\n")
  end

  failure_message_when_negated do
    "\nProxy used during staging:\n\n" +
      @traffic_lines.join("\n")
  end
end
