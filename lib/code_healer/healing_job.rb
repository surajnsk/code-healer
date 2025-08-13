# frozen_string_literal: true

module CodeHealer
  class HealingJob
    include Sidekiq::Job
    
    sidekiq_options retry: 3, backtrace: true, queue: 'evolution'
    
    def perform(error_type, error_message, class_name, method_name, evolution_method = 'api', backtrace = nil)
      puts "🚀 Evolution Job Started: #{class_name}##{method_name}"
      
      # Reconstruct the error object with backtrace
      error = reconstruct_error(error_type, error_message, backtrace)
      
      # Determine evolution strategy
      case evolution_method
      when 'claude_code_terminal'
        handle_claude_code_evolution(error, class_name, method_name)
      when 'api'
        handle_api_evolution(error, class_name, method_name)
      when 'hybrid'
        handle_hybrid_evolution(error, class_name, method_name)
      else
        puts "⚠️  Unknown evolution method: #{evolution_method}"
      end
    end
    
    private
    
    def handle_claude_code_evolution(error, class_name, method_name)
      puts "🤖 Using Claude Code Terminal for evolution..."
      
      if defined?(CodeHealer::ClaudeCodeEvolutionHandler)
        # For Claude Code: pass the full backtrace instead of file path
        # Claude can analyze the backtrace and find files itself
        puts "📋 Sending full backtrace to Claude Code for intelligent analysis"
        puts "🔍 Backtrace length: #{error.backtrace&.length || 0} lines"
        
        CodeHealer::ClaudeCodeEvolutionHandler.handle_error_with_claude_code(
          error, class_name, method_name, nil
        )
      else
        puts "⚠️  ClaudeCodeEvolutionHandler not available"
      end
    end
    
    def handle_api_evolution(error, class_name, method_name)
      puts "🌐 Using OpenAI API for evolution..."
      
      # For API: extract file path since API doesn't have codebase access
      file_path = extract_file_path_from_backtrace(error.backtrace)
      puts "📁 File path for API: #{file_path || 'Not found'}"
      
      # Load business context
      if defined?(CodeHealer::BusinessContextManager)
        business_context = CodeHealer::BusinessContextManager.get_context_for_error(
          error, class_name, method_name
        )
        puts "📋 Business context loaded for API evolution"
      else
        business_context = {}
        puts "⚠️  BusinessContextManager not available"
      end
      
      # Use SimpleHealer for API-based evolution
      if defined?(CodeHealer::SimpleHealer)
        CodeHealer::SimpleHealer.handle_error_with_mcp_intelligence(
          error, class_name, method_name, file_path, business_context
        )
      else
        puts "⚠️  SimpleHealer not available"
      end
    end
    
    def handle_hybrid_evolution(error, class_name, method_name)
      puts "🔄 Using hybrid evolution strategy..."
      
      # Try Claude Code first, fallback to API
      begin
        handle_claude_code_evolution(error, class_name, method_name)
      rescue => e
        puts "⚠️  Claude Code evolution failed: #{e.message}"
        puts "🔄 Falling back to API evolution..."
        handle_api_evolution(error, class_name, method_name)
      end
    end
    
    def extract_file_path_from_backtrace(backtrace)
      return nil unless backtrace
      
      core_methods = %w[* + - / % ** == != < > <= >= <=> === =~ !~ & | ^ ~ << >> [] []= `]
      app_file_line = backtrace.find { |line| line.include?('/app/') }
      
      return nil unless app_file_line
      
      if app_file_line =~ /(.+):(\d+):in `(.+)'/
        file_path = $1
        method_name = $3
        
        # Handle Ruby operators by looking deeper in the stack
        if core_methods.include?(method_name)
          deeper_app_line = backtrace.find do |line| 
            line.include?('/app/') && 
            line =~ /in `(.+)'/ && 
            !core_methods.include?($1) &&
            !$1.include?('block in') &&
            !$1.include?('each') &&
            !$1.include?('map') &&
            !$1.include?('reduce')
          end
          
          if deeper_app_line && deeper_app_line =~ /(.+):(\d+):in `(.+)'/
            file_path = $1
            method_name = $3
          end
        end
        
        # Handle iterator methods and blocks
        if method_name && (
          method_name.include?('block in') || 
          method_name.include?('each') || 
          method_name.include?('map') || 
          method_name.include?('reduce') ||
          method_name.include?('sum')
        )
          containing_line = backtrace.find do |line|
            line.include?('/app/') && 
            line =~ /in `(.+)'/ && 
            !$1.include?('block in') &&
            !$1.include?('each') &&
            !$1.include?('map') &&
            !$1.include?('reduce') &&
            !$1.include?('sum')
          end
          
          if containing_line && containing_line =~ /(.+):(\d+):in `(.+)'/
            file_path = $1
            method_name = $3
          end
        end
        
        return file_path if file_path
      end
      
      nil
    end
    
    def reconstruct_error(error_type, error_message, backtrace = nil)
      # Create a simple error object with the type and message
      error_class = error_type.constantize rescue StandardError
      error = error_class.new(error_message)
      
      # Set the backtrace if provided
      if backtrace
        error.set_backtrace(backtrace)
        puts "📋 Backtrace restored: #{backtrace.length} lines"
      else
        puts "⚠️  No backtrace provided"
      end
      
      error
    rescue
      # Fallback to generic error
      StandardError.new(error_message)
    end
  end
end
