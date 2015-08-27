# Generated via
#  `rails generate bibliocat:work TelevisedOpera`
module CurationConcern
  class TelevisedOperaActor < CurationConcern::GenericWorkActor
    def create
      super

    end

    def update
      super

    end

    def save
      super
      Thread.new do
        solr_url = Settings.work_types.to_hash[curation_concern.human_readable_type.to_sym][:solr_url]
        ActiveFedora::SolrService.register(solr_url)
        curation_concern.update_index
      end
    end
  end
end
