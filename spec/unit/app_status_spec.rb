require 'spec_helper'

module Machete
  describe AppStatus do
    describe '#status' do
      let(:app) { double(:app) }
      let(:instances) { double(:instances) }
      let(:instance) { double(:instance, state: instance_state) }
      let(:error) { double(:error) }

      subject(:app_status) { AppStatus.new }
      before do
        allow(CF::Instances).
          to receive(:new).
               with(app).
               and_return(instances)

        allow(instances).
          to receive(:execute).
               and_return([instance])

        allow(instances).
          to receive(:error).
               and_return(error)
      end

      context 'app has starting instances' do
        let(:instance_state) { 'STARTING' }

        specify do
          expect(app_status.execute(app)).to eql AppStatus::UNKNOWN
        end
      end

      context 'app has staging failures' do
        let(:error) { 'CF-BuildpackCompileFailed' }
        let(:instance_state) { '' }

        specify do
          expect(app_status.execute(app)).to eql AppStatus::STAGING_FAILED
        end
      end

      context 'app has running instances' do
        let(:instance_state) { 'RUNNING' }

        specify do
          expect(app_status.execute(app)).to eql AppStatus::RUNNING
        end
      end
    end
  end
end
