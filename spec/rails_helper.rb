# frozen_string_literal: true
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] = 'test'
ENV['DATABASE_URL'] = ENV['DATABASE_TEST_URL'] if ENV['DATABASE_TEST_URL'] && !ENV['CI']
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'devise'
require 'devise_saml_authenticatable'
require 'hyrax/specs/shared_specs/factories/strategies/json_strategy'
require 'hyrax/specs/shared_specs/factories/strategies/valkyrie_resource'
require 'hyrax/specs/shared_specs/factories/users'
require 'hyrax/specs/capybara'
require 'rspec/active_model/mocks'
require 'database_cleaner'

require 'valkyrie'
Valkyrie::MetadataAdapter.register(Valkyrie::Persistence::Memory::MetadataAdapter.new, :test_adapter)
Valkyrie::StorageAdapter.register(Valkyrie::Storage::Memory.new, :memory)

require 'factory_bot'
FactoryBot.register_strategy(:valkyrie_create, ValkyrieCreateStrategy)
FactoryBot.register_strategy(:json, JsonStrategy)
FactoryBot.find_definitions

query_registration_target =
  Valkyrie::MetadataAdapter.find(:test_adapter).query_service.custom_queries
custom_queries = [Hyrax::CustomQueries::Navigators::CollectionMembers,
                  Hyrax::CustomQueries::Navigators::ChildFilesetsNavigator,
                  Hyrax::CustomQueries::Navigators::ChildWorksNavigator,
                  Hyrax::CustomQueries::FindAccessControl,
                  Hyrax::CustomQueries::FindCollectionsByType,
                  Hyrax::CustomQueries::FindManyByAlternateIds,
                  Hyrax::CustomQueries::FindIdsByModel,
                  Hyrax::CustomQueries::FindFileMetadata,
                  Hyrax::CustomQueries::Navigators::FindFiles,
                  SelfDeposit::CustomQueries::FindPublicationByDeduplicationKey,
                  SelfDeposit::CustomQueries::FindBySourceIdentifier]
custom_queries.each do |handler|
  query_registration_target.register_query_handler(handler)
end

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

def database_exists?
  ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError
  false
else
  true
end

begin
  unless database_exists? && !ENV['CI']
    db_config = ActiveRecord::Base.configurations[ENV['RAILS_ENV']]
    ActiveRecord::Tasks::DatabaseTasks.create(db_config)
    ActiveRecord::Migrator.migrations_paths = [Pathname.new(ENV['RAILS_ROOT']).join('db', 'migrate').to_s]
    ActiveRecord::Tasks::DatabaseTasks.migrate
    ActiveRecord::Base.descendants.each(&:reset_column_information)
  end
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.fixture_path = Rails.root.join('spec', 'fixtures').to_s
  config.use_transactional_fixtures = true
  # config.use_active_record = false
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include Devise::Test::ControllerHelpers, type: :view

  # The following behaviors are copied from Hyrax v5.0.1's spec_helper.rb
  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)
    User.group_service = TestHydraGroupService.new
  end

  config.after do
    DatabaseCleaner.clean
    User.group_service.clear
  end

  config.before do |example|
    if example.metadata[:type] == :feature && Capybara.current_driver != :rack_test
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end

    # using :workflow is preferable to :clean_repo, use the former if possible
    # It's important that this comes after DatabaseCleaner.start
    ensure_deposit_available_for(user) if example.metadata[:workflow] && defined?(user)
  end

  config.prepend_before(:example, :storage_adapter) do |example|
    adapter_name = example.metadata[:storage_adapter]

    allow(Hyrax)
      .to receive(:storage_adapter)
      .and_return(Valkyrie::StorageAdapter.find(adapter_name))
  end

  config.prepend_before(:example, :valkyrie_adapter) do |example|
    adapter_name = example.metadata[:valkyrie_adapter]

    if adapter_name == :wings_adapter
      skip("Don't test Wings when it is disabled") if Hyrax.config.disable_wings
    else
      allow(Hyrax.config).to receive(:disable_wings).and_return(true)
      hide_const("Wings") # disable_wings=true removes the Wings constant
    end

    allow(Hyrax)
      .to receive(:metadata_adapter)
      .and_return(Valkyrie::MetadataAdapter.find(adapter_name))
  end
end
