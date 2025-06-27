# frozen_string_literal: true

class FileSetsInPublicationsCountReportJob < Hyrax::ApplicationJob
  def perform
    publications = Hyrax.query_service.custom_queries.find_all_by_model_via_solr(model: Publication)
    csv_path = Rails.root.join('tmp', 'emory', "file_sets_in_publications_count_#{DateTime.now.strftime('%Y%m%dT%H%M')}.csv")

    ::FileUtils.mkdir_p(File.dirname(csv_path))
    CSV.open(csv_path, "w") do |csv|
      csv << ['PID', 'FileSet count']
      publications.each { |pub| csv << [pub.deduplication_key, pub.member_ids.count] }
    end
  end
end
