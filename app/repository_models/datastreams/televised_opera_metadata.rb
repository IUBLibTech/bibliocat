class TelevisedOperaMetadata < ActiveFedora::NtriplesRDFDatastream
  include BiblioWorkRdfProperties

  #TODO Here we need to walk across vocabularies unique to the work type
  # We will check first to hopefully find the named vocab in RDF:: or RDF::Vocab.
  # Failing that we will create a vocab definition on the fly, providing we have a URI

    # Map properties from vocabularies
    work_type = 'Televised Opera' 
    # FIXME Why doesn't my custom i18n_set method work?
=begin
    if self.i18n_set? work_type + '.fields' 
      vocabs =  I18n.t work_type + '.fields' 
    else 
      vocabs =  I18n.t 'Generic Work.fields' 
    end 
=end
    vocabs =  I18n.t work_type + '.fields' 

    vocabs.each do |vocab, fields|
      unless vocab.to_s == 'RDF::DC'
        fields.each do |key, value|
          # FIXME Why doesn't my custom class_send method work?
          #property key.to_sym, predicate: class_send(vocab.to_s,key.to_s) do |index|
          property key.to_sym, predicate: Object.const_get(vocab.to_s).send(key.to_sym) do |index|
            index.as :stored_searchable, :facetable
          end
        end
      end
    end

=begin
    property :composer, predicate: RDF::MO.composer do |index|
      index.as :stored_searchable
    end
    property :engineer, predicate: RDF::MO.engineer do |index|
      index.as :stored_searchable, :facetable
    end
=end

  # We need a way to check for classes that can return methods for our vocab names
  def class_send(class_name, method, *args)
    return nil unless Object.const_defined?(class_name)
    c = Object.const_get(class_name)
    c.respond_to?(method) ? c.send(method, *args) : nil
  end

  # TODO We won't always drive vocabs with locales but for now we need a helper for sanity checks
  def i18n_set? key
      I18n.t key, :raise => true rescue false
  end
end
