# frozen_string_literal: true
module ApplicationHelper
  def emory_creators_display(presenter)
    values = presenter.is_a?(Hash) ? presenter[:value] : presenter.solr_document['creator_ssim']

    safe_join(
      values.map do |author|
        parsed_author = parse_creator_string(author)
        author_span =
          if parsed_author[:orcid]
            sanitize("<span itemprop='name'>#{parsed_author[:first_name]} #{parsed_author[:last_name]} #{orcid_link_for_creator(parsed_author[:orcid])}
                     #{parsed_author[:affiliation].present? ? ",#{parsed_author[:affiliation]}" : ''}</span>")
          else
            tag.span(author, itemprop: 'name')
          end

        content_tag(:span, author_span, itemprop: 'creator', itemscope: '', itemtype: 'http://schema.org/Person', class: 'attribute attribute-creator')
      end
    )
  end

  def orcid_link_for_creator(orcid_id)
    link_to(image_tag("https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png", alt: 'ORCID logo', size: "16"),
            "https://orcid.org/#{orcid_id}")
  end

  def parse_creator_string(creator_string)
    parts = creator_string&.split(',')&.map(&:strip) || []

    {
      last_name: parts[0] || '',
      first_name: parts[1] || '',
      **parse_remaining_parts(parts[2..-1] || [])
    }
  end

  private

  def parse_remaining_parts(remaining_parts)
    return { institution: '', orcid_id: '' } if remaining_parts.empty?

    orcid_id = extract_orcid(remaining_parts)
    institution = orcid_id ? remaining_parts[0..-2].join(', ') : remaining_parts.join(', ')

    { institution:, orcid_id: }
  end

  def extract_orcid(parts)
    return '' unless parts.any?
    valid_orcid?(parts.last) ? parts.pop : ''
  end

  def valid_orcid?(id)
    id.to_s.match?(/^\d{4}-\d{4}-\d{4}-\d{3}[0-9X]$/)
  end
end
