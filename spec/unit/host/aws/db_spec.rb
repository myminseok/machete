require 'spec_helper'

module Machete::Host
  describe Aws::DB do
    let(:host) { double(:host) }
    subject(:host_db) { Aws::DB.new(host) }

    describe '#run' do
      it 'gets results from psql' do
        expect(host).to receive(:run)
          .with('export PATH=/var/vcap/packages/postgres/bin:$PATH; psql my_command', :postgres_z1)
          .and_return('psql output')

        expect(host_db.run('psql my_command')).to eq 'psql output'
      end
    end
  end
end

