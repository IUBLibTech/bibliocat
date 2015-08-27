class TelevisedOperaMetadata < ActiveFedora::NtriplesRDFDatastream
  include BiblioWorkRdfProperties



  def initialize(digital_object=nil, dsid=nil, options={})
    super(digital_object, dsid, options)
    # Here we need to walk across vocabularies unique to the work type
    # We will check first to hopefully find the named vocab in RDF:: or RDF::Vocab.
    # Failing that we will create a vocab definition on the fly, providing we have a URI

    work_type = 'Televised Opera'
    unless Settings.work_types.to_hash[work_type.to_sym].nil?
      fields =  Settings.work_types.to_hash[work_type.to_sym][:fields]
    else 
      fields =  Settings.work_types.to_hash['Biblio Work'.to_sym][:fields]
    end 

    # For every vocab section in the config, take each field and setup a property mapping
    fields.each do |field, props|
      unless props[:vocab].to_s == 'RDF::DC'
        vocab_name = props[:vocab]
        vocab_uri = props[:vocab_uri]
        # Handle custom vocab with a URI by creating it on the fly
        if vocab_uri
          this_vocab = RDF::Vocabulary.new(vocab_uri)
          self.class.property field.to_sym, predicate: this_vocab[field] do |index|
            index.as :stored_searchable, :facetable
          end
        else
          # Handle vocabularies available in either RDF:: or RDF::Vocab
          self.class.property field.to_sym, predicate: vocab_name.safe_constantize.try(field.to_sym) do |index|
            index.as :stored_searchable, :facetable
          end
        end
      end
    end
  end

end
