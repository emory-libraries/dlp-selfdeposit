# frozen_string_literal: true
# To cleanup specific file sets, run:
# rake selfdeposit:file_sets:file_sets_cleanup[id1,id2,id3]
# To cleanup all file sets, run:
# rake selfdeposit:file_sets:file_sets_cleanup

namespace :selfdeposit do
  namespace :file_sets do
    desc "Perform characterization on file_sets"
    task :file_sets_cleanup, [:file_set_ids] => :environment do |_t, args|
      if args[:file_set_ids].present?
        file_set_ids = args[:file_set_ids].split(',')
        puts "Cleaning up FileSet(s) with ID(s): #{file_set_ids.join(', ')}"
        FilesetCleanUpJob.perform_later(file_set_ids)
      else
        puts "Cleaning up all FileSets"
        FilesetCleanUpJob.perform_later
      end
    end
  end
end
