ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

require "rspec/rails"

ActiveRecord::Base.establish_connection(:benchmark)

Dir[Rails.root.join("spec/benchmarks/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.expose_dsl_globally = false

  config.infer_spec_type_from_file_location!
  config.example_status_persistence_file_path = "spec/examples.txt"

  config.use_transactional_fixtures = true
  config.include BenchmarkHelpers
end
