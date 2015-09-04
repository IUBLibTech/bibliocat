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

class Bibliocat::ConfigureGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def activate_schema
    begin
      # Get work_type object in Fedora; grab first result since this search returns an array
      work_type = WorkType.find(registered_name: class_name)[0] 
      schema_file = work_type.schema_datastream
      puts "Updating the schema file in config/work_types/#{file_name}.yml from Work Type in Fedora"
      File.open(Rails.root + "config/work_types/#{file_name}.yml", "w+b") {|f| f.write(schema_file.read)}
    rescue
      puts "Unable to write new config to config/work_types/#{file_name}.yml"
    end
  end


end
