require 'spec_helper'

module Machete::Host
  describe Vagrant::DB do
    let(:host) { double(:host) }
    subject(:host_db) { Vagrant::DB.new(host) }

    describe '#run' do
      it 'gets results from psql' do
        expect(Machete::SystemHelper).to receive(:run_cmd)
          .with('psql my_command')
          .and_return('psql output')

        expect(host_db.run('psql my_command')).to eq 'psql output'
      end
    end
  end
end

