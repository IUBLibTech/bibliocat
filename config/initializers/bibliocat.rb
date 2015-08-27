# Be sure to restart your server when you modify this file.
require 'yaml'


work_type_path = Rails.root.join("config", 'work_types')
raise "bibliowork.yml is required" unless (work_type_path + "bibliowork.yml").exist?
work_type_path.each_child do |c|
  Settings.add_source!(c.to_s)
end
Settings.reload!
puts "Available work types with configuration #{Settings.work_types.keys.inspect}"

listener = Listen.to(work_type_path) do |modified, added, removed|
    puts "Added #{added}"
  unless added[0].nil? 
    Settings.add_source!(added[0])
    puts "Added #{added}"
  end
  Settings.reload!
  puts "Available work types with configuration #{Settings.work_types.keys.inspect}"
end
listener.start


