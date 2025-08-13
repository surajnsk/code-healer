# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

# Custom tasks for CodeHealer gem
namespace :code_healer do
  desc "Run all tests"
  task test: :spec

  desc "Check code quality with RuboCop"
  task :rubocop do
    system("bundle exec rubocop")
  end

  desc "Generate documentation with YARD"
  task :docs do
    system("bundle exec yard doc")
  end

  desc "Build the gem"
  task :build do
    system("gem build code_healer.gemspec")
  end

  desc "Install the gem locally"
  task :install => :build do
    system("gem install code_healer-*.gem")
  end

  desc "Push to RubyGems"
  task :release => :build do
    system("gem push self_evolving-*.gem")
  end

  desc "Clean build artifacts"
  task :clean do
    FileUtils.rm_f(Dir.glob("code_healer-*.gem"))
    FileUtils.rm_rf("doc") if Dir.exist?("doc")
    FileUtils.rm_rf("coverage") if Dir.exist?("coverage")
  end

  desc "Setup development environment"
  task :setup do
    puts "Setting up CodeHealer development environment..."
    
    # Install dependencies
    system("bundle install")
    
    # Create necessary directories
    FileUtils.mkdir_p("tmp")
    FileUtils.mkdir_p("log")
    
    puts "✅ Development environment setup complete!"
  end

  desc "Run example"
  task :example do
    puts "Running basic usage example..."
    system("ruby examples/basic_usage.rb")
  end
end

# Add RuboCop to default task
task default: [:spec, :rubocop]
