module BiblioConcern::WithBasicMetadata
  extend ActiveSupport::Concern

  included do 

    def self.i18n_set? key
      I18n.t key, :raise => true rescue false
    end

    #has_metadata "descMetadata", type: ::BiblioWorkMetadata

    # Validations that apply to all types of Work AND Collections
    validates_presence_of :title, message: 'Your work must have a title.'

    # Metadata always present
    has_attributes :created, :date_modified, :date_uploaded, datastream: :descMetadata, multiple: false

    # Descriptive metadata from vocabularies
    work_type = self.human_readable_type 
    if self.i18n_set? work_type + '.fields' 
      vocabs =  I18n.t work_type + '.fields' 
    else 
      vocabs =  I18n.t 'Generic Work.fields' 
    end 

    vocabs.each do |vocab, fields|
      fields.each do |key, value|
        has_attributes key, datastream: 'descMetadata',
        multiple: value[:multiple].to_s == 'true' ? true : false
      end
    end

    def to_solr(solr_doc={}, opts={})
      super(solr_doc, opts)
      # These extra fields are being written so as to be picked up by Spotlight
      # TODO Figure out what new fields to write to Solr using following example
      solr_doc[Solrizer.solr_name('full_title', 'tesim')] = self.title
      solr_doc[Solrizer.solr_name('personal_name', 'ssm')] = self.creator
      solr_doc[Solrizer.solr_name('abstract', 'tesim')] = self.description
      solr_doc[Solrizer.solr_name('note_source', 'tesim')] = self.source
      return solr_doc
    end
  end
end 
