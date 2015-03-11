# Generated via
#  `rails generate worthwhile:work BiblioWork`
class BiblioWork < ActiveFedora::Base
  include ::CurationConcern::Work
  include ::CurationConcern::WithBasicMetadata

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    # TODO Figure out what new fields to write to Solr using following example
    solr_doc[Solrizer.solr_name('full_title', 'tesim')] = self.title
    solr_doc[Solrizer.solr_name('personal_name', 'ssm')] = self.creator
    solr_doc[Solrizer.solr_name('abstract', 'tesim')] = self.description
    solr_doc[Solrizer.solr_name('note_desc_note', 'tesim')] = self.contributor
    solr_doc[Solrizer.solr_name('corporate_name', 'ssm')] = self.publisher
    solr_doc[Solrizer.solr_name('note_provenance', 'tesim')] = self.coverage
    solr_doc[Solrizer.solr_name('note_source', 'tesim')] = self.source
    return solr_doc
  end

end
