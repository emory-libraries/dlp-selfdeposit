# frozen_string_literal: true
module ApplicationHelper
  def emory_creators_display(presenter)
    values = presenter.is_a?(Hash) ? presenter[:value] : presenter.solr_document['creator_ssim']

    safe_join(
      values.map do |author|
        author_array = author.split(',').map(&:strip)
        author_span = if author_array.length > 3
                        sanitize("<span itemprop='name'>#{author_array[0]} #{author_array[1]} #{orcid_link_for_creator(author_array[3])}, #{author_array[2]}</span>")
                      else
                        tag.span([author_array[0], "#{author_array[1]},", author_array[2]].join(' '), itemprop: 'name')
                      end

        content_tag(:li, author_span, itemprop: 'creator', itemscope: '', itemtype: 'http://schema.org/Person', class: 'attribute attribute-creator')
      end
    )
  end

  def orcid_link_for_creator(orcid_id)
    link_to(image_tag("https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png", alt: 'ORCID logo', size: "16"),
            "https://orcid.org/#{orcid_id}")
  end
end
