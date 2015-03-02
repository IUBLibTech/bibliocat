# Generated via
#  `rails generate worthwhile:work BiblioWork`

class CurationConcern::BiblioWorksController < ApplicationController
  include Worthwhile::CurationConcernController
  set_curation_concern_type BiblioWork
end
