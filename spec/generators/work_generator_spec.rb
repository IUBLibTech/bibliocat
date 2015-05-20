require 'spec_helper'
require 'rails_helper'

require 'generators/bibliocat/work/work_generator'

describe Bibliocat::WorkGenerator, :type => :generator do

 destination File.expand_path('../../../../../tmp/tests', __FILE__)

 before { prepare_destination }

end
