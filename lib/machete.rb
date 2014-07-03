require 'machete/logger'
require 'machete/app_controller'
require 'machete/app'
require 'machete/fixture'
require 'machete/buildpack_uploader'
require 'machete/buildpack_mode'
require 'machete/firewall'
require 'machete/cf'
require 'machete/host'
require 'machete/vendor_dependencies'
require 'machete/database_url_builder'

module Machete
  class << self
    def deploy_app(path, options={})
      app = App.new(path, host, options)
      app_controller.deploy(app)
      app
    end

    def logger
      @logger ||= Machete::Logger.new(STDOUT)
    end

    def logger=(new_logger)
      @logger = new_logger
    end

    private

    def app_controller
      Machete::AppController.new
    end

    def host
      Host.new
    end
  end
end
