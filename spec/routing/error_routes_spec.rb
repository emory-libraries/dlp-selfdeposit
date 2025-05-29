# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'not_found', type: :routing do
  it 'routes requests for 404 to the errors_controller#not_found' do
    expect(get('/404')).to route_to(
      controller: 'errors',
      action: 'not_found'
    )
  end
end
