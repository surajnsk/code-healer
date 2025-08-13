# Basic Usage Example
# This example shows how to use CodeHealer in a simple Rails application

# 1. Add to Gemfile
puts "Add to your Gemfile:"
puts "gem 'code_healer'"
puts

# 2. Configuration
puts "Create config/code_healer.yml:"
puts <<~YAML
---
enabled: true

allowed_classes:
  - User
  - Order
  - PaymentProcessor

evolution_strategy:
  method: "api"

business_context:
  enabled: true
  User:
    domain: "User Management"
    key_rules:
      - "Email must be unique and valid"
      - "Password must meet security requirements"
YAML
puts

# 3. Model Example
puts "Example model (app/models/user.rb):"
puts <<~RUBY
class User < ApplicationRecord
  def calculate_discount(amount, percentage)
    # This will trigger evolution if an error occurs
    amount * (percentage / 100.0)
  end
  
  def validate_payment(card_number, expiry_date)
    # Another method that can evolve
    card_number.length == 16 && expiry_date > Date.current
  end
end
RUBY
puts

# 4. Controller Example
puts "Example controller (app/controllers/api/users_controller.rb):"
puts <<~RUBY
class Api::UsersController < ApplicationController
  def calculate_discount
    user = User.find(params[:id])
    discount = user.calculate_discount(
      params[:amount].to_f, 
      params[:percentage].to_f
    )
    
    render json: { discount: discount }
  rescue => e
    # CodeHealer will catch this error and fix it
    render json: { error: e.message }, status: 500
  end
end
RUBY
puts

# 5. Routes
puts "Add to config/routes.rb:"
puts <<~RUBY
Rails.application.routes.draw do
  namespace :api do
    resources :users do
      member do
        post :calculate_discount
      end
    end
  end
end
RUBY
puts

# 6. Test the Evolution
puts "Test the evolution:"
puts <<~BASH
# Start your Rails server
rails server

# In another terminal, trigger an error
curl -X POST http://localhost:3000/api/users/1/calculate_discount \\
  -H "Content-Type: application/json" \\
  -d '{"amount": 100, "percentage": nil}'
BASH
puts

# 7. Watch the Evolution
puts "Watch the healing in action:"
puts <<~BASH
# Check Rails logs
tail -f log/development.log

# Check Sidekiq (if using background jobs)
tail -f log/sidekiq.log

# Monitor Sidekiq Web UI
open http://localhost:3000/sidekiq
BASH
puts

# 8. Business Requirements
puts "Create business_requirements/user_management.md:"
puts <<~MARKDOWN
# User Management Business Rules

## Authentication
- Users must have valid email addresses
- Passwords must be at least 8 characters
- Failed login attempts should be logged

## Discount Calculation
- Discount cannot exceed 50% of total amount
- Negative percentages are not allowed
- Zero amounts should return zero discount

## Data Validation
- All user input must be sanitized
- Email uniqueness is enforced at database level
MARKDOWN
puts

# 9. Environment Variables
puts "Set environment variables (.env):"
puts <<~ENV
OPENAI_API_KEY=your_openai_api_key_here
GITHUB_TOKEN=your_github_token_here
ENV
puts

# 10. Sidekiq Configuration
puts "Create config/sidekiq.yml:"
puts <<~YAML
:concurrency: 5
:queues:
  - [evolution, 2]
  - [default, 1]
YAML
puts

puts "🎉 Your CodeHealer application is ready!"
puts
puts "Next steps:"
puts "1. Run 'bundle install'"
puts "2. Start Redis: 'redis-server'"
puts "3. Start Sidekiq: 'bundle exec sidekiq'"
puts "4. Start Rails: 'rails server'"
puts "5. Test with the curl command above"
puts
puts "Watch the magic happen! 🚀"
