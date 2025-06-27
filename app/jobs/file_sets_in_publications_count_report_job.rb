# frozen_string_literal: true

class FileSetsInPublicationsCountReportJob < Hyrax::ApplicationJob
  def perform
    counts = Hyrax.query_service.custom_queries.find_file_set_counts_for_all_publications
    csv_path = Rails.root.join('tmp', 'emory', "file_sets_in_publications_count_#{DateTime.now.strftime('%Y%m%dT%H%M')}.csv")

    ::FileUtils.mkdir_p(File.dirname(csv_path))
    CSV.open(csv_path, "w") do |csv|
      csv << ['PID', 'FileSet count']
      counts.each { |arr| csv << arr }
    end
  end
end
