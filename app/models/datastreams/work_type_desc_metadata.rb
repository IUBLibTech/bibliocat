# Represent an OAI_DC (Dublin Core XML) datastream.
#--
# Copyright 2014 Indiana University.

class WorkTypeDescMetadata < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(path: 'oai_dc:dc',
      'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
      'xmlns:dc' => 'http://purl.org/dc/elements/1.1/')
    t.registered_name(namespace_prefix: 'dc', index_as: :stored_searchable)
    t.display_name(namespace_prefix: 'dc', index_as: :stored_searchable)
    t.is_type_of(namespace_prefix: 'dc', index_as: :stored_searchable)
  end

  def self.xml_template
    Nokogiri::XML.parse('<oai_dc:dc' \
      ' xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"' \
      ' xmlns:dc="http://purl.org/dc/elements/1.1/"/>')
  end
end
