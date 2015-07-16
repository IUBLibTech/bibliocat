# Generated via
#  `rails generate worthwhile:work BiblioWork`
module CurationConcern
  class BiblioWorkActor < CurationConcern::GenericWorkActor

    def create
      super

    end

    def update
      super

    end

    def save
      super
      Thread.new do
        ActiveFedora::SolrService.register('http://localhost:8983/solr/spotlight')
        curation_concern.update_index
      end
    end

  end
end
