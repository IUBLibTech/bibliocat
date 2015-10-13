#
# Ruby process for batch import, called by rake tasks
#

module Bibliocat

  module Ingest

    module Tasks
      def Tasks.batch_import(config_file, data_file, start_line = 1)
        Settings.add_source! config_file
        Settings.reload!
        batch_config = Settings.batch_import_config.to_hash

        work_type = batch_config[:work_type].constantize
        owner = User.find_by_email(batch_config[:owner])
        line = 0

        CSV.foreach(data_file, headers:true) do |row|
          line += 1
          # Skip ahead to the start line
          next if line < start_line

          work_attributes = {}
          row.each do |label, data|
            col_conf = batch_config[:fieldmap][label.upcase.to_sym]

            # Skip empty data fields
            next if data.blank?

            # Filter out unprintable characters.
            # Fixes illegal character exceptions in Solr.
            data.strip!
            data.gsub!(/[^[:print:]]/, '')

            # Handle lookup option
            if col_conf.has_key? :lookup
              data = batch_config[:lookup][col_conf[:lookup].to_sym][data.upcase.to_sym]
            end

            # Handle delimiter option
            if col_conf.has_key? :delimiter
              data = data.split col_conf[:delimiter]
            end

            # Write data to attribute
            # Throw away data for nil targets
            unless col_conf[:target].nil?
              target = col_conf[:target].to_sym
              # Make sure multivalued fields are in an array
              if data.is_a? Enumerable or work_type.defined_attributes[target].try(:multiple)
                work_attributes[target] = [work_attributes[target]].compact unless work_attributes[target].is_a? Enumerable
                data = [data] unless data.is_a? Enumerable
                work_attributes[target].concat data
              else  # data.is_a? String
                if work_attributes[target].blank?
                  work_attributes[target] = data
                elsif work_attributes[target].is_a? String
                  work_attributes[target] = "#{work_attributes[target]} #{data}"
                elsif work_attributes[target].is_a? Enumerable
                  work_attributes[target] << data
                else
                  work_attributes[target] = data
                end
              end
            end
          end

          # Create work and save
          next if work_attributes.empty?
          work = Worthwhile::CurationConcern.actor(work_type.new, owner, work_attributes)
          if work.create
            print "Work object #{work.curation_concern.pid} successfully created.\n"
          else
            print "ERROR: Could not save work from line #{line}!\n"
            print "Data: #{work_attributes}\n"
            print "Reason: #{work.curation_concern.errors.messages}\n"
            exit(1)
          end
        end
      end

      def Tasks.old_batch_import(user_email)
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