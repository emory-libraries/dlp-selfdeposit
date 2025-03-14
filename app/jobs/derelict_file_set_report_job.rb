# frozen_string_literal: true

class DerelictFileSetReportJob < Hyrax::ApplicationJob
  def perform
    @query_service = Hyrax.query_service
    @file_sets_lacking_files = []
    @file_sets_unlinked_to_publications = []
    @all_file_sets_from_fedora = @query_service.find_all_of_model(model: ::FileSet)
    @all_file_set_ids_linked_publications = @query_service.custom_queries.find_all_file_set_ids_associated_to_publications

    process_file_sets_without_files
    process_file_sets_unlinked_to_publications
    create_report(filename: 'file_sets_without_files.csv', report_array: @file_sets_lacking_files) if @file_sets_lacking_files.present?
    create_report(filename: 'file_sets_unlinked_to_publications.csv', report_array: @file_sets_lacking_files) if @file_sets_lacking_files.present?
  end

  private

  def process_file_sets_without_files
    @all_file_sets_from_fedora.each { |fs| @file_sets_lacking_files << fs if !fs.file_ids.present? }
  end

  def process_file_sets_unlinked_to_publications
    @all_file_sets_from_fedora.each do |fs|
      @file_sets_unlinked_to_publications << fs if !@all_file_set_ids_linked_publications.include?(fs.id.to_s)
    end
  end

  def create_report(filename:, report_array:)
    csv_path = Rails.root.join('tmp', 'emory', filename)
    ::FileUtils.mkdir_p(File.dirname(csv_path))
    CSV.open(csv_path, "w") { |csv| report_array.each { |fs| csv << [fs.id.to_s] } }
  end
end

