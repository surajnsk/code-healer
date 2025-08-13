# frozen_string_literal: true

require "bundler/setup"
require "code_healer"
require "rspec"

# Configure RSpec
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Mock external services
  config.before(:each) do
    # Mock OpenAI API calls
    allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(
      double(
        choices: [
          double(
            message: double(
              content: "def calculate_discount(amount, percentage)\n  return 0 if amount.nil? || percentage.nil?\n  amount * (percentage / 100.0)\nend"
            )
          )
        ]
      )
    )

    # Mock GitHub API calls
    allow_any_instance_of(Octokit::Client).to receive(:create_pull_request).and_return(
      double(
        html_url: "https://github.com/user/repo/pull/123",
        number: 123,
        title: "Test PR"
      )
    )

    # Mock Git operations
    allow_any_instance_of(Git::Base).to receive(:checkout).and_return(true)
    allow_any_instance_of(Git::Base).to receive(:add).and_return(true)
    allow_any_instance_of(Git::Base).to receive(:commit).and_return(true)
    allow_any_instance_of(Git::Base).to receive(:push).and_return(true)
  end
end

# Helper methods for testing
module TestHelpers
  def create_temp_config(config_hash)
    config_file = Tempfile.new(['self_evolution', '.yml'])
    config_file.write(config_hash.to_yaml)
    config_file.close
    config_file.path
  end

  def cleanup_temp_files
    # Cleanup temporary files if needed
  end
end

RSpec.configure do |config|
  config.include TestHelpers
end
