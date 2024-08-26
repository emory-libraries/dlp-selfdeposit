# frozen_string_literal: true

module FedoraThreeObjectsMigrationMethods
  private

  def make_pid_folder
    FileUtils.mkdir_p "emory_#{@pid}"
  end

  def pull_pid_xml
    system('fedora-export.sh', @fedora_three_path.split('://').last, @fedora_username, @fedora_password,
           "emory:#{@pid}", 'info:fedora/fedora-system:FOXML-1.1', 'migrate', '.', @fedora_three_path.split('://').first)
    file = File.open("./emory_#{@pid}.xml")
    Nokogiri::XML(file)
  end

  def copy_files_to_folder
    datastreams = @pid_xml.xpath('//foxml:datastream')

    @pids_with_no_binaries += [@pid] if pid_lacks_binaries(datastreams)
    return if pid_lacks_binaries(datastreams)

    make_pid_folder

    datastreams.each do |datastream|
      if test_for_audit(datastream:)
        pull_audit_object(datastream:)
      elsif test_for_xmls(datastream:)
        pull_xml_object(datastream:)
      elsif test_for_license(datastream:) || test_for_allowed_mime_type(datastream:)
        pull_binary_object(datastream:)
      end
    end
  end

  def test_for_xmls(datastream:)
    datastream['ID'] != 'AUDIT' && ['text/xml', 'application/rdf+xml'].include?(datastream.elements.first['MIMETYPE'])
  end

  def test_for_audit(datastream:)
    datastream['ID'] == 'AUDIT'
  end

  def test_for_license(datastream:)
    datastream['ID'] == 'SYMPLECTIC-LICENCE'
  end

  def test_for_allowed_mime_type(datastream:)
    ALLOWED_TYPES.any? { |k, _v| datastream.elements.first['MIMETYPE'].include?(k.to_s) }
  end

  def pid_lacks_binaries(datastreams)
    tested_datastreams = datastreams.reject do |ds|
      test_for_xmls(datastream: ds) || test_for_audit(datastream: ds) || !test_for_allowed_mime_type(datastream: ds) || test_for_license(datastream: ds)
    end
    tested_datastreams.empty?
  end

  def pull_audit_object(datastream:)
    IO.copy_stream(StringIO.new(datastream.at_xpath('//foxml:datastreamVersion/foxml:xmlContent').to_s), "./emory_#{@pid}/AUDIT.xml")

    record_filenames_with_path('AUDIT.xml')
  end

  def pull_xml_object(datastream:)
    xml_doc = datastream['ID']
    download = URI.open("#{@fedora_three_path}/fedora/get/emory:#{@pid}/#{xml_doc}")
    filename = "#{download.base_uri.to_s.split('/')[-1]}.xml"

    IO.copy_stream(download, "./emory_#{@pid}/#{filename}")
    record_filenames_with_path(filename)
  end

  def pull_binary_object(datastream:)
    binary_save_name = process_binary_filename(datastream:)
    download = URI.open("#{@fedora_three_path}/fedora/get/emory:#{@pid}/#{@binary_id}")

    IO.copy_stream(download, "./emory_#{@pid}/#{binary_save_name}")
    record_filenames_with_path(binary_save_name)
  end

  def pull_pids_csv
    ::CSV.open(@pids, headers: true, return_headers: false).map(&:fields).flatten
  end

  def record_filenames_with_path(filename)
    @pids_with_filenames[@pid] = @pids_with_filenames[@pid].nil? ? filename : @pids_with_filenames[@pid] + ";#{filename}"
  end

  def file_end_reports
    # PIDs with no binaries report
    File.write("./pids_with_no_binaries_#{@date_time_started}.txt", "List of PIDs with no binary files: #{@pids_with_no_binaries.join(', ')}") unless @pids_with_no_binaries.empty?

    return if @pids_with_filenames.empty?
    # PIDs with binaries CSV
    ::CSV.open("./pids_with_binaries_#{@date_time_started}.csv", 'wb') do |csv|
      csv << ['pid', 'filenames']
      @pids_with_filenames.to_a.each { |elem| csv << elem }
    end
  end

  def truncate_long_filenames(filename)
    if filename.length > 150
      filename_chunks = filename.split('.')
      [filename_chunks.first[0..99], 'TRUNCATED_FILE_NAME', ".#{filename_chunks.last}"].join
    else
      filename
    end
  end

  def process_binary_filename(datastream:)
    @binary_id = datastream['ID']
    binary_filename = datastream.elements.first['LABEL']
    blank_filename_test = binary_filename.empty? || binary_filename.include?('/') || (!test_for_license(datastream:) && !ALLOWED_TYPES.values.any? { |t| binary_filename.include?(".#{t}") })
    binary_ext = ALLOWED_TYPES.find { |k, _v| datastream.elements.first['MIMETYPE'].include?(k.to_s) }[1] unless test_for_license(datastream:)
    blank_filename_test ? ["content", binary_ext].join('.') : truncate_long_filenames(binary_filename.tr(' ', '_'))
  end
end
