# frozen_string_literal: true
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }

    transient do
      groups { [] }
    end

    after(:build) do |user, evaluator|
      current_user = user
      User.group_service.add(user: current_user, groups: evaluator.groups)
    end

    after(:create) do |user, _evaluator|
      user.update(uid: user.email) if user.uid.blank?
    end

    trait :with_uid do
      sequence(:uid) { |n| "user#{n}" }
    end

    trait :saml do
      provider { 'saml' }
      sequence(:uid) { |n| "samluser#{n}" }
      sequence(:ppid) { |n| "PPID#{n}" }
    end

    factory :admin do
      groups { ['admin'] }
    end

    factory :user_with_mail do
      after(:create) do |user|
        (1..10).each do |number|
          file = MockFile.new(number.to_s, "Single File #{number}")
          User.batch_user.send_message(user, 'File 1 could not be updated. You do not have sufficient privileges to edit it.', file.to_s, false)
          User.batch_user.send_message(user, 'File 1 has been saved', file.to_s, false)
        end

        files = []
        (1..50).each do |number|
          files << MockFile.new(number.to_s, "File #{number}")
        end
        User.batch_user.send_message(user, 'These files could not be updated. You do not have sufficient privileges to edit them.', 'Batch upload permission denied', false)
        User.batch_user.send_message(user, 'These files have been saved', 'Batch upload complete', false)
      end
    end
  end

  trait :guest do
    guest { true }
  end
end

class MockFile
  attr_accessor :to_s, :id
  def initialize(id, string)
    self.id = id
    self.to_s = string
  end
end
