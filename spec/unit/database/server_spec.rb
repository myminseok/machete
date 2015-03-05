require 'spec_helper'

module Machete
  class Database
    describe Server do
      subject(:server) { Server.new }

      describe '#host' do
        context 'when bosh includes the vm postgres_zl' do
          it 'returns the IP address for the VM' do
            expect(server).to receive(:`).with('bosh vms').and_return(<<-BOSH_OUTPUT)
| nfs_z1/0                           | running | small_z1      | 10.0.16.105    |
| postgres_z1/0                      | running | small_z1      | 10.0.16.101    |
            BOSH_OUTPUT

            expect(server.host).to eq '10.0.16.101'
          end
        end
      end

      describe '#port' do
        it { expect(server.port).to eq 5524 }
      end

      describe '#type' do
        it { expect(server.type).to eq 'postgres' }
      end
    end
  end
end
