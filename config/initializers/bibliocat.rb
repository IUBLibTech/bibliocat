# Be sure to restart your server when you modify this file.
require 'yaml'

# This initializer sets up a watched directory to monitor for changes/additions to work type YAML files.
# It relies on the config gem to parse configuration files and make hashes available via Settings object,
# and it relies on the listen gem to watch a directory for changes.

work_type_path = Rails.root.join("config", 'work_types')
raise "bibliowork.yml is required" unless (work_type_path + "bibliowork.yml").exist?
work_type_path.each_child do |c|
  Settings.add_source!(c.to_s)
end
Settings.reload!
puts "Available work types with configuration #{Settings.work_types.keys.inspect}"

# Start a listener to watch the work_types dir for modified, added, or removed files
listener = Listen.to(Rails.root.join("config", 'work_types')) do |modified, added, removed|
  modified.each do |m|
    puts "Modified #{m}"
  end
  added.each do |a|
    unless a.nil? 
      Settings.add_source!(a)
      puts "Added #{a}"
    end
  end
  removed.each do |r|
    puts "Removed #{r}"
  end
  Settings.reload!
  puts "Available work types with configuration #{Settings.work_types.keys.inspect}"
end
listener.start


