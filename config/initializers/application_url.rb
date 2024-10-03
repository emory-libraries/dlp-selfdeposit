# frozen_string_literal: true
module ApplicationUrl
  def self.base_url
    Rails.application.routes.default_url_options[:host] || ENV['APPLICATION_HOST'] || 'localhost:3000'
  end
end
