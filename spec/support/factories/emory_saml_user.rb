FactoryBot.define do
  factory :emory_saml_user, class: 'User' do
    sequence(:email) { |n| "samluser#{n}@emory.edu" }
    sequence(:uid) { |n| "samluser#{n}" }
    provider { 'saml' }
    
    after(:build) do |user|
      user.password = 'testing123'
      user.password_confirmation = 'testing123'
    end
    
    trait :with_display_name do
      sequence(:display_name) { |n| "Test User #{n}" }
    end

    trait :with_ppid do
      sequence(:ppid) { |n| "PPID#{n}" }
    end

    trait :tezprox do
      uid { 'tezprox' }
      provider { 'saml' }
      display_name { 'Tezprox User' }
    end
  end
end 