# frozen_string_literal: true
FactoryBot.define do
  factory :emory_saml_user, class: 'User' do
    sequence(:email) { |n| "samluser#{n}@emory.edu" }
    sequence(:uid) { |n| "samluser#{n}" }
    provider { 'saml' }
    ppid { '12345' }

    after(:build) do |user|
      user.password = 'testing123'
      user.password_confirmation = 'testing123'
    end

    trait :with_display_name do
      sequence(:display_name) { |n| "Test User #{n}" }
    end

    trait :tezprox do
      uid { 'tezprox' }
      ppid { '12345' }
      provider { 'saml' }
      display_name { 'Tezprox User' }
    end
  end
end
