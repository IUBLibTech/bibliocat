# Generated via
#  `rails generate worthwhile:work BiblioWork`
class BiblioWork < ActiveFedora::Base
  include ::CurationConcern::Work
  include ::CurationConcern::WithBasicMetadata

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    # TODO Figure out what new fields to write to Solr using following example
    solr_doc[Solrizer.solr_name('my_title', 'ss')] = self.title
    return solr_doc
  end

end
