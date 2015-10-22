namespace :bibliocat do
  require "#{Rails.root}/lib/tasks/batch_import"
  require "#{Rails.root}/lib/ingestable_file"
  namespace :import do
    desc "Import works from CSV using a field mapping. Start line optional."
    task :batch, [:configfile, :datafile, :startline] => :environment do |task, args|
      args.with_defaults(startline: 0)
      Bibliocat::Ingest::Tasks::batch_import(args.configfile, args.datafile, args.startline)
    end
  end
end