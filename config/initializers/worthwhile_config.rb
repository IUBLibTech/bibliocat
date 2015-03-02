Worthwhile.configure do |config|
  # Injected via `rails g worthwhile:work BiblioWork`
  config.register_curation_concern :biblio_work
  config.register_curation_concern 'GenericWork'
end
