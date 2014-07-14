require 'spec_helper'

module Machete
  module CF
    describe Instances do
      let(:app_guid_finder) { double(:app_guid_finder) }
      let(:app) { double(:app) }
      let(:app_guid) { double(:app_guid) }
      let(:instances_json) { double(:instances_json) }

      subject(:instances_command) { Instances.new }


      before do
        allow(CF::AppGuidFinder).
          to receive(:new).
               and_return(app_guid_finder)

        allow(app_guid_finder).
          to receive(:execute).
               with(app).
               and_return(app_guid)

        allow(SystemHelper).
          to receive(:run_cmd).
               with("cf curl /v2/apps/#{app_guid}/instances").
               and_return(instances_json)
      end

      specify do
        instances = instances_command.execute(app)
        expect(instances.size).to eql 1
        expect(instances.first.status).to eql 'RUNNING'
      end
    end
  end
end
