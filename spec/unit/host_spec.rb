require 'spec_helper'

describe Machete::Host do
  describe 'Creating the correct host for the environment' do
    context 'VAGRANT_CWD is set' do

      specify 'it uses the Vagrant host' do

      end
    end

    context 'VAGRANT_CWD is not set' do
      specify 'it uses the Bosh host' do

      end

    end
  end
end
