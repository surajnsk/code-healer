#!/usr/bin/env ruby

# Simple test script for CodeHealer gem (no Rails required)
puts "🧪 Testing CodeHealer Gem - Simple Version"
puts "=" * 50

begin
  # Test 1: Load the version file directly
  puts "\n1️⃣ Testing version loading..."
  require_relative 'lib/code_healer/version'
  version = CodeHealer::VERSION
  puts "✅ Version: #{version}"
  
  # Test 2: Load the config manager
  puts "\n2️⃣ Testing config manager..."
  require_relative 'lib/code_healer/config_manager'
  puts "✅ ConfigManager loaded successfully!"
  
  # Test 3: Test basic configuration
  puts "\n3️⃣ Testing basic configuration..."
  config = CodeHealer::ConfigManager.config
  puts "✅ Configuration loaded: #{config.keys.join(', ')}"
  
  # Test 4: Test enabled status
  puts "\n4️⃣ Testing enabled status..."
  enabled = CodeHealer::ConfigManager.enabled?
  puts "✅ Enabled: #{enabled}"
  
  # Test 5: Test allowed classes
  puts "\n5️⃣ Testing allowed classes..."
  allowed_classes = CodeHealer::ConfigManager.allowed_classes
  puts "✅ Allowed classes: #{allowed_classes}"
  
  puts "\n🎉 Basic tests passed! CodeHealer gem core is working!"
  
rescue => e
  puts "\n❌ Test failed with error: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.first(3)
end
