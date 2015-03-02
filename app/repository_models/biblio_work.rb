# Generated via
#  `rails generate worthwhile:work BiblioWork`
class BiblioWork < ActiveFedora::Base
  include ::CurationConcern::Work
  include ::CurationConcern::WithBasicMetadata
end
