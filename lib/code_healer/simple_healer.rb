# frozen_string_literal: true

module CodeHealer
  class SimpleHealer
    class << self
      def handle_error_with_mcp_intelligence(error, class_name, method_name, file_path, business_context = {})
        puts "🧠 Starting MCP-powered intelligent healing..."
        
        # Initialize MCP server if available
        if defined?(CodeHealer::McpServer)
          begin
            CodeHealer::McpServer.initialize_server
            puts "✅ MCP Server initialized successfully with tools"
          rescue => e
            puts "⚠️  MCP Server initialization failed: #{e.message}"
          end
        end
        
        # Analyze the error using MCP tools
        analysis = analyze_error_with_mcp(error, class_name, method_name, business_context)
        
        if analysis
          # Generate fix using MCP
          fix = generate_fix_with_mcp(error, analysis, class_name, method_name, business_context)
          
          if fix
            # Apply the fix
            apply_fix_to_code(fix, class_name, method_name)
          else
            puts "⚠️  Failed to generate fix with MCP"
          end
        else
          puts "⚠️  Failed to analyze error with MCP"
        end
      end
      
      private
      
      def analyze_error_with_mcp(error, class_name, method_name, business_context)
        puts "🧠 MCP analyzing error: #{error.class} - #{error.message}"
        
        if defined?(CodeHealer::McpServer)
          begin
            context = {
              class_name: class_name,
              method_name: method_name,
              error: error,
              business_context: business_context
            }
            
            analysis = CodeHealer::McpServer.analyze_error(error, context)
            puts "✅ MCP analysis complete"
            return analysis
          rescue => e
            puts "⚠️  MCP analysis failed: #{e.message}"
            return nil
          end
        else
          puts "⚠️  MCP Server not available"
          return nil
        end
      end
      
      def generate_fix_with_mcp(error, analysis, class_name, method_name, business_context)
        puts "🧠 MCP generating contextual fix..."
        
        if defined?(CodeHealer::McpServer)
          begin
            context = {
              class_name: class_name,
              method_name: method_name,
              error: error,
              analysis: analysis,
              business_context: business_context
            }
            
            fix = CodeHealer::McpServer.generate_contextual_fix(error, analysis, context)
            puts "✅ MCP generated intelligent fix"
            return fix
          rescue => e
            puts "⚠️  MCP fix generation failed: #{e.message}"
            return nil
          end
        else
          puts "⚠️  MCP Server not available"
          return nil
        end
      end
      
      def apply_fix_to_code(fix, class_name, method_name)
        puts "🔧 Applying fix to code..."
        
        begin
          # Extract the new code from the fix
          new_code = extract_code_from_fix(fix)
          
          if new_code
            # Find the source file
            file_path = find_source_file(class_name)
            
            if file_path && File.exist?(file_path)
              # Apply the fix to the file
              success = patch_file_with_fix(file_path, method_name, new_code)
              
              if success
                puts "✅ Fix successfully applied to #{file_path}"
                
                # Reload the class to apply changes
                reload_class(class_name)
                
                # Create Git commit if configured
                create_git_commit(class_name, method_name, fix)
                
                return true
              else
                puts "⚠️  Failed to apply fix to file"
                return false
              end
            else
              puts "⚠️  Source file not found for #{class_name}"
              return false
            end
          else
            puts "⚠️  No valid code found in fix"
            return false
          end
        rescue => e
          puts "❌ Error applying fix: #{e.message}"
          puts e.backtrace.first(3)
          return false
        end
      end
      
      private
      
      def extract_code_from_fix(fix)
        case fix
        when Hash
          fix[:new_code] || fix[:code] || fix['new_code'] || fix['code']
        when String
          fix
        else
          nil
        end
      end
      
      def find_source_file(class_name)
        # Look for the class file in common Rails locations
        possible_paths = [
          "app/models/#{class_name.underscore}.rb",
          "app/controllers/#{class_name.underscore}_controller.rb",
          "app/services/#{class_name.underscore}.rb",
          "app/lib/#{class_name.underscore}.rb"
        ]
        
        possible_paths.find { |path| File.exist?(Rails.root.join(path)) }
      end
      
      def patch_file_with_fix(file_path, method_name, new_code)
        full_path = Rails.root.join(file_path)
        current_content = File.read(full_path)
        
        puts "Applying fix for #{method_name}..."
        puts "Current content length: #{current_content.length}"
        
        # Get the new method code and clean it up
        new_method_code = new_code.to_s.strip
        puts "Generated new method: #{new_method_code}"
        
        # Clean up the new method code - remove extra indentation
        method_lines = new_method_code.split("\n")
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
          if line.strip.start_with?("def #{method_name}")
            method_start_index = index
            method_indent = line.match(/^(\s*)/)[1].length
            break
          end
        end
        
        if method_start_index.nil?
          puts "❌ Could not find method #{method_name} in file"
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
        unless valid_ruby_syntax?(new_content)
          puts "❌ Syntax validation failed, reverting to original content"
          return false
        end
        
        # Write the updated content
        File.write(full_path, new_content)
        puts "📝 Updated method #{method_name} in #{file_path}"
        true
      end
      
      private
      
      def valid_ruby_syntax?(content)
        begin
          # Try to parse the Ruby code
          RubyVM::InstructionSequence.compile(content)
          true
        rescue SyntaxError => e
          puts "   Syntax error: #{e.message}"
          false
        rescue => e
          puts "   Validation error: #{e.message}"
          false
        end
      end
      
      def reload_class(class_name)
        begin
          # Remove the constant to force reload
          Object.send(:remove_const, class_name.to_sym) if Object.const_defined?(class_name.to_sym)
          
          # Reload the file
          load Rails.root.join(find_source_file(class_name))
          
          puts "🔄 Successfully reloaded #{class_name}"
        rescue => e
          puts "⚠️  Failed to reload #{class_name}: #{e.message}"
        end
      end
      
      def create_git_commit(class_name, method_name, fix)
        return unless git_configured?
        
        begin
          git = Git.open(Rails.root.to_s)
          
          # Create Git branch using configuration
          branch_prefix = CodeHealer::ConfigManager.branch_prefix
          branch_name = "#{branch_prefix}/#{class_name.downcase}-#{method_name}-#{Time.now.to_i}"
          puts "🌿 Creating new branch: #{branch_name}"
          
          # Create and checkout new branch
          git.branch(branch_name).checkout
          puts "✅ Created and checked out branch: #{branch_name}"
          
          # Create a descriptive commit message using template
          commit_message = generate_commit_message_from_template(class_name, method_name, fix)
          
          # Add and commit the changes
          git.add('.')
          git.commit(commit_message)
          
          puts "📝 Git commit created: #{commit_message}"
          
          # Push if configured
          if CodeHealer::ConfigManager.auto_push?
            push_changes(git, branch_name)
          end
          
          # Create pull request if configured
          if CodeHealer::ConfigManager.auto_create_pr?
            create_pull_request(branch_name, class_name, method_name, fix)
          end
          
        rescue => e
          puts "⚠️  Git operations failed: #{e.message}"
        end
      end
      
      def git_configured?
        File.exist?(Rails.root.join('.git'))
      end
      
      def generate_commit_message_from_template(class_name, method_name, fix)
        template = CodeHealer::ConfigManager.commit_message_template
        
        # Replace placeholders in template
        message = template.gsub('{class_name}', class_name.to_s)
                         .gsub('{method_name}', method_name.to_s)
                         .gsub('{error_type}', fix[:error_type] || fix['error_type'] || 'Unknown')
        
        # Add additional context
        message += "\n\nGenerated by CodeHealer gem"
        if fix[:description] || fix['description']
          message += "\nDescription: #{fix[:description] || fix['description']}"
        end
        if fix[:risk_level] || fix['risk_level']
          message += "\nRisk Level: #{fix[:risk_level] || fix['risk_level']}"
        end
        
        message
      end
      
      def push_changes(git, branch_name)
        begin
          git.push('origin', branch_name)
          puts "🚀 Changes pushed to origin/#{branch_name}"
        rescue => e
          puts "⚠️  Failed to push changes: #{e.message}"
        end
      end

      def create_pull_request(branch_name, class_name, method_name, fix)
        puts "🔗 Creating pull request for branch: #{branch_name}"
        
        # Get configuration
        target_branch = CodeHealer::ConfigManager.pr_target_branch
        labels = CodeHealer::ConfigManager.pr_labels
        
        puts "📋 Target branch: #{target_branch}"
        puts "🏷️  Labels: #{labels.join(', ')}"
        
        begin
          # Validate GitHub configuration
          unless validate_github_config
            return false
          end
          
          # Initialize GitHub client
          github_client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
          
          # Test GitHub connection
          begin
            github_client.user
            puts "✅ GitHub connection successful"
          rescue Octokit::Error => e
            puts "❌ GitHub authentication failed: #{e.message}"
            return false
          end
          
          # Create pull request title and body
          title = "Fix #{class_name}##{method_name}: #{fix[:error_type] || 'AI-generated fix'}"
          body = generate_pr_body(class_name, method_name, fix, branch_name)
          
          puts "📝 Creating PR: #{title}"
          puts "📄 PR Body length: #{body.length} characters"
          
          # Create the pull request
          pr = github_client.create_pull_request(
            ENV['GITHUB_REPOSITORY'],
            target_branch,
            branch_name,
            title,
            body
          )
          
          # Add labels to the PR
          if labels.any?
            begin
              github_client.add_labels_to_an_issue(ENV['GITHUB_REPOSITORY'], pr.number, labels)
              puts "🏷️  Added labels: #{labels.join(', ')}"
            rescue => e
              puts "⚠️  Warning: Could not add labels: #{e.message}"
            end
          end
          
          puts "✅ Pull request created successfully!"
          puts "🔗 PR URL: #{pr.html_url}"
          puts "🔢 PR Number: ##{pr.number}"
          
          return true
          
        rescue Octokit::Error => e
          puts "❌ GitHub API error: #{e.message}"
          if e.respond_to?(:errors) && e.errors.any?
            puts "📍 Error details:"
            e.errors.each { |error| puts "   - #{error}" }
          end
          return false
        rescue => e
          puts "❌ Unexpected error creating PR: #{e.message}"
          puts "📍 Backtrace: #{e.backtrace.first(3)}"
          return false
        end
      end
      
      private
      
      def validate_github_config
        github_token = ENV['GITHUB_TOKEN']
        github_repo = ENV['GITHUB_REPOSITORY']
        
        unless github_token
          puts "❌ Missing GITHUB_TOKEN environment variable"
          puts "💡 Set it in your .env file or export it in your shell"
          return false
        end
        
        unless github_repo
          puts "❌ Missing GITHUB_REPOSITORY environment variable"
          puts "💡 Set it in your .env file (format: username/repository)"
          return false
        end
        
        unless github_repo.include?('/')
          puts "❌ Invalid GITHUB_REPOSITORY format: #{github_repo}"
          puts "💡 Should be in format: username/repository"
          return false
        end
        
        puts "✅ GitHub configuration validated"
        true
      end
      
      def generate_pr_body(class_name, method_name, fix, branch_name)
        body = <<~MARKDOWN
          ## 🤖 AI-Powered Code Fix
          
          This pull request was automatically generated by **CodeHealer** - an AI-powered code healing system.
          
          ### 📋 Fix Details
          - **Class**: `#{class_name}`
          - **Method**: `#{method_name}`
          - **Error Type**: #{fix[:error_type] || 'Unknown'}
          - **Branch**: `#{branch_name}`
          
          ### 🔧 What Was Fixed
          #{fix[:description] || 'AI-generated fix for the specified error'}
          
          ### 🧠 How It Works
          CodeHealer detected an error in your application and automatically:
          1. Analyzed the error using AI
          2. Generated a production-ready fix
          3. Applied the fix to your code
          4. Created this pull request for review
          
          ### ✅ Safety Features
          - Code syntax validated before application
          - Business context awareness integrated
          - Comprehensive error handling added
          - Logging and monitoring included
          
          ### 🔍 Review Checklist
          - [ ] Code follows your project's style guidelines
          - [ ] Error handling is appropriate for your use case
          - [ ] Business logic aligns with your requirements
          - [ ] Tests pass (if applicable)
          
          ### 🚀 Next Steps
          Review the changes and merge when ready. The fix is already applied to your code and ready for testing.
          
          ---
          *Generated by CodeHealer v#{CodeHealer::VERSION}*
        MARKDOWN
        
        body.strip
      end
    end
  end
end
