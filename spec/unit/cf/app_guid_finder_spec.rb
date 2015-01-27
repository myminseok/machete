require 'spec_helper'

module Machete
  module CF
    describe AppGuidFinder do
      context "with immediate result" do
        let(:app) { double(:app, name: 'app_name') }
        let(:app_guid) { 'app_guid'}

        subject(:app_guid_finder) { AppGuidFinder.new }

        before do
          allow(SystemHelper).
            to receive(:run_cmd).
                 with('cf curl /v2/apps?q=\'name:'+ app.name + '\'', true).
                 and_return('{
                    "total_results": 1,
                    "resources": [
                        {
                            "metadata": {
                                "guid": "' + app_guid + '"
                            }
                        }
                    ]
                }')
        end

        specify do
          expect(app_guid_finder.execute(app)).to eql app_guid
        end
      end

      context "when the first response does not have the app GUID" do
        let(:app) { double(:app, name: 'app_name') }

        subject(:app_guid_finder) { AppGuidFinder.new }


        context "and the next retry request returns the app GUID" do
          specify do
            expect(SystemHelper).to receive(:run_cmd).and_return('{}', {
              resources: [{metadata: {guid: "my-awesome-guid"}}]
            }.to_json)
            expect(app_guid_finder.execute(app)).to eql "my-awesome-guid"
          end
        end

        context "after the third retry request" do
          it "retries the request 3 times until" do
            expect(SystemHelper).to receive(:run_cmd).exactly(3).times.and_return('{}')
            app_guid_finder.execute(app) rescue nil
          end

          it "returns an error" do
            expect {
              app_guid_finder.execute(app)
            }.to raise_error(Exception)
          end
        end
      end
    end
  end
end
