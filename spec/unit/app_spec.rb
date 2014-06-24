require 'spec_helper'

module Machete
  describe App do
    let(:host) { double(:host) }
    subject(:app) { App.new('path/to/example_app', host) }

    before do
      allow(SystemHelper).to receive(:run_cmd)
    end

    describe '#push' do
      context 'starting the app immediately' do
        before do
          app.push
        end

        specify do
          expect(SystemHelper).to have_received(:run_cmd).with('cf push example_app')
        end
      end

      context 'not starting the app immediately' do
        before do
          app.push(start: false)
        end

        specify do
          expect(SystemHelper).to have_received(:run_cmd).with('cf push example_app --no-start')
        end
      end
    end

    describe '#delete' do
      before do
        app.delete
      end

      specify do
        expect(SystemHelper).to have_received(:run_cmd).with('cf delete -f example_app')
      end
    end

    describe '#homepage_body' do
      let(:website) { double(body: 'kyles homepage body') }

      before do
        allow(SystemHelper).to receive(:run_cmd).with('cf app example_app | grep url').and_return('urls: www.kylesurl.com')
        allow(HTTParty).to receive(:get).with('http://www.kylesurl.com').and_return website
      end

      specify do
        expect(app.homepage_body).to eql 'kyles homepage body'
      end
    end

    describe '#file' do
      before do
        allow(SystemHelper).to receive(:run_cmd).with('cf files example_app log/a_log_file.log').and_return('output from file')
      end

      specify do
        expect(app.file('log/a_log_file.log')).to eql 'output from file'
      end
    end

    describe '#has_file' do
      context 'the file exists' do
        let(:app_has_file) { app.has_file?('log/a_log_file.log') }
        let(:status) { double(:status, exitstatus: 0) }

        before do
          allow(Process::Status).to receive(:new).and_return status
          $?.existatus = Process::Status.new
        end

        specify do
          expect(app_has_file).to be_truthy
        end

        specify do
          app_has_file
          expect(SystemHelper).to have_received(:run_cmd).with('cf files example_app log/a_log_file.log')
        end
      end

      context 'the file does not exist' do
        let(:app_has_file) { app.has_file?('log/a_log_file.log') }

        before do
          allow($?).to receive(:exitstatus).and_return(1)
        end

        specify do
          expect(app_has_file).to be_falsey
        end

        specify do
          app_has_file
          expect(SystemHelper).to have_received(:run_cmd).with('cf files example_app log/a_log_file.log')
        end
      end
    end

    describe '#set_env' do
      before do
        app.set_env('env_var', 'env_val')
      end

      specify do
        expect(SystemHelper).to have_received(:run_cmd).with('cf set-env example_app env_var env_val')
      end
    end
  end
end