namespace :bibliocat do
  require "#{Rails.root}/lib/tasks/batch_import"
  require "#{Rails.root}/lib/ingestable_file"
  namespace :import do
    desc "Batch import works using a manifest. Requires user email argument."
    task :batch, [:user] => :environment do |task, args|
      Bibliocat::Ingest::Tasks::batch_import(args.user)
    end
  end
end