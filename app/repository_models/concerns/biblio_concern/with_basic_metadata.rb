module BiblioConcern::WithBasicMetadata
  extend ActiveSupport::Concern
  
  included do 
    has_metadata "descMetadata", type: ::BiblioWorkMetadata

    # Validations that apply to all types of Work AND Collections
    validates_presence_of :title, message: 'Your work must have a title.'

    # Metadata always present
    has_attributes :created, :date_modified, :date_uploaded, datastream: :descMetadata, multiple: false

    # Descriptive metadata from vocabularies
    vocabs = I18n.t 'bibliowork.fields'
    vocabs.each do |vocab, fields|
      fields.each do |key, value|
        has_attributes key, datastream: 'descMetadata',
        multiple: value[:multiple].to_s == 'true' ? true : false
      end
    end

=begin
    # Single-value fields
    has_attributes :created, :date_modified, :date_uploaded, datastream: :descMetadata, multiple: false
    # Multi-value fields
    has_attributes :contributor, :creator, :coverage, :date, :description, :content_format, :identifier,
                    :language, :publisher, :relation, :rights, :source, :subject, :title, :type,
                    datastream: :descMetadata, multiple: true
=end
  end


end 
