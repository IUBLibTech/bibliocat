class TelevisedOperaMetadata < ActiveFedora::NtriplesRDFDatastream
  include BiblioWorkRdfProperties



  def initialize(digital_object=nil, dsid=nil, options={})
    super(digital_object, dsid, options)
    # Here we need to walk across vocabularies unique to the work type
    # We will check first to hopefully find the named vocab in RDF:: or RDF::Vocab.
    # Failing that we will create a vocab definition on the fly, providing we have a URI

    work_type = 'Televised Opera'
    unless Settings.work_types.to_hash[work_type.to_sym].nil?
      vocabs =  Settings.work_types.to_hash[work_type.to_sym][:fields]
    else 
      vocabs =  Settings.work_types.to_hash['Biblio Work'.to_sym][:fields]
    end 

    # For every vocab section in the config, take each field and setup a property mapping
    vocabs.each do |vocab, fields|
      unless vocab.to_s == 'RDF::DC'
        vocab_name, uri = vocab.to_s.split
        fields.each do |key, value|
          # Handle custom vocab with a URI by creating it on the fly
          if uri
            this_vocab = RDF::Vocabulary.new(uri)
            self.class.property key.to_sym, predicate: this_vocab[key] do |index|
              index.as :stored_searchable, :facetable
            end
          else
            # Handle vocabularies available in either RDF:: or RDF::Vocab
            self.class.property key.to_sym, predicate: vocab_name.safe_constantize.try(key.to_sym) do |index|
              index.as :stored_searchable, :facetable
            end
          end
        end
      end
    end
  end

end
