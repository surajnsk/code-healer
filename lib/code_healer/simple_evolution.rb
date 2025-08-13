require 'git'
require_relative 'business_rule_applier'
require_relative 'business_context_analyzer'

module CodeHealer
  class SimpleEvolution
    def self.handle_error(error, class_name, method_name, file_path)
      # Check if evolution is enabled and allowed
      unless ConfigManager.enabled?
        puts "Self-evolution is disabled"
        return false
      end

      unless ConfigManager.can_evolve_class?(class_name)
        puts "Class #{class_name} is not allowed to evolve"
        return false
      end

      unless ConfigManager.can_handle_error?(error)
        puts "Error type #{error.class.name} is not allowed to be handled"
        return false
      end

      puts "\n=== Self-Evolution Triggered ==="
      puts "Error: #{error.class} - #{error.message}"
      puts "Class: #{class_name}"
      puts "Method: #{method_name}"
      puts "File: #{file_path}"
      
      # Analyze the error and generate a fix
      fix = generate_fix(error, class_name, method_name)
      
      if fix
        # Apply the fix
        apply_fix(file_path, fix, class_name, method_name, error)
        return true
      else
        puts "Could not generate fix for this error"
        return false
      end
    end
    
    private
    
    def self.repatch_evolved_class(class_name, file_path)
      puts "🔄 Re-patching evolved class: #{class_name}"
      
      begin
        # Get the actual class object
        klass = Object.const_get(class_name)
        
        # Re-patch the class with error handling
        klass.class_eval do
          instance_methods(false).each do |method_name|
            next if method_name == :initialize || method_name.to_s.start_with?('_')
            
            original_method = instance_method(method_name)
            remove_method(method_name)
            
            define_method(method_name) do |*args, &block|
              begin
                original_method.bind(self).call(*args, &block)
              rescue => e
                puts "\n=== Error Caught in #{self.class.name}##{method_name} ==="
                puts "Error: #{e.class} - #{e.message}"
                
                # Handle the error with self-evolution
                handle_console_error(e, self.class, method_name)
                raise e
              end
            end
          end
        end
        
        puts "✅ Successfully re-patched #{class_name} for error handling"
        return true
        
      rescue => e
        puts "❌ Failed to re-patch #{class_name}: #{e.message}"
        return false
      end
    end
    
    def self.generate_fix(error, class_name, method_name)
      case error
      when ZeroDivisionError
        generate_division_fix(class_name, method_name)
      when NoMethodError
        generate_method_fix(error, class_name, method_name)
      else
        nil
      end
    end
    
    def self.generate_division_fix(class_name, method_name)
      {
        method_name: method_name,
        new_code: <<~RUBY
  def #{method_name}(a, b)
    if b == 0
      puts "Warning: Division by zero attempted. Returning 0."
      return 0
    end
    a / b
  end
        RUBY
      }
    end
    
    def self.generate_method_fix(error, class_name, method_name)
      if error.message.include?('undefined method')
        {
          method_name: method_name,
          new_code: <<~RUBY
  def #{method_name}(a, b)
    puts "Warning: Method #{method_name} called but not implemented. Returning 0."
    return 0
  end
        RUBY
        }
      else
        nil
      end
    end
    
    def self.apply_fix(file_path, fix, class_name, method_name, error)
      puts "Applying fix for #{class_name}##{method_name}..."
      
      # Read current file
      current_content = File.read(file_path)
      puts "Current content length: #{current_content.length}"
      
      # Get the new method code and clean it up
      new_method_code = fix['new_code'] || fix[:new_code]
      puts "Generated new method: #{new_method_code}"
      
      # 🔧 APPLY BUSINESS RULES TO THE GENERATED CODE
      if defined?(BusinessContextAnalyzer) && defined?(BusinessRuleApplier)
        begin
          puts "🔍 Getting business context for business rule application..."
          
          # Get the file path for business context analysis
          file_path_for_context = file_path
          
          # Analyze business context
          business_analysis = BusinessContextAnalyzer.analyze_error_for_business_context(
            error, class_name, method_name, file_path_for_context
          )
          
          # Apply business rules to the generated code
          new_method_code = BusinessRuleApplier.apply_business_rules_to_code(
            business_analysis, new_method_code, error, class_name, method_name
          )
          
          puts "✅ Business rules applied to generated code"
        rescue => e
          puts "⚠️  Warning: Could not apply business rules: #{e.message}"
          puts "   Continuing with original generated code..."
        end
      else
        puts "ℹ️  Business rule applier not available, using original generated code"
      end
      
      # Clean up the new method code - remove extra indentation
      method_lines = new_method_code.strip.split("\n")
      # Find the base indentation of the first line
      base_indent = method_lines.first.match(/^(\s*)/)[1].length
      # Remove the base indentation from all lines
      cleaned_method_lines = method_lines.map do |line|
        if line.strip.empty?
          line
        else
          line_indent = line.match(/^(\s*)/)[1].length
          if line_indent >= base_indent
            line[base_indent..-1]
          else
            line
          end
        end
      end
      cleaned_method_code = cleaned_method_lines.join("\n")
      
      # Use a simpler and more reliable method replacement approach
      lines = current_content.split("\n")
      new_lines = []
      method_start_index = nil
      method_indent = 0
      
      # Find the method start
      lines.each_with_index do |line, index|
        if line.strip.start_with?("def #{fix['method_name'] || fix[:method_name]}")
          method_start_index = index
          method_indent = line.match(/^(\s*)/)[1].length
          break
        end
      end
      
      if method_start_index.nil?
        puts "❌ Could not find method #{fix['method_name'] || fix[:method_name]} in file"
        return false
      end
      
      # Find the method end using a simple approach
      method_end_index = method_start_index
      indent_level = method_indent
      
      lines[method_start_index..-1].each_with_index do |line, relative_index|
        actual_index = method_start_index + relative_index
        current_indent = line.match(/^(\s*)/)[1].length
        
        # Skip the method definition line
        if relative_index == 0
          next
        end
        
        # If we find an 'end' at the same or lower indentation level, we're done
        if line.strip == 'end' && current_indent <= indent_level
          method_end_index = actual_index
          break
        end
        
        # If we find another method definition at the same level, we're done
        if line.strip.start_with?('def ') && current_indent == indent_level
          method_end_index = actual_index - 1
          break
        end
      end
      
      # Build the new content
      new_lines = lines[0...method_start_index]
      
      # Add the new method with proper indentation
      method_indent_str = ' ' * method_indent
      cleaned_method_lines.each do |method_line|
        if method_line.strip.empty?
          new_lines << method_line
        else
          new_lines << method_indent_str + method_line
        end
      end
      
      # Add the rest of the file after the method
      new_lines += lines[(method_end_index + 1)..-1]
      
      new_content = new_lines.join("\n")
      puts "New content length: #{new_content.length}"
      
      # Validate syntax before applying
      unless validate_syntax(new_content)
        puts "❌ Syntax validation failed, reverting to original content"
        return false
      end
      
      # Create Git branch
      git_settings = ConfigManager.git_settings
      branch_prefix = git_settings['branch_prefix'] || 'evolve'
      branch_name = "#{branch_prefix}/#{class_name.downcase}-#{method_name}-#{Time.now.to_i}"
      puts "Creating new branch: #{branch_name}"
      
      begin
        git = Git.open(Dir.pwd)
        
        # Create and checkout new branch
        git.branch(branch_name).checkout
        puts "Created and checked out branch: #{branch_name}"
        
        # Write the updated file
        File.write(file_path, new_content)
        puts "Updated file: #{file_path}"
        
        # Reload the class to get the updated method
        load file_path
        puts "🔄 Class reloaded with updated method!"
        
        # Re-patch the evolved class to restore error handling
        repatch_evolved_class(class_name, file_path)
        
        # Commit the changes
        commit_template = (git_settings['commit_message_template'] || 'Fix {class_name}##{method_name}: {error_type}').to_s
        commit_message = commit_template.gsub('{class_name}', class_name.to_s)
                                       .gsub('{method_name}', method_name.to_s)
                                       .gsub('{error_type}', error.class.name.to_s)
        
        puts "Commit message: #{commit_message}"
        
        git.add(file_path)
        puts "Added file to git"
        
        # Use a simpler commit approach
        begin
          git.commit(commit_message)
          puts "Committed changes to branch: #{branch_name}"
        rescue => commit_error
          puts "Commit failed with message: #{commit_message}"
          puts "Commit error: #{commit_error.message}"
          # Try with a simpler message
          git.commit("Fix #{class_name}##{method_name}: #{error.class.name}")
          puts "Committed with fallback message"
        end
        
        # Push to remote if enabled
        if git_settings['auto_push']
          begin
            git.push('origin', branch_name)
            puts "Pushed to remote repository"
            
            # Create pull request if enabled
            if ConfigManager.auto_create_pr?
              puts "🎯 Attempting to create pull request..."
              fix_description = get_fix_description(error, method_name)
              pr_url = CodeHealer::PullRequestCreator.create_pull_request(
                branch_name, 
                class_name, 
                method_name, 
                error, 
                fix_description, 
                file_path
              )
              if pr_url
                puts "✅ Pull request created successfully: #{pr_url}"
              else
                puts "❌ Pull request creation failed"
              end
            else
              puts "📝 PR creation is disabled in configuration"
            end
          rescue => e
            puts "Push failed (expected without remote): #{e.message}"
          end
        end
        
        return true
        
      rescue => e
        puts "Git operations failed: #{e.message}"
        return false
      end
    end

    def self.get_fix_description(error, method_name)
      case error
      when ZeroDivisionError
        "Added division by zero check to prevent crashes"
      when NoMethodError
        "Added method implementation with default return value"
      when ArgumentError
        "Added argument validation and error handling"
      else
        "Added error handling for #{error.class.name}"
      end
    end

    def self.validate_syntax(content)
      begin
        # Try to parse the content as Ruby code
        RubyVM::InstructionSequence.compile(content)
        puts "✅ Syntax validation passed"
        true
      rescue SyntaxError => e
        puts "❌ Syntax error: #{e.message}"
        false
      rescue => e
        puts "❌ Validation error: #{e.message}"
        false
      end
    end

    # Intelligent MCP-powered error handler
    def self.handle_error_with_mcp_intelligence(error, class_name, method_name, file_path, business_context = nil)
      # Check if evolution is enabled and allowed
      unless ConfigManager.enabled?
        puts "Self-evolution is disabled"
        return false
      end

      unless ConfigManager.can_evolve_class?(class_name)
        puts "Class #{class_name} is not allowed to evolve"
        return false
      end

      unless ConfigManager.can_handle_error?(error)
        puts "Error type #{error.class.name} is not allowed to be handled"
        return false
      end

      puts "\n=== MCP-Powered Self-Evolution Triggered ==="
      puts "Error: #{error.class} - #{error.message}"
      puts "Class: #{class_name}"
      puts "Method: #{method_name}"
      puts "File: #{file_path}"
      puts "Business Context: #{business_context.inspect}" if business_context

      
      # Initialize MCP server if not already done
      MCPServer.initialize_server unless defined?(@mcp_initialized)
      @mcp_initialized = true
      
      # Get rich context from MCP, enhanced with business context if provided
      puts "🧠 Getting codebase context from MCP..."
      context = MCPServer.get_codebase_context(class_name, method_name)
      
      # Enhance context with business context if provided
      if business_context
        puts "🧠 Enhancing context with business rules..."
        context = context.merge({
          'business_context' => business_context
        })
      end
      
      # Analyze error with MCP intelligence
      puts "🧠 Analyzing error with MCP..."
      analysis = MCPServer.analyze_error(error, context)
      
      # Generate intelligent, contextual fix
      puts "🧠 Generating intelligent fix with MCP..."
      fix = MCPServer.generate_contextual_fix(error, analysis, context)
      
      # Debug: Check what fix contains
      puts "🔍 Debug: Fix result = #{fix.inspect}"
      
      # Validate fix with MCP
      puts "🔍 Validating fix with MCP..."
      validation = MCPServer.validate_fix(fix, context)
      
      unless validation['approved'] || validation[:approved]
        puts "❌ MCP validation failed: #{validation['recommendations'] || validation[:recommendations]}"
        return false
      end
      
      puts "✅ MCP validation passed with confidence: #{validation['confidence_score'] || validation[:confidence_score]}"
      
      if fix
        if ConfigManager.require_approval?
          # Approval required - create PR but don't apply fix locally
          puts "\n🔒 Approval Required - Creating PR for Review"
          puts "=" * 50
          puts "The intelligent fix will be applied only after PR is merged."
          puts "Check the created PR for review and approval."
          
          # Create PR without applying fix locally
          create_pr_without_local_fix(file_path, fix, class_name, method_name, error)
          return true
        else
          # No approval required - apply fix immediately
          apply_fix(file_path, fix, class_name, method_name, error)
          return true
        end
      else
        puts "Could not generate intelligent fix for this error"
        return false
      end
    end

    # Approval-aware error handler (legacy)
    def self.handle_error_with_approval(error, class_name, method_name, file_path)
      # Check if evolution is enabled and allowed
      unless ConfigManager.enabled?
        puts "Self-evolution is disabled"
        return false
      end

      unless ConfigManager.can_evolve_class?(class_name)
        puts "Class #{class_name} is not allowed to evolve"
        return false
      end

      unless ConfigManager.can_handle_error?(error)
        puts "Error type #{error.class.name} is not allowed to be handled"
        return false
      end

      puts "\n=== Self-Evolution Triggered ==="
      puts "Error: #{error.class} - #{error.message}"
      puts "Class: #{class_name}"
      puts "Method: #{method_name}"
      puts "File: #{file_path}"
      
      # Analyze the error and generate a fix
      fix = generate_fix(error, class_name, method_name)
      
      if fix
        if ConfigManager.require_approval?
          # Approval required - create PR but don't apply fix locally
          puts "\n🔒 Approval Required - Creating PR for Review"
          puts "=" * 50
          puts "The fix will be applied only after PR is merged."
          puts "Check the created PR for review and approval."
          
          # Create PR without applying fix locally
          create_pr_without_local_fix(file_path, fix, class_name, method_name, error)
          return true
        else
          # No approval required - apply fix immediately
          apply_fix(file_path, fix, class_name, method_name, error)
          return true
        end
      else
        puts "Could not generate fix for this error"
        return false
      end
    end

    def self.create_pr_without_local_fix(file_path, fix, class_name, method_name, error)
      puts "Creating PR for #{class_name}##{method_name}..."
      
      # Create Git branch
      git_settings = ConfigManager.git_settings
      branch_prefix = git_settings['branch_prefix'] || 'evolve'
      branch_name = "#{branch_prefix}/#{class_name.downcase}-#{method_name}-#{Time.now.to_i}"
      puts "Creating new branch: #{branch_name}"
      
      begin
        git = Git.open(Dir.pwd)
        
        # Store the original branch
        original_branch = git.current_branch
        puts "Original branch: #{original_branch}"
        
        # Create and checkout new branch
        git.branch(branch_name).checkout
        puts "Created and checked out branch: #{branch_name}"
        
        # Read current file content
        current_content = File.read(file_path)
        
        # Apply the fix to create the new content
        lines = current_content.split("\n")
        new_lines = []
        in_method = false
        method_indent = 0
        skip_until_end = false
        
        lines.each_with_index do |line, index|
          if skip_until_end
            if line.strip == 'end' && in_method
              in_method = false
              skip_until_end = false
              # Add the new method content
              new_lines.concat(fix[:new_code].strip.split("\n"))
            end
            next
          end
          
          if line.strip.start_with?("def #{fix[:method_name]}(")
            in_method = true
            method_indent = line.match(/^(\s*)/)[1].length
            skip_until_end = true
            next
          end
          
          new_lines << line
        end
        
        new_content = new_lines.join("\n")
        
        # Write the updated file to the branch
        File.write(file_path, new_content)
        puts "Updated file in branch: #{file_path}"
        
        # Use simple commit message
        commit_message = "Fix #{method_name} method (requires approval)"
        
        puts "Commit message: #{commit_message}"
        
        git.add(file_path)
        puts "Added file to git"
        
        # Commit the changes
        commit_success = false
        begin
          git.commit(commit_message)
          puts "Committed changes to branch: #{branch_name}"
          commit_success = true
        rescue => commit_error
          puts "Commit failed: #{commit_error.message}"
          # Try using system git command as fallback
          begin
            system("git add #{file_path}")
            system("git commit -m '#{commit_message}'")
            if $?.success?
              puts "Committed using system git command"
              commit_success = true
            else
              puts "System git commit also failed"
            end
          rescue => system_error
            puts "System git command failed: #{system_error.message}"
          end
        end
        
        # Push to remote if enabled and commit was successful
        push_success = false
        if git_settings['auto_push'] && commit_success
          begin
            git.push('origin', branch_name)
            puts "Pushed to remote repository"
            push_success = true
          rescue => e
            puts "Git gem push failed: #{e.message}"
            # Try using system git command as fallback
            begin
              system("git push origin #{branch_name}")
              if $?.success?
                puts "Pushed using system git command"
                push_success = true
              else
                puts "System git push also failed"
              end
            rescue => system_error
              puts "System git push failed: #{system_error.message}"
            end
          end
        elsif !commit_success
          puts "Push skipped - commit failed"
        end
        
        # Create pull request if enabled
        if ConfigManager.auto_create_pr? && push_success
          puts "🎯 Creating pull request for approval..."
          fix_description = get_fix_description(error, method_name)
          pr_url = PullRequestCreator.create_pull_request(
            branch_name, 
            class_name, 
            method_name, 
            error, 
            fix_description, 
            file_path
          )
          if pr_url
            puts "✅ Pull request created successfully: #{pr_url}"
            puts "🔒 Fix will be applied only after PR is merged."
            puts "📋 Review the PR and merge when ready."
          else
            puts "❌ Pull request creation failed"
          end
        elsif ConfigManager.auto_create_pr? && !push_success
          puts "📝 PR creation skipped - push to remote failed"
        else
          puts "📝 PR creation is disabled in configuration"
        end
        
        # Switch back to original branch
        git.checkout(original_branch)
        puts "Switched back to original branch: #{original_branch}"
        
        return true
        
      rescue => e
        puts "Git operations failed: #{e.message}"
        return false
      end
    end
    
    # Dedicated method for Git operations (used by Claude Code evolution)
    def self.handle_git_operations_for_claude(error, class_name, method_name, file_path)
      puts "🚀 Starting Git operations for Claude Code evolution..."
      
      begin
        git_settings = ConfigManager.git_settings
        branch_prefix = git_settings['branch_prefix'] || 'evolve'
        branch_name = "#{branch_prefix}/#{class_name.downcase}-#{method_name}-#{Time.now.to_i}"
        puts "Creating new branch: #{branch_name}"
        
        git = Git.open(Dir.pwd)
        
        # Create and checkout new branch
        git.branch(branch_name).checkout
        puts "Created and checked out branch: #{branch_name}"
        
        # Add all modified files (Claude Code may have modified multiple files)
        git.add('.')
        puts "Added all modified files to git"
        
        # Commit the changes
        commit_template = (git_settings['commit_message_template'] || 'Fix {class_name}##{method_name}: {error_type}').to_s
        commit_message = commit_template.gsub('{class_name}', class_name.to_s)
                                       .gsub('{method_name}', method_name.to_s)
                                       .gsub('{error_type}', error.class.name.to_s)
        
        puts "Commit message: #{commit_message}"
        
        begin
          git.commit(commit_message)
          puts "Committed changes to branch: #{branch_name}"
        rescue => commit_error
          puts "Commit failed, trying fallback message..."
          git.commit("Fix #{class_name}##{method_name}: #{error.class.name}")
          puts "Committed with fallback message"
        end
        
        # Push to remote if enabled
        if git_settings['auto_push']
          begin
            git.push('origin', branch_name)
            puts "Pushed to remote repository"
            
            # Create pull request if enabled
            if ConfigManager.auto_create_pr?
              puts "🎯 Attempting to create pull request..."
              fix_description = get_fix_description(error, method_name)
              pr_url = CodeHealer::PullRequestCreator.create_pull_request(
                branch_name, 
                class_name, 
                method_name, 
                error, 
                fix_description, 
                file_path
              )
              if pr_url
                puts "✅ Pull request created successfully: #{pr_url}"
                return true
              else
                puts "❌ Pull request creation failed"
                return false
              end
            else
              puts "📝 PR creation is disabled in configuration"
              return true
            end
          rescue => e
            puts "Push failed: #{e.message}"
            return false
          end
        else
          puts "📝 Auto-push is disabled in configuration"
          return true
        end
        
      rescue => e
        puts "Git operations failed: #{e.message}"
        return false
      end
    end
  end
end

require_relative 'mcp_server' 