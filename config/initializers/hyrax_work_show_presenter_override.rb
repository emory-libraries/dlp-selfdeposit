# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.1] - Changes the page_title value.

Rails.application.config.to_prepare do
  Hyrax::WorkShowPresenter.class_eval do
    def page_title
      "#{title.first} | #{I18n.t('hyrax.product_name')}"
    end
  end
end
