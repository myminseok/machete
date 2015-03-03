require 'spec_helper'
require 'machete/matchers'

module Machete
  describe '#has_internet_traffic' do
    let(:app)  { double(:app, host: host) }
    let(:host) { double(:host) }
    let(:log_manager) { double(:log_manager) }

    before do

      allow(host).
        to receive(:create_log_manager).
        and_return(log_manager)

      allow(log_manager).
        to receive(:contents).
        and_return(log_contents)
    end

    context 'there is internet traffic ' do
      let(:log_contents) { 'cf-to-internet-traffic' }

      specify do
        expect(app.host).to have_internet_traffic
      end
    end

    context 'there is not internet traffic' do
      let(:log_contents) { '' }

      specify do
        expect(app.host).not_to have_internet_traffic
      end
    end
  end
end
