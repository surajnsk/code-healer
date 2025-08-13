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

### 1. Interactive Installation (Recommended)

The easiest way to get started is using our interactive setup script:

```bash
# Install the gem
gem install code_healer

# Run the interactive setup in your Rails app directory
code_healer-setup
```

The setup script will:
- ✅ Add CodeHealer to your Gemfile
- 🔑 Collect your OpenAI API key and GitHub token
- 📝 Create configuration files
- 💼 Set up business context
- 📦 Install dependencies

### 2. Manual Installation

```bash
# Add to your Gemfile
gem 'code_healer'

# Install dependencies
bundle install
```

### 3. Environment Variables

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

### Environment Variables

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

### Configuration File

The setup script creates `config/code_healer.yml` automatically, or you can create it manually:

```yaml
enabled: true

# Allowed classes for healing
allowed_classes:
  - User
  - Order
  - PaymentProcessor

# Evolution strategy
evolution_strategy:
  method: api  # Options: api, claude_code_terminal, hybrid
  fallback_to_api: true

# OpenAI API configuration
api:
  provider: openai
  model: gpt-4
  max_tokens: 2000
  temperature: 0.1

# Git operations
git:
  auto_commit: true
  auto_push: true
  branch_prefix: "heal"
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

### Business Context

Create `docs/business_rules.md` to provide domain-specific context:

```markdown
# Business Rules

## Error Handling
- All errors should be logged for audit purposes
- User-facing errors should be user-friendly
- Critical errors should trigger alerts

## Data Validation
- All user inputs must be validated
- Business rules must be enforced
- Invalid data should be rejected with clear messages
```

### Custom Healing Strategies

```yaml
# Use Claude Code Terminal for local development
evolution_strategy:
  method: claude_code_terminal
  fallback_to_api: true

claude_code:
  enabled: true
  command_template: "claude --print '{prompt}' --output-format text"
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
