# frozen_string_literal: true
namespace :selfdeposit do
  namespace :google_scholar do
    task sitemap: :environment do
      results = Hyrax.query_service.custom_queries.find_all_by_model_via_solr(model: Publication)
      ids = results.map do |x|
        ["#{ENV.fetch('HOME_PATH', 'http://localhost:3000')}/concern/publications/#{x.id}", x.updated_at.to_s]
      end
      builder = Nokogiri::XML::Builder.new do |sitemap|
        sitemap.urlset("xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
                       xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
                       "xsi:schemaLocation": "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd") do
          ids.each do |url, date|
            sitemap.url do
              sitemap.loc url
              sitemap.lastmod date
            end
          end
        end
      end
      File.open(Rails.root.join("public", "sitemap.xml"), "w") { |f| f.write(builder.to_xml) }
    end
  end
end
