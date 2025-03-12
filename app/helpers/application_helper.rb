# frozen_string_literal: true
# rubocop:disable Rails/OutputSafety
module ApplicationHelper
  def emory_creators_display(presenter)
    values = presenter.is_a?(Hash) ? presenter[:value] : presenter.solr_document['creator_ssim']
    values_html = pull_html_values(values)
    first_five = values_html.first(5)
    remaining_authors = values_html.drop(5)
    return_array = raw(safe_join(first_five))

    return_array << remaining_authors_html(presenter, remaining_authors) if remaining_authors.present?
    return_array
  end

  def orcid_link_for_creator(orcid_id)
    link_to(image_tag("https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png", alt: 'ORCID logo', size: "16"),
            "https://orcid.org/#{orcid_id}")
  end

  def parse_creator_string(creator_string)
    parts = creator_string&.split(',')&.map(&:strip) || []

    {
      first_name: parts[0] || '',
      last_name: parts[1] || '',
      **parse_remaining_parts(parts[2..-1] || [])
    }
  end

  private

  def parse_remaining_parts(remaining_parts)
    return { institution: '', orcid: '' } if remaining_parts.empty?

    orcid = extract_orcid(remaining_parts)
    institution = remaining_parts.join(', ')

    { institution:, orcid: }
  end

  def extract_orcid(parts)
    return '' unless parts.any?
    valid_orcid?(parts.last) ? parts.pop : ''
  end

  def valid_orcid?(id)
    id.to_s.match?(/^\d{4}-\d{4}-\d{4}-\d{3}[0-9X]$/)
  end

  def remaining_authors_html(presenter, remaining_authors)
    unique_doc_id = presenter.is_a?(Hash) ? presenter[:document]['id'] : presenter.solr_document['id']
    raw(
    "<span id='remaining-authors-#{unique_doc_id}' class='collapse'>#{safe_join(remaining_authors)}</span>
    <a class='btn-link remaining-authors-collapse collapsed'
      data-toggle='collapse'
      role='button'
      aria-expanded='false'
      aria-controls='remaining-authors'
      href='#remaining-authors-#{unique_doc_id}'></a>"
  )
  end

  def pull_html_values(values)
    values.map do |author|
      parsed_author = parse_creator_string(author)
      author_span =
        if parsed_author[:orcid].present?
          sanitize("<span itemprop='name'>#{parsed_author[:first_name]} #{parsed_author[:last_name]} #{orcid_link_for_creator(parsed_author[:orcid])}
                     #{parsed_author[:institution].present? ? ", #{parsed_author[:institution]}" : ''}</span>")
        else
          tag.span("#{parsed_author[:first_name]} #{parsed_author[:last_name]}#{parsed_author[:institution].present? ? ", #{parsed_author[:institution]}" : ''}", itemprop: 'name')
        end

      content_tag(:span, author_span, itemprop: 'creator', itemscope: '', itemtype: 'http://schema.org/Person', class: 'attribute attribute-creator')
    end
  end
end
# rubocop:enable Rails/OutputSafety
