# frozen_string_literal: true
# To process reports that detail derelict FileSets, run:
#   rake selfdeposit:file_sets:report_derelict_objects
# The reports will be placed within `tmp/emory/`.
#   - The report containing ids for FileSets without binaries/files
#     will be entitled `file_sets_without_files.csv`.
#   - The report containing ids for FileSets unlinked to any Publications
#     will be named `file_sets_unlinked_to_publications.csv`.
# The reports will only deposit to that folder if ids are found for each report.

namespace :selfdeposit do
  namespace :file_sets do
    desc "Perform two reports that detail derelict FileSets"
    task report_derelict_objects: :environment do
      DerelictFileSetReportJob.perform_later
    end
  end
end
