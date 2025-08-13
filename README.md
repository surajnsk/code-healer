# CodeHealer 🏥

**AI-Powered Code Healing and Self-Repair System for Ruby Applications**

[![Gem Version](https://badge.fury.io/rb/code_healer.svg)](https://badge.fury.io/rb/code_healer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

CodeHealer automatically detects runtime errors in your Ruby/Rails application and uses AI to generate intelligent, context-aware fixes. It's like having a senior developer on call 24/7 to fix your bugs!

## ✨ Features

- **🚨 Automatic Error Detection** - Catches runtime errors in real-time
- **🤖 AI-Powered Fix Generation** - Uses OpenAI GPT models for intelligent code fixes
- **💼 Business Context Awareness** - Incorporates your business rules and domain knowledge
- **🔄 Automatic Code Patching** - Applies fixes directly to your source code
- **📝 Git Integration** - Creates commits and pull requests for all fixes
- **⚡ Background Processing** - Uses Sidekiq for non-blocking error resolution
- **🔧 Multiple Healing Strategies** - API-based, Claude Code Terminal, or hybrid approaches

## Dependencies

CodeHealer requires the following gems:

- **Rails** (>= 6.0.0) - Web framework integration
- **Sidekiq** (>= 6.0.0) - Background job processing
- **Redis** (>= 4.0.0) - Sidekiq backend
- **Octokit** (>= 4.0.0) - GitHub API integration
- **Git** (>= 1.0.0) - Git operations
- **OpenAI** (>= 0.16.0) - AI-powered code generation

## Installation

### 🚀 Quick Start with Interactive Setup (Recommended)

The easiest way to get started is using our **interactive bash script** that guides you through the entire setup process:

```bash
# Install the gem
gem install code_healer

# Run the interactive setup in your Rails app directory
code_healer-setup
```

The interactive setup script will:
- ✅ **Automatically add** CodeHealer to your Gemfile
- 🔑 **Securely collect** your OpenAI API key and GitHub token
- 📝 **Generate** all necessary configuration files
- 💼 **Set up** business context and rules
- 📦 **Install** all required dependencies
- 🎯 **Configure** Git operations and PR creation
- ⚙️ **Customize** healing strategies for your project
- 📚 **Create sample markdown files** for business context
- 🔧 **Set up directory structure** for documentation

### 📋 Manual Installation

If you prefer manual setup:

```bash
# Add to your Gemfile
gem 'code_healer'

# Install dependencies
bundle install
```

### 🔑 Environment Variables

CodeHealer requires several environment variables to function properly:

```bash
# Required for AI-powered code generation
OPENAI_API_KEY=your_openai_api_key_here

# Required for GitHub integration (PR creation, etc.)
GITHUB_TOKEN=your_github_personal_access_token
GITHUB_REPOSITORY=username/repository_name

# Optional: Redis URL for Sidekiq
REDIS_URL=redis://localhost:6379/0
```

**Loading Environment Variables:**

You have several options for loading these variables:

1. **Using dotenv-rails (Recommended):**
   ```ruby
   # In your Gemfile
   gem 'dotenv-rails'
   ```

2. **Manual export in shell:**
   ```bash
   export OPENAI_API_KEY=your_key
   export GITHUB_TOKEN=your_token
   export GITHUB_REPOSITORY=username/repo
   ```

3. **Load directly in application.rb:**
   ```ruby
   # In config/application.rb
   load '.env' if File.exist?('.env')
   ```

## ⚙️ Configuration

### 🔧 Configuration File

The setup script automatically creates `config/code_healer.yml`, or you can create it manually. Here's a comprehensive overview of all available configuration options:

```yaml
---
# CodeHealer Configuration
enabled: true  # Master switch to enable/disable the entire system

# 🎯 Class Control
allowed_classes:
  - User          # Classes that are allowed to evolve
  - Order         # Add your model classes here
  - PaymentProcessor
  - Api::UserController  # Controllers are also supported

excluded_classes:
  - ApplicationController  # Classes that should NEVER evolve
  - ApplicationRecord      # Core Rails classes
  - ApplicationJob
  - ApplicationMailer

# 🚨 Error Type Filtering
allowed_error_types:
  - ArgumentError      # Invalid arguments passed to methods
  - NameError          # Undefined variables or methods
  - NoMethodError      # Method doesn't exist on object
  - TypeError          # Wrong type of object
  - ValidationError    # Custom validation errors

# 🤖 Evolution Strategy
evolution_strategy:
  method: "api"                    # Options: "api", "claude_code_terminal", "hybrid"
  fallback_to_api: true            # If Claude Code fails, fall back to API

# 🧠 Claude Code Terminal (Local AI Agent)
claude_code:
  enabled: true                    # Enable Claude Code integration
  timeout: 300                     # 5 minutes timeout for AI responses
  max_file_changes: 10             # Maximum files Claude can modify
  include_tests: true              # Include test files in analysis
  command_template: "claude --print '{prompt}' --output-format text --permission-mode acceptEdits --allowedTools Edit"
  business_context_sources:        # Sources for business context
    - "config/business_rules.yml"
    - "docs/business_logic.md"
    - "spec/business_context_specs.rb"

# 💼 Business Context & Domain Knowledge
business_context:
  enabled: true                    # Enable business context integration
  
  User:                           # Class-specific business rules
    domain: "User Management"
    key_rules:
      - "Email must be unique and valid"
      - "Password must meet security requirements"
      - "User data must be validated"
    validation_patterns:
      - "Email format validation"
      - "Password strength requirements"
      - "Data integrity checks"
  
  Order:                          # Another class example
    domain: "E-commerce Order Processing"
    key_rules:
      - "Orders must have valid customer information"
      - "Payment validation is required"
      - "Inventory must be checked before processing"

# 🌐 OpenAI API Configuration
api:
  provider: "openai"              # AI provider (currently OpenAI)
  model: "gpt-4"                  # AI model to use
  max_tokens: 2000                # Maximum tokens in response
  temperature: 0.1                # Creativity vs. consistency (0.0 = deterministic, 1.0 = creative)

# 📝 Git Operations
git:
  auto_commit: true               # Automatically commit fixes
  auto_push: true                 # Push to remote repository
  branch_prefix: "evolve"         # Branch naming: evolve/classname-methodname-timestamp
  commit_message_template: 'Fix {class_name}##{method_name}: {error_type}'
  pr_target_branch: "main"        # Target branch for pull requests

# 🔀 Pull Request Configuration
pull_request:
  enabled: true                   # Enable automatic PR creation
  auto_create: true               # Create PRs automatically
  title_template: 'Fix {class_name}##{method_name}: Handle {error_type}'
  labels:                         # Labels to add to PRs
    - "auto-fix"
    - "self-evolving"
    - "bug-fix"

# ⚡ Sidekiq Background Processing
sidekiq:
  queue: "evolution"              # Queue name for healing jobs
  retry: 3                        # Number of retry attempts
  backtrace: true                 # Include backtraces in job data
```

### 🔑 Environment Variables

Create a `.env` file in your Rails app root:

```bash
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# GitHub Configuration  
GITHUB_TOKEN=your_github_token_here
GITHUB_REPOSITORY=username/repo

# Optional: Redis Configuration
REDIS_URL=redis://localhost:6379/0
```

## 🏥 How It Works

1. **Error Detection**: CodeHealer catches runtime errors using Rails error reporting
2. **Context Analysis**: Analyzes the error with business context and codebase information
3. **AI Fix Generation**: Uses OpenAI to generate intelligent, context-aware fixes
4. **Code Patching**: Automatically applies fixes to your source files
5. **Git Operations**: Creates commits and optionally pushes changes
6. **Class Reloading**: Reloads patched classes to apply fixes immediately

## 📖 Usage Examples

### Basic Usage

Once configured, CodeHealer works automatically! Just run your Rails app:

```bash
# Start your Rails server
rails s

# Start Sidekiq for background processing
bundle exec sidekiq
```

### Testing the Healing

Create a model with intentional errors to test:

```ruby
# app/models/broken_calculator.rb
class BrokenCalculator < ApplicationRecord
  def divide(a, b)
    a / b  # This will cause ZeroDivisionError when b = 0
  end
end
```

When you hit an endpoint that triggers this error, CodeHealer will:
1. Catch the error automatically
2. Generate a fix using AI
3. Apply the fix to your code
4. Create a Git commit
5. Reload the class

### Viewing Healing Results

Check your Sidekiq dashboard at `http://localhost:3000/sidekiq` to see healing jobs in action.

## 🔧 Advanced Configuration

### 🎯 Interactive Setup Script

The `code_healer-setup` script provides an interactive, guided setup experience:

```bash
$ code_healer-setup

🏥 Welcome to CodeHealer Setup!
================================

This interactive setup will configure CodeHealer for your Rails application.

📋 What we'll set up:
- OpenAI API configuration
- GitHub integration
- Business context rules
- Git operations
- Healing strategies
- Sidekiq configuration

🔑 Step 1: OpenAI Configuration
Enter your OpenAI API key: ****************
✅ OpenAI API key configured successfully!

🔗 Step 2: GitHub Integration
Enter your GitHub personal access token: ****************
Enter your GitHub repository (username/repo): deepan-g2/myapp
✅ GitHub integration configured successfully!

💼 Step 3: Business Context
Would you like to set up business context rules? (y/n): y
Enter business domain for User class: User Management
Enter key business rules (comma-separated): Email validation, Password security, Data integrity
✅ Business context configured successfully!

⚙️ Step 4: Healing Strategy
Choose evolution method:
1. API (OpenAI) - Cloud-based, reliable
2. Claude Code Terminal - Local AI agent, full codebase access
3. Hybrid - Best of both worlds
Enter choice (1-3): 2
✅ Claude Code Terminal strategy selected!

📝 Step 5: Git Configuration
Enter branch prefix for fixes: evolve
Enter target branch for PRs: main
✅ Git configuration completed!

🎉 Setup complete! CodeHealer is now configured for your application.
```

### 💼 Business Context Integration

CodeHealer can read business context from **Markdown (.md) files** to provide domain-specific knowledge for better AI fixes. These files help the AI understand your business rules, validation patterns, and domain logic.

#### 📁 Creating Business Context Files

Create markdown files in your project to define business rules:

**`docs/business_rules.md`** - General business rules:
```markdown
# Business Rules & Standards

## Error Handling Principles
- All errors should be logged for audit purposes
- User-facing errors should be user-friendly and actionable
- Critical errors should trigger immediate alerts
- Security errors should never expose sensitive information

## Data Validation Standards
- All user inputs must be validated before processing
- Business rules must be enforced at the model level
- Invalid data should be rejected with clear, helpful error messages
- Data integrity must be maintained across all operations

## Security Guidelines
- Never log sensitive information (passwords, tokens, PII)
- Input sanitization is mandatory for all user-provided data
- Rate limiting should be applied to prevent abuse
- Authentication must be verified for all protected operations
```

**`docs/user_management.md`** - Domain-specific rules:
```markdown
# User Management Domain

## User Registration
- Email addresses must be unique across the system
- Password strength: minimum 8 characters, mixed case, numbers
- Email verification is required before account activation
- Username must be alphanumeric, 3-20 characters

## User Authentication
- Failed login attempts are limited to 5 per hour
- Password reset tokens expire after 1 hour
- Session timeout after 24 hours of inactivity
- Multi-factor authentication for admin accounts

## Data Privacy
- User data is encrypted at rest
- GDPR compliance for EU users
- Right to data deletion must be honored
- Audit trail for all data modifications
```

**`docs/order_processing.md`** - Another domain example:
```markdown
# Order Processing Domain

## Order Validation
- Customer information must be complete and verified
- Payment method must be valid and authorized
- Inventory must be available before order confirmation
- Shipping address must be deliverable

## Business Rules
- Orders cannot be cancelled after shipping
- Refunds processed within 30 days
- Bulk orders get 10% discount
- Free shipping for orders over $50

## Error Handling
- Insufficient inventory: suggest alternatives
- Payment failure: retry up to 3 times
- Invalid address: prompt for correction
- System errors: queue for manual review
```

#### 🔧 Configuration for Markdown Files

Update your `config/code_healer.yml` to include these files:

```yaml
business_context:
  enabled: true
  
  # Sources for business context (markdown files)
  sources:
    - "docs/business_rules.md"
    - "docs/user_management.md"
    - "docs/order_processing.md"
    - "README.md"  # Project documentation
    - "docs/API.md"  # API documentation

claude_code:
  business_context_sources:
    - "docs/business_rules.md"
    - "docs/user_management.md"
    - "docs/order_processing.md"
    - "config/business_rules.yml"  # YAML format also supported
```

#### 📝 Markdown File Best Practices

1. **Use clear headings** (`#`, `##`, `###`) for structure
2. **Include specific examples** of valid/invalid data
3. **Document error scenarios** and expected responses
4. **Keep it concise** but comprehensive
5. **Update regularly** as business rules evolve
6. **Use consistent formatting** for better AI parsing

#### 🎯 How AI Uses Markdown Context

When CodeHealer encounters an error, it:
1. **Reads relevant markdown files** based on the error context
2. **Extracts business rules** that apply to the failing code
3. **Generates fixes** that respect your business logic
4. **Ensures compliance** with your domain standards
5. **Maintains consistency** with existing code patterns

### 🤖 Custom Healing Strategies

#### API Strategy (OpenAI)
```yaml
evolution_strategy:
  method: "api"
  fallback_to_api: false  # No fallback needed

api:
  provider: "openai"
  model: "gpt-4"
  max_tokens: 3000        # Increase for complex fixes
  temperature: 0.05       # More deterministic
```

#### Claude Code Terminal Strategy
```yaml
evolution_strategy:
  method: "claude_code_terminal"
  fallback_to_api: true   # Fallback if Claude fails

claude_code:
  enabled: true
  timeout: 600             # 10 minutes for complex fixes
  max_file_changes: 15     # Allow more file modifications
  include_tests: true      # Include test files in analysis
```

#### Hybrid Strategy
```yaml
evolution_strategy:
  method: "hybrid"
  fallback_to_api: true

# Claude Code for local development
claude_code:
  enabled: true
  timeout: 300

# OpenAI API for production/fallback
api:
  provider: "openai"
  model: "gpt-4"
  max_tokens: 2000
```

## 🛠️ Development

### Building the Gem

```bash
git clone https://github.com/deepan-g2/code-healer.git
cd code-healer
bundle install
gem build code_healer.gemspec
```

### Running Tests

```bash
bundle exec rspec
```

## ⚠️ Configuration Best Practices

### 🎯 Class Selection
- **Start conservative**: Only allow classes you're comfortable with auto-evolving
- **Exclude core classes**: Never allow `ApplicationController`, `ApplicationRecord`, etc.
- **Test thoroughly**: Verify allowed classes work as expected before production

### 🔐 Security Considerations
- **API keys**: Store in environment variables, never in code
- **GitHub tokens**: Use minimal required permissions (`repo`, `workflow`)
- **Business context**: Be careful with sensitive business rules in markdown files

### 🚀 Performance Optimization
- **Claude Code timeout**: Set appropriate timeouts (300-600 seconds)
- **Max file changes**: Limit to prevent excessive modifications
- **Sidekiq queue**: Use dedicated queue for evolution jobs

### 🔧 Troubleshooting Common Issues

#### "No backtrace available" Error
```yaml
# Ensure backtrace is enabled in Sidekiq config
sidekiq:
  backtrace: true
```

#### Pull Request Creation Fails
```yaml
# Verify GitHub token has correct permissions
# Check target branch exists
git:
  pr_target_branch: "main"  # Must exist in remote
```

#### Claude Code Not Responding
```yaml
# Increase timeout and verify command template
claude_code:
  timeout: 600
  command_template: "claude --print '{prompt}' --output-format text"
```

#### Business Context Not Loading
```yaml
# Ensure markdown files exist and are readable
business_context:
  enabled: true
  # Check file paths are correct
```

## 📚 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Configuration Reference](docs/CONFIGURATION.md)
- [API Documentation](docs/API.md)
- [Examples](examples/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## 🙏 Acknowledgments

- Built with ❤️ by the CodeHealer Team
- Powered by OpenAI's GPT models
- Inspired by the need for self-healing applications

## 📞 Support

- 📧 Email: support@code-healer.com
- 🐛 Issues: [GitHub Issues](https://github.com/deepan-g2/code-healer/issues)
- 📖 Documentation: [docs.code-healer.com](https://docs.code-healer.com)

---

**CodeHealer** - Because your code deserves to heal itself! 🏥✨
