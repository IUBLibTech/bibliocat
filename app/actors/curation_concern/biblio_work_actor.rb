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
        solr_url = I18n.t "#{curation_concern.human_readable_type}.solr_url"
        if /^http/ =~ solr_url
          ActiveFedora::SolrService.register(solr_url)
          curation_concern.update_index
        end
      end
    end

  end
end
