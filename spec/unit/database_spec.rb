require 'spec_helper'

module Machete
  describe Database do
    let(:name) { 'name' }
    let(:host) { 'example.com' }
    let(:port) { 'port' }
    let(:type) { 'postgres' }
    let(:server) { double(:server, host: host, port: port, type: type) }

    let(:password) { Database::Settings.superuser_password }
    let(:username) { Database::Settings.superuser_name }

    let(:app) { double(:app, create_db_manager: db_manager) }
    let(:db_manager) { double(:db_manager) }

    subject(:database) { Database.new(database_name: name, server: server, app: app) }

    describe '#clear' do
      specify do
        expect(db_manager).
          to receive(:run).
               with("PGPASSWORD=#{password} psql -U #{username} -h #{host} -p #{port} -d postgres -c \"DROP DATABASE IF EXISTS #{name}\"")
        database.clear
      end
    end

    describe '#create' do
      let(:owner) { Database::Settings.user_name }

      specify do
        expect(db_manager).
          to receive(:run).
               with("PGPASSWORD=#{password} psql -U #{username} -h #{host} -p #{port} -d postgres -c \"CREATE DATABASE #{name} WITH OWNER #{owner}\"")
        database.create
      end
    end
  end
end
