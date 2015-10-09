namespace :bibliocat do
  require "#{Rails.root}/lib/tasks/batch_import"
  require "#{Rails.root}/lib/ingestable_file"
  namespace :import do
    desc "Batch import works from CSV using a field mapping configuration.\n"
    task :batch, [:configfile, :datafile] => :environment do |task, args|
      Bibliocat::Ingest::Tasks::batch_import(args.configfile, args.datafile)
    end
  end
end