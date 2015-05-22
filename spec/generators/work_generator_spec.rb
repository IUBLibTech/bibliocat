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
      let (:files) { 
        {controller:'app/controllers/curation_concern/new_types_controller.rb',
         view: 'app/views/curation_concern/new_types/_new_type.html.erb',
         actor: 'app/actors/curation_concern/new_type_actor.rb',
         model: 'app/repository_models/new_type.rb',
         locale: 'config/locales/new_type.en.yml',
         controller_spec: 'spec/controllers/curation_concern/new_types_controller_spec.rb',
         actor_spec: 'spec/actors/curation_concern/new_type_actor_spec.rb',
         spec: 'spec/repository_models/new_type_spec.rb' }
      }

      before do
        run_generator %w(NewType)
      end

      describe 'has a model' do
        subject { file(files[:model]) }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has a controller' do
        subject { file(files[:controller]) }
        it { is_expected.to exist }
        it { is_expected.to contain /NewTypesController/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has an actor' do
        subject { file(files[:actor]) }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewTypeActor/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has views' do
        subject { file(files[:view]) }
        it { is_expected.to exist }
        #it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has specs' do
        subject { file(files[:spec]) }
        it { is_expected.to exist }
        #it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has metadata configuration' do
        subject { file(files[:locale]) }
        it { is_expected.to exist }
        #it { is_expected.to contain /class NewType/ }
        it 'is_expected.to have_correct_syntax'
      end
      describe 'is a registered concern'
      describe 'has metadata methods matching the configuration'
    end
end
