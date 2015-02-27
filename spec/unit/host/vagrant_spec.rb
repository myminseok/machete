require 'spec_helper'

module Machete
  describe Host::Vagrant do

    subject(:host) { Host::Vagrant.new(vagrant_cwd) }

    context 'when VAGRANT_CWD is set' do
      let(:vagrant_cwd) { '/tmp' }

      before do
        allow(Bundler).
          to receive(:with_clean_env).
               and_yield

        allow(host).
          to receive(:`).
               with('vagrant ssh -c \'command\' 2>&1').
               and_return 'hello there'
      end

      specify do
        expect(host.run('command')).to eql 'hello there'
      end
    end

    context 'when VAGRANT_CWD is not set' do
      let(:vagrant_cwd) { nil }

      specify do
        expect do
          host.run('command')
        end.to raise_error(Host::VagrantCWDMissingError)
      end
    end
  end
end
