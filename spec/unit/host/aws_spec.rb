require 'spec_helper'

module Machete
  describe Host::Aws do

    subject(:host) { Host::Aws.new }

    describe '#run' do
      let(:command) { 'echo "hello there"' }

      before do
        allow(Bundler).
          to receive(:with_clean_env).
               and_yield

        allow(host).
          to receive(:`).
               with("bosh ssh runner_z1 --gateway_user vcap --gateway_host microbosh.my.host --default_password p 'echo \"---COMMAND START---\"; #{command}; echo \"---COMMAND STOP---\"' 2>&1").
               and_return <<BOSH_RESULT
This is bosh output
More Bosh output
---COMMAND START---
hello there
---COMMAND STOP---
Last Bosh output
BOSH_RESULT
      end

      context "without a BOSH_TARGET" do
        before do
          allow(ENV).
            to receive(:[]).
                 with('BOSH_TARGET').
                 and_return(nil)
        end

        specify do
          expect{ host.run(command) }.to raise_error("BOSH_TARGET must be set")
        end

      end

      context "with a BOSH_TARGET" do
        before do
          allow(ENV).
            to receive(:[]).
                 with('BOSH_TARGET').
                 and_return('microbosh.my.host')
        end

        specify do
          expect(host.run(command)).to eql "hello there\n"
        end
      end

    end

  end
end
