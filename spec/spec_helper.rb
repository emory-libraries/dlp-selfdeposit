# frozen_string_literal: true
require 'factory_bot'
require 'hyrax/specs/shared_specs/factories/strategies/json_strategy'
require 'hyrax/specs/shared_specs/factories/strategies/valkyrie_resource'
require 'coveralls'

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
    User.group_service = TestHydraGroupService.new
  end

  config.after :suite do
    User.group_service.clear
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
      skip("Don't test Wings when it is dasabled") if Hyrax.config.disable_wings
    else
      allow(Hyrax.config).to receive(:disable_wings).and_return(true)
      hide_const("Wings") # disable_wings=true removes the Wings constant
    end

    allow(Hyrax)
      .to receive(:metadata_adapter)
      .and_return(Valkyrie::MetadataAdapter.find(adapter_name))
  end
end
