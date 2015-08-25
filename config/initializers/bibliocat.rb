# Be sure to restart your server when you modify this file.
require 'yaml'

work_type_config = Rails.root.join("config", 'work_types', "bibliowork.yml").to_s
Settings.add_source!(work_type_config)
Settings.reload!

listener = Listen.to(Rails.root.join("config", 'work_types')) do |modified, added, removed|
    puts "Added #{added}"
  unless added[0].nil? 
    Settings.add_source!(added[0])
    puts "Added #{added}"
  end
  Settings.reload!
end
listener.start


