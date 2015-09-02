# -*- encoding : utf-8 -*-
require 'rails/generators'

class Rails::Generators::NamedBase
  private
  def destroy(what, *args)
    log :destroy, what
    argument = args.map {|arg| arg.to_s }.flatten.join(" ")

    in_root {
      run_ruby_script("bin/rails destroy #{what} #{argument}", verbose: true)
    }
  end
end

class Bibliocat::WorkGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)


  argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

  def create_model_spec
    return unless rspec_installed?
    template "model_spec.rb.erb", "spec/repository_models/#{file_name}_spec.rb"
  end

  def create_model
    template("model.rb.erb", "app/repository_models/#{file_name}.rb")
  end

  def configure_work_type
    template("work_type.yml.erb", "config/work_types/#{file_name}.yml")
  end

  def create_controller_spec
    return unless rspec_installed?
    template("controller_spec.rb.erb", "spec/controllers/curation_concern/#{plural_file_name}_controller_spec.rb")
  end

  def create_actor_spec
    return unless rspec_installed?
    template("actor_spec.rb.erb", "spec/actors/curation_concern/#{file_name}_actor_spec.rb")
  end

  def create_controller
    template("controller.rb.erb", "app/controllers/curation_concern/#{plural_file_name}_controller.rb")
  end

  def create_metadata
    template("metadata.rb.erb", "app/repository_models/datastreams/#{file_name}_metadata.rb")
  end

  def create_actor
    template("actor.rb.erb", "app/actors/curation_concern/#{file_name}_actor.rb")
  end

  def register_work
    inject_into_file 'config/initializers/worthwhile_config.rb', after: "Worthwhile.configure do |config|\n" do
      data = ""
      data << "  # Injected via `rails g bibliocat:work #{class_name}`\n"
      data << "  config.register_curation_concern :#{file_name}\n"
      data
    end
  end

  def create_views
    create_file "app/views/curation_concern/#{plural_file_name}/_#{file_name}.html.erb" do
      data = "<%# This is a search result view %>\n"
      data << "<%= render 'catalog/document', document: #{file_name}, document_counter: #{file_name}_counter  %>\n"
      data
    end
  end

  def create_readme
    readme 'README'
  end

  def to_fedora
    # TODO paramatize is_type_of
    is_type_of = 'BiblioWork'
    work_type = WorkType.new(registered_name: class_name, display_name: class_name.titleize, is_type_of: is_type_of)
    begin
      work_type.schema_file = File.open(Rails.root + "config/work_types/#{file_name}.yml")
    rescue
      puts "No schema found in config/work_types/#{file_name}.yml"
      work_type.schema_file = File.open(Rails.root + "config/work_types/bibliowork.yml")
    end
    if work_type.save
      print "\"#{class_name}\" WorkType saved to Fedora."
    else
      puts "ABORTING: problem saving WorkType"
      puts work_type.errors.messages
    end
  end

  private

    def rspec_installed?
      defined?(RSpec) && defined?(RSpec::Rails)
    end

end
