# frozen_string_literal: true
module SelfDeposit
  class Statistic < ::Hyrax::Statistic
    def self.content_genres
      results = query_works("content_genre_tesi")
      content_genres = []
      results.each do |y|
        if y["content_genre_tesi"].nil? || (y["content_genre_tesi"] == "")
          content_genres.push("Unknown")
        else
          content_genres.push(y["content_genre_tesi"])
        end
      end
      content_genres.group_by { |rt| rt }.transform_values(&:count)
    end
  end
end
