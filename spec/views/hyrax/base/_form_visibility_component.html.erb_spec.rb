# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hyrax/base/_form_visibility_component.html.erb', type: :view do
  let(:user) { stub_model(User) }
  let(:publication) { Publication.new }
  let(:form) { Hyrax::Forms::ResourceForm.for(resource: publication) }
  let(:form_template) do
    %(
      <%= simple_form_for [main_app, @form] do |f| %>
        <%= render "hyrax/base/form_visibility_component", f: f %>
      <% end %>
    )
  end

  let(:rendered_save) do
    # explicitly save rendered, as it seems to become empty at some point during processing
    assign(:form, form)
    render inline: form_template
  end

  let(:page) do
    Capybara::Node::Simple.new(rendered_save)
  end

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:action_name).and_return('new')
  end

  shared_examples 'renders the expected lis' do |num_of_lis, expected_badges|
    it "renders only #{num_of_lis} options for the visibility assignment" do
      pulled_lis = page.find_all('li', class: 'form-check')

      expect(pulled_lis.size).to eq(num_of_lis)
      expect(pulled_lis.map { |li| li.find_css('label span.badge').text }).to match_array(expected_badges)
    end
  end

  context 'typical user' do
    include_examples 'renders the expected lis', 2, ['PublicPublic', 'Embargo']
  end

  context 'admin user' do
    before { allow(user).to receive(:admin?).and_return(true) }

    include_examples 'renders the expected lis', 5, ["Embargo", "Institution", "Lease", "Private", "PublicPublic"]
  end
end
