# frozen_string_literal: true
class ErrorsController < ApplicationController
  def not_found
    set_locale
  end

  private

  def set_locale
    I18n.locale = :en
  end
end
