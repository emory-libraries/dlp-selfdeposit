# frozen_string_literal: true

class FilesetCleanUpJob < Hyrax::ApplicationJob
  def perform(*file_set_ids)
    csv_path = Rails.root.join('tmp', 'emory', 'index_file_set_results.csv')
    ::FileUtils.mkdir_p(File.dirname(csv_path))
    CSV.open(csv_path, "w") do |csv|
      if file_set_ids.present?
        file_set_ids.flatten.each do |id|
          file_set = ::Hyrax.query_service.find_by(id:)
          process_fileset(file_set, csv)
        end
      else
        ::Hyrax.query_service.find_all_of_model(model: ::FileSet).each do |file_set|
          process_fileset(file_set, csv)
        end
      end
    end
  end

  private

  def process_fileset(file_set, csv)
    if file_set.file_ids.present?
      characterize_file_set(file_set, csv)
    else
      csv << [file_set.id, "Fileset contains no binaries/files to characterize", "Not Processed"]
    end
  end

  def characterize_file_set(file_set, csv)
    ::ValkyrieCharacterizationJob.perform_later(file_set.original_file_id.to_s)
    csv << [file_set.id, "Fileset not characterized", "Queued"]
  end
end
