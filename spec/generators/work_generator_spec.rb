require 'spec_helper'
require 'rails_helper'

require 'generators/bibliocat/work/work_generator'

describe Bibliocat::WorkGenerator, :type => :generator do
  destination File.expand_path("../../../tmp/test", __FILE__)
  before do
    prepare_destination
    FileUtils.mkdir_p file('config/initializers')
    FileUtils.copy_file(Rails.root + 'config/initializers/worthwhile_config.rb', 
      file('config/initializers/worthwhile_config.rb'))
  end
  
    describe 'generated files' do
      before do
        run_generator %w(NewType)
      end
      describe 'has a model' do
        subject { file('app/repository_models/new_type.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has a controller' do
        subject { file('app/repository_models/new_type.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has an actor' do
        subject { file('app/repository_models/new_type.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has views' do
        subject { file('app/repository_models/new_type.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has specs' do
        subject { file('app/repository_models/new_type.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has metadata configuration' do
        subject { file('app/repository_models/new_type.rb') }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'is a registered concern'
      describe 'has metadata methods matching the configuration'
    end
end
