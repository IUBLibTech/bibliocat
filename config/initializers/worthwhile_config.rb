Worthwhile.configure do |config|
  # Injected via `rails g bibliocat:work TelevisedOpera`
  config.register_curation_concern :televised_opera
  # Injected via `rails g worthwhile:work BiblioWork`
  #config.register_curation_concern :biblio_work
  #config.register_curation_concern 'GenericWork'
end
