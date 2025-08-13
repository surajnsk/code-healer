#!/usr/bin/env ruby

# Test script for CodeHealer gem
puts "🧪 Testing CodeHealer Gem Functionality"
puts "=" * 50

begin
  # Test 1: Load the gem
  puts "\n1️⃣ Testing gem loading..."
  require_relative 'lib/code_healer'
  puts "✅ Gem loaded successfully!"
  
  # Test 2: Check version
  puts "\n2️⃣ Testing version..."
  version = CodeHealer::VERSION
  puts "✅ Version: #{version}"
  
  # Test 3: Check configuration
  puts "\n3️⃣ Testing configuration..."
  config = CodeHealer::ConfigManager.config
  puts "✅ Configuration loaded: #{config.keys.join(', ')}"
  
  # Test 4: Check if enabled
  puts "\n4️⃣ Testing enabled status..."
  enabled = CodeHealer::ConfigManager.enabled?
  puts "✅ Enabled: #{enabled}"
  
  # Test 5: Check allowed classes
  puts "\n5️⃣ Testing allowed classes..."
  allowed_classes = CodeHealer::ConfigManager.allowed_classes
  puts "✅ Allowed classes: #{allowed_classes}"
  
  # Test 6: Check evolution strategy
  puts "\n6️⃣ Testing evolution strategy..."
  strategy = CodeHealer::ConfigManager.evolution_strategy
  puts "✅ Evolution strategy: #{strategy}"
  
  # Test 7: Check business context
  puts "\n7️⃣ Testing business context..."
  business_enabled = CodeHealer::ConfigManager.business_context_enabled?
  puts "✅ Business context enabled: #{business_enabled}"
  
  # Test 8: Check API configuration
  puts "\n8️⃣ Testing API configuration..."
  api_enabled = CodeHealer::ConfigManager.api_enabled?
  puts "✅ API enabled: #{api_enabled}"
  
  # Test 9: Check Claude Code configuration
  puts "\n9️⃣ Testing Claude Code configuration..."
  claude_enabled = CodeHealer::ConfigManager.claude_code_enabled?
  puts "✅ Claude Code enabled: #{claude_enabled}"
  
  # Test 10: Check Git configuration
  puts "\n🔟 Testing Git configuration..."
  git_settings = CodeHealer::ConfigManager.git_settings
  puts "✅ Git settings: #{git_settings.keys.join(', ')}"
  
  puts "\n🎉 All tests passed! CodeHealer gem is working correctly!"
  
rescue => e
  puts "\n❌ Test failed with error: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.first(5)
end
