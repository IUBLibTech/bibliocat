class TelevisedOperaMetadata < ActiveFedora::NtriplesRDFDatastream
  include BiblioWorkRdfProperties

  #TODO Here we need to walk across vocabularies unique to the work type
  # We will check first to hopefully find the named vocab in RDF:: or RDF::Vocab.
  # Failing that we will create a vocab definition on the fly, providing we have a URI

    # Map properties from vocabularies
    work_type = 'Televised Opera' 
    if self.i18n_set? work_type + '.fields' 
      vocabs =  I18n.t work_type + '.fields' 
    else 
      vocabs =  I18n.t 'Generic Work.fields' 
    end 

    vocabs.each do |vocab, fields|
      fields.each do |key, value|
        property key.to_sym, predicate: class_send(vocab.to_s,key.to_s) do |index|
          index.as :stored_searchable, :facetable
        end
      end
    end

    property :composer, predicate: RDF::MO.composer do |index|
      index.as :stored_searchable
    end
    property :engineer, predicate: RDF::MO.engineer do |index|
      index.as :stored_searchable, :facetable
    end


  # We need a way to check for classes that can return methods for our vocab names
  def class_send(class_name, method, *args)
    return nil unless Object.const_defined?(class_name)
    c = Object.const_get(class_name)
    c.respond_to?(method) ? c.send(method, *args) : nil
  end

  # FIXME We won't always drive vocabs with locales but for now we need a helper for sanity checks
  def i18n_set? key
      I18n.t key, :raise => true rescue false
  end
end
