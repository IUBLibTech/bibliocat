#
# Ruby process for batch import, called by rake tasks
#

module Bibliocat

  module Ingest

    module Tasks

      def Tasks.batch_import
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
              Helpers::import_manifest(subdir, manifest) unless manifest.nil?
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

      def Helpers.work_hash(options = {})
        { 'descMetadata' => { 'title' => options['title'],
                              'creator' => options['creator'],
                              'contributor' => options['contributor'],
                              'description' => options['description'],
                              'subject' => options['subject'],
                              'publisher' => options['publisher'],
                              'language' => options['language'],
                              'rights' => options['rights']
        },
          'content' => { 'image' => options['image']
          }
        }
      end

      def Helpers.structure_array(struct_string, delimiter = '--')
        result = struct_string.split(delimiter)
        result.each_with_index do |value, index|
          result[index] = result[index - 1] + delimiter + value unless index == 0
        end
        result
      end


      def Helpers.import_manifest(subdir, manifest)
        if manifest["works"].nil? or manifest["works"].empty?
          puts "ABORTING: No works listed in manifest."
        else
          manifest["works"].each do |work|
            print "Importing work: #{work['descMetadata'] && work['descMetadata']['title'] ? work['descMetadata']['title'] : '(title unavailable)'}\n"
            import_work(subdir, work)
          end
        end
      end

      def Helpers.import_work(subdir, work_yaml)
        work_attributes = {}
        begin
          work_yaml["descMetadata"].each_pair do |key, value|
            work_attributes[key.to_sym] = value
          end
        rescue
          puts "ABORTING WORKS CREATION: invalid structure in descMetadata"
          return
        end
        if work_attributes.any?
          begin
            work = BiblioWork.new(work_attributes)
          rescue
            puts "ABORTING WORKS CREATION: invalid contents of descMetadata:"
            puts work_attributes.inspect
            return
          end
        end
        if work_yaml["content"] && work_yaml["content"]["image"]
          begin
            imagePath = Rails.root + subdir + "content/" + work_yaml["content"]["image"]
            print "Adding image file.\n"
            #MIGHT NEED NEW OBJECT HERE paged.pagedXML.content = File.open(xmlPath)
          rescue
            puts "ABORTING WORKS CREATION: unable to open image file: #{imagePath}"
            return
          end
        else
          print "No image file specified.\n"
        end
        if work
          #TODO: check for failed connection
          if work.save
            print "Work object #{work.pid} successfully created.\n"
          else
            puts "ABORTING WORKS CREATION: problem saving work object"
            puts work.errors.messages
            return
          end


          print "\nUpdating work index.\n"
          work.reload
          work.update_index
          print "Done.\n\n"

        end
      end
    end
  end
end