# frozen_string_literal: true

class FilesetCleanUpJob < Hyrax::ApplicationJob
  def perform(*file_set_ids)
    CSV.open("config/emory/index_file_set_results.csv", "w") do |csv|
      if file_set_ids.present?
        file_set_ids.flatten.each do |id|
          process_fileset(::FileSet.find(id), csv)
        end
      else
        FileSet.all.find_each do |file_set|
          process_fileset(file_set, csv)
        end
      end
    end
  end

  private

  def process_fileset(file_set, csv)
    characterize_file_set(file_set, csv)
  end

  def characterize_file_set(file_set, csv)
    ValkyrieCharacterizationJob.perform_later(file_set.original_file_id)
    csv << [file_set.id, "Fileset not characterized", "Queued"]
  end
end
