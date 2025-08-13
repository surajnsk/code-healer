class EvolutionJob
  include Sidekiq::Job
  
  sidekiq_options retry: 3, backtrace: true, queue: 'evolution'
  
  def perform(error_data, class_name, method_name, file_path)
    puts "🚀 Evolution Job Started: #{class_name}##{method_name}"
    
    # Reconstruct the error object
    error = reconstruct_error(error_data)
    
    # Determine evolution strategy
    evolution_method = CodeHealer::ConfigManager.evolution_method
    
    case evolution_method
    when 'claude_code_terminal'
      handle_claude_code_evolution(error, class_name, method_name, file_path)
    when 'api'
      handle_api_evolution(error, class_name, method_name, file_path)
    when 'hybrid'
      handle_hybrid_evolution(error, class_name, method_name, file_path)
    else
      puts "❌ Unknown evolution method: #{evolution_method}"
    end
    
    puts "✅ Evolution Job Completed: #{class_name}##{method_name}"
  rescue => e
    puts "❌ Evolution Job Failed: #{e.message}"
    puts "📍 Backtrace: #{e.backtrace.first(5)}"
    raise e  # Re-raise to trigger Sidekiq retry
  end

  private

  def reconstruct_error(error_data)
    # Reconstruct the error object from serialized data
    error_class = Object.const_get(error_data['class'])
    error = error_class.new(error_data['message'])
    
    # Restore backtrace if available
    if error_data['backtrace']
      error.set_backtrace(error_data['backtrace'])
    end
    
    error
  end

  def handle_claude_code_evolution(error, class_name, method_name, file_path)
    puts "🤖 Using Claude Code Terminal for evolution..."
    
    # Use the existing Claude Code evolution handler (it's a class method)
    success = CodeHealer::ClaudeCodeEvolutionHandler.handle_error_with_claude_code(error, class_name, method_name, file_path)
    
    if success
      puts "✅ Claude Code evolution completed successfully!"
    else
      puts "❌ Claude Code evolution failed"
      raise "Claude Code evolution failed for #{class_name}##{method_name}"
    end
  end

  def handle_api_evolution(error, class_name, method_name, file_path)
    puts "🌐 Using OpenAI API for evolution..."
    
    # Load business context for API evolution
    business_context = CodeHealer::BusinessContextManager.get_context_for_error(
      error, class_name, method_name
    )
    
    puts "📋 Business context loaded for API evolution"
    
    # Use the existing MCP evolution handler with business context
    success = CodeHealer::SimpleEvolution.handle_error_with_mcp_intelligence(
      error, class_name, method_name, file_path, business_context
    )
    
    if success
      puts "✅ API evolution completed successfully!"
    else
      puts "❌ API evolution failed"
      raise "API evolution failed for #{class_name}##{method_name}"
    end
  end

  def handle_hybrid_evolution(error, class_name, method_name, file_path)
    puts "🔄 Using Hybrid approach for evolution..."
    
    begin
      # Try Claude Code first
      success = handle_claude_code_evolution(error, class_name, method_name, file_path)
      return if success
    rescue => e
      puts "⚠️  Claude Code failed, falling back to API: #{e.message}"
    end
    
    # Fallback to API
    handle_api_evolution(error, class_name, method_name, file_path)
  end
end
