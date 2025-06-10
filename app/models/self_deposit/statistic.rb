# frozen_string_literal: true
module SelfDeposit
  class Statistic < ::Hyrax::Statistic
    def self.content_genres
      ret_hsh = {}
      types = query_works("content_genre_tesi")
      types['Unknown'] = types.delete(nil)
      types.keys.each do |k|
        ret_hsh[k.capitalize] = types[k] if types[k].positive?
      end
      ret_hsh
    end
  end
end
