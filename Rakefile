# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# The default version for jettywrapper is no longer 7 with Fedora 3, so we have to set it for
#  Worthwhile or we would get Fedora 4
require 'jettywrapper'
Jettywrapper.hydra_jetty_version = "v7.1.0"

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks


