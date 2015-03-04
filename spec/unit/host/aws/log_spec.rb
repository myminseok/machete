require 'spec_helper'

module Machete::Host
  describe Aws::Log do
    let(:host) { double(:host) }
    subject(:host_log) { Aws::Log.new(host) }

    describe '#contents' do
      before do
        allow(host).to receive(:run).with("echo -e 'p\n' | sudo -S cat /var/log/messages").and_return('some logging')
      end

      specify do
        expect(host_log.contents).to eql 'some logging'
      end
    end

    describe '#clear' do
      before do
        allow(host).to receive(:run)
      end

      specify do
        host_log.clear
        expect(host).to have_received(:run).with("echo -e 'p\n' | sudo -S rm /var/log/messages")
        expect(host).to have_received(:run).with("echo -e 'p\n' | sudo -S restart rsyslog")
      end
    end
  end
end
