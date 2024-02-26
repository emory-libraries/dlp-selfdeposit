# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Publication`
class Publication < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:publication_metadata)
end
