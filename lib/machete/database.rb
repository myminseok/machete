require 'machete/database/server'
require 'machete/database/url_builder'
require 'machete/database/settings'

module Machete
  class Database
    def initialize(database_name:, server:, app:)
      @database_name = database_name
      @server = server
      @app = app
    end

    def clear
      @app.create_db_manager.run psql(drop_database_command)
    end

    def create
      @app.create_db_manager.run psql(create_database_command)
    end

    private

    def database_name
      @database_name
    end

    def server
      @server
    end

    def drop_database_command
      "DROP DATABASE IF EXISTS #{database_name}"
    end

    def create_database_command
      "CREATE DATABASE #{database_name} WITH OWNER #{Settings.user_name}"
    end

    def psql(sql)
      command = "PGPASSWORD=#{Settings.superuser_password} psql"
      command += " -U #{Settings.superuser_name}"
      command += " -h #{host}"
      command += " -p #{port}"
      command += " -d #{connecting_database}"
      command + " -c \"#{sql}\""
    end

    def host
      server.host
    end

    def port
      server.port
    end

    def connecting_database
      server.type
    end
  end
end
