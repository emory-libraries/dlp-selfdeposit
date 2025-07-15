# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'error routing', type: :routing do
  it 'routes requests for 404 to the errors_controller#not_found' do
    expect(get('/404')).to route_to(
      controller: 'errors',
      action: 'not_found'
    )
  end

  it 'routes requests for 500 to the errors_controller#unhandled_exception' do
    expect(get('/500')).to route_to(
      controller: 'errors',
      action: 'unhandled_exception'
    )
  end

  it 'routes requests for 422 to the errors_controller#unprocessable' do
    expect(get('/422')).to route_to(
      controller: 'errors',
      action: 'unprocessable'
    )
  end
end
