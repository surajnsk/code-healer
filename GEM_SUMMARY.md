# CodeHealer Gem - Complete Package 🏥

## 📦 What You Get

This gem package contains everything needed to integrate AI-powered code healing and self-repair into any Ruby application.

## 🏗️ Gem Structure

```
code_healer_gem/
├── lib/
│   ├── code_healer.rb                # Main gem file with Railtie
│   ├── code_healer/
│   │   ├── version.rb                # Gem version
│   │   ├── config_manager.rb         # Configuration management
│   │   ├── core.rb                   # Core healing engine
│   │   ├── simple_healer.rb          # Basic healing logic
│   │   ├── claude_code_healing_handler.rb  # Claude Code integration
│   │   ├── business_context_manager.rb      # Business rules management
│   │   ├── mcp_server.rb             # MCP server for AI integration
│   │   ├── mcp_tools.rb              # MCP tools and utilities
│   │   ├── mcp_prompts.rb            # AI prompt templates
│   │   ├── pull_request_creator.rb   # Git operations automation
│   │   ├── error_handler.rb          # Error handling utilities
│   │   ├── usage_analyzer.rb         # Usage analytics
│   │   └── healing_job.rb            # Sidekiq background job
├── config/
│   └── code_healer.yml.example       # Example configuration
├── examples/
│   └── basic_usage.rb                # Basic usage example
├── docs/
│   └── INSTALLATION.md               # Detailed installation guide
├── spec/                             # Test suite
├── code_healer.gemspec               # Gem specification
├── Gemfile                           # Development dependencies
├── Rakefile                          # Build and development tasks
├── README.md                         # Comprehensive documentation
├── CHANGELOG.md                      # Version history
└── LICENSE.txt                       # MIT license
```

## 🚀 Quick Start for Users

### 1. Add to Gemfile
```ruby
gem 'self_evolving'
```

### 2. Install
```bash
bundle install
```

### 3. Configure
```bash
cp config/self_evolution.yml.example config/self_evolution.yml
# Edit the configuration file
```

### 4. Use
```ruby
# Your models will automatically evolve when errors occur
class User < ApplicationRecord
  def calculate_discount(amount, percentage)
    amount * (percentage / 100.0)  # Will auto-fix if error occurs
  end
end
```

## 🔧 Key Features

### 🤖 **Multiple AI Integration Options**
- **OpenAI API**: Cloud-based, production-ready
- **Claude Code Terminal**: Local, offline, full codebase access
- **Hybrid**: Best of both worlds with fallback

### 🎯 **Business Context Awareness**
- YAML configuration for business rules
- Markdown file integration for requirements
- Domain-specific validation patterns

### 🔄 **Automated Evolution**
- Error detection and analysis
- AI-powered fix generation
- Automatic code application
- Class reloading for immediate testing

### 📝 **Git Operations Automation**
- Feature branch creation
- Automatic commits with descriptive messages
- Pull request creation
- Configurable target branches

### ⚡ **Background Processing**
- Sidekiq integration for non-blocking evolution
- Queue management and retry logic
- Evolution job monitoring

## 📋 Configuration Options

### Core Settings
```yaml
enabled: true
allowed_classes: [User, Order, PaymentProcessor]
excluded_classes: [ApplicationController, ApplicationRecord]
allowed_error_types: [ArgumentError, TypeError, NoMethodError]
```

### Evolution Strategy
```yaml
evolution_strategy:
  method: "api"  # or "claude_code_terminal" or "hybrid"
  fallback_to_api: true
```

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

## 🎨 Customization

### Custom Error Handlers
```ruby
# config/initializers/self_evolution.rb
Rails.application.config.after_initialize do
  CodeHealer::Core.configure do |config|
    config.custom_error_handler = ->(error, context) {
      # Custom error handling logic
    }
  end
end
```

### Custom Evolution Jobs
```ruby
# app/jobs/custom_evolution_job.rb
class CustomEvolutionJob < CodeHealer::EvolutionJob
  sidekiq_options queue: 'high_priority_evolution'
  
  def perform(error_data, class_name, method_name, file_path)
    # Custom evolution logic
    super
  end
end
```

### Business Context Sources
```yaml
claude_code:
  business_context_sources:
    - "config/business_rules.yml"
    - "docs/business_logic.md"
    - "spec/business_context_specs.rb"
    - "app/models/concerns/business_rules.rb"
```

## 🧪 Testing

### Run Tests
```bash
bundle exec rspec
```

### Test Configuration
```yaml
# config/self_evolution.yml (test environment)
test:
  enabled: false
  mock_ai_responses: true
  dry_run: true
```

### Mock Responses
```yaml
test:
  mock_response: |
    def calculate_discount(amount, percentage)
      return 0 if amount.nil? || percentage.nil?
      amount * (percentage / 100.0)
    end
```

## 📊 Monitoring

### Log Levels
- `INFO`: General evolution activities
- `WARN`: Potential issues or fallbacks
- `ERROR`: Evolution failures
- `DEBUG`: Detailed debugging information

### Metrics
```ruby
# Access evolution metrics
CodeHealer::UsageAnalyzer.get_evolution_stats
CodeHealer::UsageAnalyzer.get_business_rule_compliance
```

### Sidekiq Web UI
```ruby
# config/routes.rb
mount Sidekiq::Web => '/sidekiq'
```

## 🔒 Security

### API Keys
```yaml
api:
  provider: "openai"
  api_key: <%= ENV['OPENAI_API_KEY'] %>
```

### Class Restrictions
```yaml
allowed_classes:
  - User
  - Order
  # Never include ApplicationController, ApplicationRecord, etc.
```

### Business Rule Validation
```yaml
business_context:
  validate_rules: true
  strict_mode: true
```

## 🚨 Troubleshooting

### Common Issues
1. **Evolution not triggering**: Check class permissions and error types
2. **AI integration failing**: Verify API keys and network connectivity
3. **Git operations failing**: Check repository configuration and tokens
4. **Business context not loading**: Verify file paths and permissions

### Debug Mode
```yaml
logging:
  level: debug
  show_thinking_process: true
  verbose: true
```

## 📚 Documentation

- **README.md**: Comprehensive usage guide
- **docs/INSTALLATION.md**: Step-by-step installation
- **examples/basic_usage.rb**: Basic usage examples
- **CHANGELOG.md**: Version history and changes

## 🤝 Support

- 📧 **Email**: deepan@example.com
- 🐛 **Issues**: GitHub Issues
- 💬 **Discussions**: GitHub Discussions
- 📖 **Wiki**: GitHub Wiki

## 🎯 Use Cases

### Development
- Automatic bug fixes during development
- Code improvement suggestions
- Business rule enforcement

### Production
- Runtime error recovery
- Performance optimization
- Security vulnerability fixes

### Testing
- Test case generation
- Edge case handling
- Validation improvement

## 🚀 Getting Started

1. **Read the README.md** for comprehensive information
2. **Follow INSTALLATION.md** for setup steps
3. **Run examples/basic_usage.rb** to see it in action
4. **Customize config/self_evolution.yml** for your needs
5. **Start evolving your code!**

---

**Transform your Rails application into a self-improving, intelligent system today! 🚀**
