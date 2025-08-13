# Installation Guide 🚀

This guide will walk you through installing and setting up CodeHealer in your Ruby on Rails application.

## 📋 Prerequisites

Before installing CodeHealer, ensure you have:

- Ruby 2.7.0 or higher
- Rails 6.0.0 or higher
- Git repository initialized
- GitHub account (for pull request creation)
- OpenAI API key (for API-based evolution)
- Claude Code terminal (for local evolution)

## 🔧 Step-by-Step Installation

### 1. Add to Gemfile

Add the gem to your `Gemfile`:

```ruby
# Gemfile
source 'https://rubygems.org'

# ... other gems ...

# CodeHealer - AI-powered code healing and self-repair system
gem 'code_healer'

# Required dependencies (if not already present)
gem 'sidekiq', '>= 6.0.0'
gem 'redis', '>= 4.0.0'
```

### 2. Install Dependencies

Run bundle install:

```bash
bundle install
```

### 3. Copy Configuration

Copy the example configuration file:

```bash
cp config/code_healer.yml.example config/code_healer.yml
```

### 4. Configure CodeHealer

Edit `config/code_healer.yml` with your settings:

```yaml
---
enabled: true

# Classes that are allowed to evolve
allowed_classes:
  - User
  - Order
  - PaymentProcessor

# Evolution strategy
evolution_strategy:
  method: "api"  # or "claude_code_terminal" or "hybrid"

# API configuration
api:
  provider: "openai"
  model: "gpt-4"
  api_key: <%= ENV['OPENAI_API_KEY'] %>

# Business context
business_context:
  enabled: true
  User:
    domain: "User Management"
    key_rules:
      - "Email must be unique and valid"
```

### 5. Set Environment Variables

Create or update your `.env` file:

```bash
# .env
OPENAI_API_KEY=your_openai_api_key_here
GITHUB_TOKEN=your_github_token_here
```

**Important**: Never commit API keys to version control!

### 6. Setup Sidekiq (Recommended)

Create `config/sidekiq.yml`:

```yaml
:concurrency: 5
:queues:
  - [evolution, 2]
  - [default, 1]
```

Add to `config/routes.rb`:

```ruby
# config/routes.rb
require 'sidekiq/web'

Rails.application.routes.draw do
  # ... other routes ...
  
  # Sidekiq Web UI (optional, for monitoring)
  mount Sidekiq::Web => '/sidekiq'
end
```

### 7. Setup Redis

Ensure Redis is running:

```bash
# macOS with Homebrew
brew services start redis

# Ubuntu/Debian
sudo systemctl start redis

# Or run manually
redis-server
```

### 8. Business Requirements (Optional)

Create a `business_requirements/` directory in your project root:

```bash
mkdir business_requirements
```

Add markdown files with your business rules:

```markdown
# business_requirements/user_management.md
# User Management Business Rules

## Authentication
- Users must have valid email addresses
- Passwords must be at least 8 characters
- Failed login attempts should be logged

## Data Validation
- All user input must be sanitized
- Email uniqueness is enforced at database level
```

## 🚀 Quick Start Example

### 1. Create a Test Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  def calculate_discount(amount, percentage)
    # This will trigger evolution if an error occurs
    amount * (percentage / 100.0)
  end
end
```

### 2. Test Evolution

Start your Rails server and trigger an error:

```bash
rails server
```

In another terminal, trigger an error:

```bash
curl -X POST http://localhost:3000/api/users/calculate_discount \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "percentage": nil}'
```

### 3. Watch Evolution in Action

Check the logs to see CodeHealer in action:

```bash
tail -f log/development.log
```

## 🔍 Verification

### Check Installation

Verify CodeHealer is properly installed:

```ruby
# In Rails console
rails console

# Check if CodeHealer is loaded
CodeHealer::VERSION
# Should return the version number

# Check configuration
CodeHealer::ConfigManager.config
# Should return your configuration hash
```

### Check Sidekiq

Verify Sidekiq is working:

```bash
# Start Sidekiq
bundle exec sidekiq

# Check Sidekiq Web UI
open http://localhost:3000/sidekiq
```

### Check Business Context

Verify business context is loading:

```ruby
# In Rails console
CodeHealer::BusinessContextManager.get_context_for_error(
  ArgumentError.new("test"), 
  "User", 
  "calculate_discount"
)
```

## 🛠️ Configuration Options

### Core Settings

| Setting | Description | Default | Required |
|---------|-------------|---------|----------|
| `enabled` | Enable/disable CodeHealer | `true` | Yes |
| `allowed_classes` | Classes that can evolve | `[]` | Yes |
| `excluded_classes` | Classes that should never evolve | `[]` | No |
| `allowed_error_types` | Error types that trigger evolution | `[]` | No |

### Evolution Strategy

| Strategy | Description | Use Case |
|----------|-------------|----------|
| `api` | Use OpenAI API for fixes | Production, cloud-based |
| `claude_code_terminal` | Use local Claude Code agent | Development, offline |
| `hybrid` | Try Claude Code first, fallback to API | Best of both worlds |

### Business Context

```yaml
business_context:
  enabled: true
  
  User:
    domain: "User Management"
    key_rules:
      - "Email must be unique and valid"
    validation_patterns:
      - "Input validation for all parameters"
```

### Git Operations

```yaml
git:
  auto_commit: true
  auto_push: true
  branch_prefix: evolve
  pr_target_branch: main

pull_request:
  enabled: true
  auto_create: true
  labels: ["auto-fix", "self-evolving"]
```

## 🔒 Security Configuration

### API Keys

Store sensitive data in environment variables:

```yaml
# config/self_evolution.yml
api:
  provider: "openai"
  api_key: <%= ENV['OPENAI_API_KEY'] %>
  model: "gpt-4"
```

### Class Restrictions

Carefully configure which classes can evolve:

```yaml
allowed_classes:
  - User
  - Order
  - PaymentProcessor

excluded_classes:
  - ApplicationController
  - ApplicationRecord
  - ApplicationJob
  - ApplicationMailer
```

### Business Rule Validation

Enable business rule validation:

```yaml
business_context:
  enabled: true
  validate_rules: true
  strict_mode: true
```

## 🧪 Testing Configuration

### Test Environment

Disable evolution in test environment:

```yaml
# config/environments/test.rb
Rails.application.configure do
  # ... other config ...
  
  # Disable CodeHealer in tests
  config.self_evolving = {
    enabled: false,
    mock_ai_responses: true,
    dry_run: true
  }
end
```

### Mock Responses

Use mock responses for testing:

```yaml
# config/self_evolution.yml
test:
  enabled: false
  mock_ai_responses: true
  mock_response: "def calculate_discount(amount, percentage)\n  return 0 if amount.nil? || percentage.nil?\n  amount * (percentage / 100.0)\nend"
```

## 🚨 Troubleshooting

### Common Installation Issues

1. **Gem not found**
   ```bash
   bundle install
   bundle exec rails console
   ```

2. **Configuration not loading**
   - Check file path: `config/self_evolution.yml`
   - Verify YAML syntax
   - Check file permissions

3. **Sidekiq not working**
   ```bash
   # Check Redis
   redis-cli ping
   
   # Check Sidekiq
   bundle exec sidekiq -V
   ```

4. **Business context not loading**
   - Verify `business_requirements/` directory exists
   - Check markdown file syntax
   - Verify file permissions

### Debug Mode

Enable debug logging:

```yaml
# config/self_evolution.yml
logging:
  level: debug
  show_thinking_process: true
  verbose: true
```

### Log Files

Check relevant log files:

```bash
# Rails logs
tail -f log/development.log

# Sidekiq logs
tail -f log/sidekiq.log

# Redis logs
tail -f /var/log/redis/redis-server.log
```

## 📚 Next Steps

After successful installation:

1. **Read the [README](README.md)** for comprehensive usage information
2. **Check [Configuration](CONFIGURATION.md)** for advanced options
3. **Review [Examples](EXAMPLES.md)** for practical use cases
4. **Join [Discussions](https://github.com/deepan-g2/self-evolving/discussions)** for community support

## 🆘 Need Help?

- 📧 **Email**: deepan@example.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/deepan-g2/self-evolving/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/deepan-g2/self-evolving/discussions)
- 📖 **Wiki**: [GitHub Wiki](https://github.com/deepan-g2/self-evolving/wiki)

---

**Happy Evolving! 🚀**
