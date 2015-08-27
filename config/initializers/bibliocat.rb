# Be sure to restart your server when you modify this file.
require 'yaml'

# This initializer sets up a watched directory to monitor for changes/additions to work type YAML files.
# It relies on the config gem to parse configuration files and make hashes available via Settings object,
# and it relies on the listen gem to watch a directory for changes.

# Inspect config/work_types directory to get initial list of current files to add to work type settings 
Dir.glob('config/work_types/**/*').reject do |work_type_config|
  puts "Adding #{work_type_config.to_s} to work type settings"
  Settings.add_source!(Rails.root.join(work_type_config).to_s)
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


