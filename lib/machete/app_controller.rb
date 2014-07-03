require 'httparty'
require 'machete/system_helper'
require 'machete/cf/delete_app'

module Machete
  class AppController

    def deploy(app)
      clear_internet_access_log(app)
      delete_app.execute(app)

      vendor_dependencies.execute(app)

      if app.environment_variables?
        push_app.execute(app, start: false)
        set_app_environment_variables.execute(app)
      end

      push_app.execute(app)
    end

    private

    def delete_app
      CF::DeleteApp.new
    end

    def push_app
      CF::PushApp.new
    end

    def set_app_environment_variables
      CF::SetAppEnv.new
    end

    def clear_internet_access_log(app)
      Host::Log.new(app.host).clear
    end

    def vendor_dependencies
      VendorDependencies.new
    end
  end
end

__END__


    def database_url(database_name)
      "postgres://buildpacks:buildpacks@#{postgres_ip}:5524/#{database_name}"
    end

    def postgres_ip
      ha_proxy_ip.gsub(/\d+\z/, '30')
    end

    def ha_proxy_ip
      @ha_proxy ||= SystemHelper.run_cmd('cf api').scan(/api\.(\
      +\.\d+\.\d+\.\d+)\.xip\.io/).flatten.first
    end
