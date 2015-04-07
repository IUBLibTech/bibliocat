#
# Ruby process for batch import, called by rake tasks
#

module Bibliocat

  module Ingest

    module Tasks

      def Tasks.batch_import(user_email)
        Helpers::ingest_folders.each_with_index do |subdir, index|
          print "Ingesting batch directory #{index + 1} of #{Helpers::ingest_folders.size}: #{subdir}\n"
          manifest_files = Dir.glob(subdir + "/" + "manifest*.yml").select { |f| File.file?(f) }
          if manifest_files.any?
            manifest_files.each do |manifest_filename|
              begin
                manifest = YAML.load_file(manifest_filename)
              rescue
                puts "ABORTING: Unable to open/parse manifest file: #{manifest_filename}."
                manifest = nil
              end
              print "Found manifest file: #{manifest_filename}\n"
              Helpers::import_manifest(subdir, manifest, user_email) unless manifest.nil?
            end
          else
            print "No manifest YAML files found in this directory.\n"
          end
        end
      end
    end


    module Helpers

      def Helpers.ingest_folders
        ingest_root = "spec/fixtures/ingest/bibliocat/"
        return Dir.glob(ingest_root + "*").select { |f| File.directory?(f) }
      end

      #FIXME: get actual id, date values
      def Helpers.manifest_hash(options = {})
        options['id'] ||= 'mybatch'
        options['date'] ||= '12-1-2014'

        { 'manifest' => { 'id' => options['id'], 'date' => options['date'] },
          'works' => options['works'] || []
        }
      end

      # Seems unused
      def Helpers.work_hash(options = {})
        imagePath = Rails.root + subdir + "content/" + options['image']
        { 'descMetadata' => { 'title' => options['title'],
                              'creator' => options['creator'],
                              'contributor' => options['contributor'],
                              'description' => options['description'],
                              'subject' => options['subject'],
                              'publisher' => options['publisher'],
                              'language' => options['language'],
                              'visibility' => options['visibility'],
                              'visibility_during_embargo' => options['visibility_during_embargo'],
                              'embargo_release_date' => options['embargo_release_date'],
                              'visibility_after_embargo' => options['visibility_after_embargo'],
                              'visibility_during_lease' => options['visibility_during_lease'],
                              'lease_expiration_date' => options['lease_expiration_date'],
                              'visibility_after_lease' => options['visibility_after_lease'],
                              'rights' => options['rights'],
                              'files' => open(imagePath)
        },
          'content' => { 'image' => options['image']
          }
        }
      end

      def Helpers.import_manifest(subdir, manifest, user_email)
        if manifest["works"].nil? or manifest["works"].empty?
          puts "ABORTING: No works listed in manifest."
        else
          manifest["works"].each do |work|
            print "Importing work: #{work['descMetadata'] && work['descMetadata']['title'] ? work['descMetadata']['title'] : '(title unavailable)'}\n"
            import_work(subdir, work, user_email)
          end
        end
      end

      def Helpers.import_work(subdir, work_yaml, user_email)
        work_attributes = {}
        begin
          work_yaml["descMetadata"].each_pair do |key, value|
            work_attributes[key.to_sym] = value
          end
        rescue
          puts "ABORTING WORKS CREATION: invalid structure in descMetadata"
          return
        end

        begin
          imagePath = Rails.root + subdir + "content/"
          work_yaml["content"].each_pair do |key, value|
             file_to_ingest = IngestableFile.open(imagePath + value, 'rb')
             work_attributes['files'] = file_to_ingest
          end
        rescue
          puts "ABORTING WORKS CREATION: invalid structure in content"
          return
        end

        begin
          ingest_user = User.find_by_email(user_email)
        rescue
          puts "ABORTING WORKS CREATION: could not find user"
          return
        end

        if work_attributes.any?
          begin
            work = Worthwhile::CurationConcern.actor(BiblioWork.new, ingest_user, work_attributes)
          rescue
            puts "ABORTING WORKS CREATION: creation of CurationConcern failed:"
            puts work_attributes.inspect
            return
          end
        end

        if work
          #TODO: check for failed connection
          if work.create
            print "Work object #{work.curation_concern.pid} successfully created.\n"
          else
            puts "ABORTING WORKS CREATION: problem saving work object"
            puts work.curation_concern.errors.messages
            return
          end


          # print "\nUpdating work index.\n"
          # work.reload
          # if work.update_index
          #   print "Done.\n\n"
          # else
          #   print "Failed to index."
          # end

        end
      end
    end
  end
end