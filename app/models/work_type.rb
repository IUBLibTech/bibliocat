class WorkType < ActiveFedora::Base

  has_metadata "descMetadata", type: WorkTypeDescMetadata, label: 'WorkType descriptive metadata'

  has_file_datastream 'metadataSchema'
  
  has_attributes :registered_name, :display_name, :is_type_of, datastream: 'descMetadata',  multiple: false

  # Setter for the schema datastream
  def schema_file=(file)
    ds = @datastreams['metadataSchema']
    ds.content = file
    ds.mimeType = 'application/xml'
    ds.dsLabel = file.inspect.sub /.*\/(.*)\>/, '\1'
  end

  # Getter for the schema datastream
  def schema_file
    @datastreams['metadataSchema']
  end

  def schema_datastream
    @datastreams['metadataSchema']
  end

  def self.fedora_url
    @fedora_url ||= ActiveFedora.fedora_config.credentials[:url] + '/'
  end

=begin
  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    return solr_doc
  end
=end

end
