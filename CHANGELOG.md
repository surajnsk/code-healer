# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial gem release
- AI-powered error analysis and code generation
- Multiple healing strategies (API, Claude Code, Hybrid)
- Business context awareness and integration
- Automated Git operations and PR creation
- Background job processing with Sidekiq
- Comprehensive YAML configuration
- Business requirements integration from markdown files
- Rails integration via Railtie

### Changed
- Converted from standalone Rails application to gem
- Refactored for modular architecture
- Improved error handling and logging
- Renamed from CodeHealer to CodeHealer

### Deprecated
- None

### Removed
- None

### Fixed
- Business context loading from markdown files
- Template placeholder substitution in PR creation
- Sidekiq job serialization issues

### Security
- Class restriction system for security
- Environment variable support for sensitive data
- Business rule validation

## [0.1.0] - 2025-01-13

### Added
- Initial release of CodeHealer gem
- Core healing engine
- OpenAI API integration
- Claude Code terminal integration
- Business context management
- Git operations automation
- Sidekiq background processing
- Comprehensive documentation
- Example configurations
- Test suite setup

---

## Version History

- **0.1.0**: Initial gem release with core functionality
- **Unreleased**: Future improvements and features

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.
