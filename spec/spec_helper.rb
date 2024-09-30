# frozen_string_literal: true
require 'factory_bot'
require 'hyrax/specs/shared_specs/factories/strategies/json_strategy'
require 'hyrax/specs/shared_specs/factories/strategies/valkyrie_resource'
require 'hyrax/specs/shared_specs/factories/users'
require 'coveralls'
require 'rspec/active_model/mocks'
require 'database_cleaner'

ENV['RAILS_ENV'] = 'test'
ENV['DATABASE_URL'] = ENV['DATABASE_TEST_URL'] if ENV['DATABASE_TEST_URL']

db_config = ActiveRecord::Base.configurations[ENV['RAILS_ENV']]
ActiveRecord::Tasks::DatabaseTasks.create(db_config)
ActiveRecord::Migrator.migrations_paths = [Pathname.new(ENV['RAILS_ROOT']).join('db', 'migrate').to_s]
ActiveRecord::Tasks::DatabaseTasks.migrate
ActiveRecord::Base.descendants.each(&:reset_column_information)
ActiveRecord::Migration.maintain_test_schema!

Coveralls.wear!('rails')

FactoryBot.register_strategy(:valkyrie_create, ValkyrieCreateStrategy)
FactoryBot.register_strategy(:json, JsonStrategy)
FactoryBot.find_definitions

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

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
