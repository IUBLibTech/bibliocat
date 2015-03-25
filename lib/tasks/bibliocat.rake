namespace :bibliocat do
  require "#{Rails.root}/lib/tasks/batch_import"
  namespace :import do
    desc "Batch import works using a manifest"
    task :batch => :environment do |task, args|
      Bibliocat::Ingest::Tasks::batch_import
    end
  end
end