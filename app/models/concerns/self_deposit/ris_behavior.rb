# frozen_string_literal: true

module SelfDeposit::RisBehavior
  RIS_GENRE_MATCHER = {
    'Article': 'JOUR',
    'Book': 'BOOK',
    'Book Chapter': 'CHAP',
    'Conference Paper': 'CONF',
    'Poster': 'GEN',
    'Presentation': 'GEN',
    'Report': 'REPORT'
  }.freeze
  URL_REGEX = /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix

  def export_as_ris(base_url)
    ris_format = ris_format_template
    ret_text = +''

    pull_values_for_ris_fields(ris_format:)

    genre = ris_format[:TY]

    process_ris_ret_txt(ris_format:, ret_text:, genre:, base_url:)
    ret_text
  end

  def ris_filename
    "#{id}.ris"
  end

  private

  def pull_values_for_ris_fields(ris_format:)
    ris_format.each do |ris_key, solr_field|
      ris_format[ris_key] = try(:[], solr_field)
    end
  end

  def process_doi_field(ris_key:, value:, ret_text:)
    dois = value.select { |v| v.include?('doi.org') && v.match?(URL_REGEX) }
    dois.each { |doi| assign_unaltered_value_to_ret_txt(ret_text:, ris_key:, value: doi) } if dois.present?
  end

  def process_parent_title_field(ris_key:, value:, genre:, ret_text:)
    ret_text << "JO  - #{value}\n" if genre == 'Article'
    assign_unaltered_value_to_ret_txt(ret_text:, ris_key:, value:) if genre == 'Book Chapter'
  end

  def process_ris_ret_txt(ris_format:, ret_text:, genre:, base_url:)
    ris_format.each do |ris_key, value|
      ret_text << "#{ris_key}  - #{RIS_GENRE_MATCHER[genre.to_sym]}\n" if ris_key == :TY && genre.present?
      process_fields_with_extended_logic(ris_key:, value:, ret_text:, genre:, base_url:)
      Array(value).each { |v| assign_unaltered_value_to_ret_txt(ret_text:, ris_key:, value: v) } if value.present? && [:TI, :AU, :LA, :PY, :PB, :CY].include?(ris_key)
    end
  end

  def assign_unaltered_value_to_ret_txt(ret_text:, ris_key:, value:)
    ret_text << "#{ris_key}  - #{value}\n"
  end

  def ris_format_template
    {
      "TY": :content_genre_ssi, "TI": :title_tesim, "AU": :creator_tesim, "LA": :language_tesim, "PY": :date_issued_year_tesi, "PB": :publisher_tesim,
      "DO": :final_published_versions_tesim, "BT": :parent_title_tesi, "T2": :conference_name_tesi, "VL": :volume_tesi, "IS": :issue_tesi, "SP": :page_range_start_tesi,
      "EP": :page_range_end_tesi, "CY": :place_of_production_tesi, "L2": :emory_persistent_id_ssi
    }
  end

  def process_l2_fields(ret_text:, ris_key:, value:, base_url:)
    assign_unaltered_value_to_ret_txt(ret_text:, ris_key:, value: "#{base_url}/purl/#{value}")
  end

  def process_field_with_added_genre_logic(ret_text:, ris_key:, value:, tests_pass:)
    assign_unaltered_value_to_ret_txt(ret_text:, ris_key:, value:) if tests_pass
  end

  def this_field_is_present?(ris_key:, expected_key:, value:)
    Array(expected_key).include?(ris_key) && value.present?
  end

  # rubocop:disable Style/IfUnlessModifier
  def process_fields_with_extended_logic(ris_key:, value:, ret_text:, genre:, base_url:)
    process_doi_field(ris_key:, value:, ret_text:) if this_field_is_present?(ris_key:, expected_key: :DO, value:)
    process_parent_title_field(ris_key:, value:, genre:, ret_text:) if this_field_is_present?(ris_key:, expected_key: :BT, value:)
    if this_field_is_present?(ris_key:, expected_key: :T2, value:)
      process_field_with_added_genre_logic(ret_text:, ris_key:, value:, tests_pass: ["Conference Paper", "Poster", "Presentation"].include?(genre))
    end
    if this_field_is_present?(ris_key:, expected_key: [:VL, :IS], value:)
      process_field_with_added_genre_logic(ret_text:, ris_key:, value:, tests_pass: ["Article", "Conference Paper"].include?(genre))
    end
    if this_field_is_present?(ris_key:, expected_key: [:SP, :EP], value:)
      process_field_with_added_genre_logic(ret_text:, ris_key:, value:, tests_pass: ["Article", "Book Chapter", "Conference Paper"].include?(genre))
    end
    process_l2_fields(ret_text:, ris_key:, value:, base_url:) if this_field_is_present?(ris_key:, expected_key: :L2, value:)
  end
  # rubocop:enable Style/IfUnlessModifier
end
