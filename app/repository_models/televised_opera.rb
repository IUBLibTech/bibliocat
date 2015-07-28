# Generated via
#  `rails generate bibliocat:work TelevisedOpera`
class TelevisedOpera < ActiveFedora::Base
  include ::CurationConcern::Work
  include BiblioConcern::WithBasicMetadata

  has_metadata "descMetadata", type: ::TelevisedOperaMetadata

end
