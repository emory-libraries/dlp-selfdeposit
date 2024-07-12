# frozen_string_literal: true

module ModsMetadataExtractionMethods
  private

  def pull_mods_xml
    file = File.open(@xml_path)
    Nokogiri::XML(file)
  end

  def assign_values_to_ret_hash
    METADATA_FIELDS_LEGEND.keys.each do |k|
      @ret_hash[k.to_s] = if METADATA_FIELDS_LEGEND[k][:ext_method].nil?
                            el = @mods_xml.xpath(METADATA_FIELDS_LEGEND[k][:xpath])
                            METADATA_FIELDS_LEGEND[k][:processor].call(el)
                          else
                            send(METADATA_FIELDS_LEGEND[k][:ext_method])
                          end
    end
  end

  def create_csv_from_ret_hash
    CSV.open(@desired_csv_filename, "wb") do |csv|
      keys = @ret_hash.keys
      # header_row
      csv << keys
      csv << @ret_hash.values_at(*keys)
    end
  end

  def holding_repository_value
    'Emory University. Library'
  end

  def rights_statements_value
    'http://rightsstatements.org/vocab/InC/1.0/'
  end

  def creator_values
    first_name_values = @mods_xml.xpath('//mods:name[@type="personal"]/mods:namePart[@type="given"]').map { |v| v.text.strip }
    last_name_values = @mods_xml.xpath('//mods:name[@type="personal"]/mods:namePart[@type="family"]').map { |v| v.text.strip }
    affiliation_values = @mods_xml.xpath('//mods:name[@type="personal"]/mods:affiliation').map { |v| v.text.strip }

    first_name_values.each_with_index.map { |v, i| [v, last_name_values[i], affiliation_values[i]].compact.join(', ') }.join('|')
  end

  def publisher_version_value
    unparsed_value = @mods_xml.xpath('//mods:genre[@authority="local"]')&.first&.text&.downcase

    return unless unparsed_value
    parsed_value = if unparsed_value.include? 'final'
                     'Final Published Version'
                   elsif unparsed_value.include? 'preprint'
                     'Preprint (Prior to Peer Review)'
                   elsif unparsed_value.include? 'post'
                     'Author Accepted Manuscript (After Peer Review)'
                   end

    parsed_value
  end

  def extract_creator_last_first
    first_name_values = @mods_xml.xpath('//mods:name[@type="personal"]/mods:namePart[@type="given"]').map { |v| v.text.strip }
    last_name_values = @mods_xml.xpath('//mods:name[@type="personal"]/mods:namePart[@type="family"]').map { |v| v.text.strip }

    first_name_values.each_with_index.map { |v, i| [last_name_values[i], v].compact.join(', ') }.join('|')
  end

  def extract_date_issued_year
    @mods_xml.xpath('/mods:mods/mods:originInfo/mods:dateIssued')&.text&.strip&.split('-')&.first
  end

  def internal_rights_note_value
    raw_elements = @mods_xml.xpath('//mods:accessCondition[@type="restrictions on access"]')

    raw_elements.map do |el|
      el_label = el['displayLabel']
      el_value = el.text

      el_label.empty? ? el_value : "#{el_label}: #{el_value}"
    end.join('; ')
  end
end
