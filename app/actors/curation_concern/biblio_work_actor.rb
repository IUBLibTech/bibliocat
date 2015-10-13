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

    # Commit to a secondary Solr index
    def save
      super
      Thread.new do
        begin
          solr_url = Settings.work_types.to_hash[curation_concern.human_readable_type.to_sym][:solr_url]
          ActiveFedora::SolrService.register(solr_url)
          curation_concern.update_index
        rescue
          pp $!
        end
      end
    end

  end
end
