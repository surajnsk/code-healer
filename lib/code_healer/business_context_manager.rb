require 'yaml'
require 'json'

module CodeHealer
  class BusinessContextManager
    class << self
      def get_context_for_error(error, class_name, method_name)
        return {} unless ConfigManager.business_context_enabled?
        
        # Load business context from markdown files (same as Claude Code)
        markdown_context = load_business_context_from_markdown_simple
        
        context = {
          class_context: get_class_business_context(class_name),
          method_context: get_method_business_context(class_name, method_name),
          error_context: get_error_context(error),
          related_context: get_related_context(class_name, method_name),
          domain_patterns: get_domain_patterns(class_name),
          markdown_requirements: markdown_context  # Add markdown content
        }
        
        context.compact
      end
      
      def get_class_business_context(class_name)
        business_context = ConfigManager.business_context_settings
        
        # Extract class-specific context
        class_context = business_context[class_name] || {}
        
        # Add domain information
        domain_info = {
          domain: class_context['domain'] || 'General Business Logic',
          key_rules: class_context['key_rules'] || [],
          validation_patterns: class_context['validation_patterns'] || []
        }
        
        domain_info
      end
      
      def get_method_business_context(class_name, method_name)
        # Method-specific business rules
        method_rules = {
          'calculate_discount' => {
            rules: ['Discount cannot exceed 50% of subtotal', 'VIP customers get maximum 15%'],
            constraints: ['Positive amounts only', 'Valid customer tier required']
          },
          'process_order' => {
            rules: ['Orders must have valid items', 'Customer validation required'],
            constraints: ['Positive quantities', 'Valid payment method']
          },
          'validate_payment' => {
            rules: ['Card number must be valid', 'Expiry date must be future'],
            constraints: ['Valid CVV format', 'Supported payment method']
          }
        }
        
        method_rules[method_name] || {}
      end
      
      def get_error_context(error)
        {
          type: error.class.name,
          message: error.message,
          common_causes: get_common_error_causes(error.class),
          suggested_fixes: get_suggested_fixes(error.class)
        }
      end
      
      def get_common_error_causes(error_class)
        causes = {
          'ArgumentError' => [
            'Invalid parameter types',
            'Missing required parameters',
            'Parameter validation failed'
          ],
          'NoMethodError' => [
            'Method not defined',
            'Incorrect method name',
            'Missing method implementation'
          ],
          'TypeError' => [
            'Incompatible data types',
            'Nil value where object expected',
            'Type conversion failed'
          ],
          'NameError' => [
            'Undefined variable or constant',
            'Scope issue with variable',
            'Missing import or require'
          ]
        }
        
        causes[error_class.name] || ['Unknown error cause']
      end
      
      def get_suggested_fixes(error_class)
        fixes = {
          'ArgumentError' => [
            'Add parameter validation',
            'Check parameter types',
            'Provide default values'
          ],
          'NoMethodError' => [
            'Implement missing method',
            'Check method spelling',
            'Verify method exists in parent class'
          ],
          'TypeError' => [
            'Add type checking',
            'Handle nil values',
            'Convert types appropriately'
          ],
          'NameError' => [
            'Define missing variable',
            'Check variable scope',
            'Add missing imports'
          ]
        }
        
        fixes[error_class.name] || ['Review error and implement appropriate fix']
      end
      
      def get_related_context(class_name, method_name)
        # Find related classes and methods
        related = {
          'OrderProcessor' => ['User', 'Payment', 'Inventory'],
          'User' => ['Order', 'Profile', 'Authentication'],
          'OrderProcessorV2' => ['OrderProcessor', 'AdvancedValidation', 'BusinessRules']
        }
        
        {
          related_classes: related[class_name] || [],
          related_methods: get_related_methods(method_name),
          dependencies: get_class_dependencies(class_name)
        }
      end
      
      def get_related_methods(method_name)
        # Method relationships
        relationships = {
          'calculate_discount' => ['validate_customer', 'calculate_loyalty_points', 'apply_coupon'],
          'process_order' => ['validate_inventory', 'process_payment', 'send_confirmation'],
          'validate_payment' => ['validate_card', 'check_balance', 'process_transaction']
        }
        
        relationships[method_name] || []
      end
      
      def get_class_dependencies(class_name)
        # Class dependencies
        dependencies = {
          'OrderProcessor' => ['User', 'Payment', 'Inventory'],
          'User' => ['Order', 'Profile'],
          'OrderProcessorV2' => ['OrderProcessor', 'AdvancedValidation']
        }
        
        dependencies[class_name] || []
      end
      
      def get_domain_patterns(class_name)
        # Domain-specific patterns
        patterns = {
          'OrderProcessor' => {
            validation_pattern: 'Input validation → Business rule check → Processing → Result',
            error_handling: 'Graceful degradation with meaningful error messages',
            logging: 'Comprehensive logging for debugging and monitoring'
          },
          'User' => {
            validation_pattern: 'Data validation → Security check → Database operation → Response',
            error_handling: 'User-friendly error messages with guidance',
            logging: 'Security-focused logging without sensitive data'
          }
        }
        
        patterns[class_name] || {}
      end
      
    def build_claude_code_prompt(error, class_name, method_name, file_path)
        # Load business context from markdown files
        business_context = load_business_context_from_markdown_simple
        
        prompt = <<~PROMPT
          I have a Ruby on Rails application with an error that needs fixing.
          
          ## Error Details:
          - **Type:** #{error.class.name}
          - **Message:** #{error.message}
          - **Class:** #{class_name}
          - **Method:** #{method_name}
          - **File:** #{file_path}
          
          ## Complete Backtrace (for root cause analysis):
          ```
          #{error.backtrace&.join("\n") || "No backtrace available"}
          ```
          
          ## Business Context (from requirements):
          #{business_context}
          
          ## Instructions:
          Please:
          1. Analyze the error and understand the root cause
          2. **IMPORTANT: Check if the fix requires changes to multiple files or if the root cause is in a different file**
          3. Fix the issue considering the business rules above
          4. Ensure the fix doesn't break other functionality
          5. Follow Rails conventions and patterns
          6. Make sure to write testcases for the fix
          
          ## IMPORTANT: Full Codebase Access & Multi-File Fixes
          You have permission to edit ANY files in the codebase. Please:
          - **Don't limit yourself to just the file where the error occurred**
          - **Check related files, dependencies, and the broader codebase**
          - **If the fix requires multiple file changes, make ALL necessary changes**
          - **Look for root causes that might be in different files**
          - **Edit any file that needs to be modified to resolve the issue completely**
          - Ensure the fix follows business rules and validation patterns
          
          ## Multi-File Fix Strategy:
          - **Analyze the complete backtrace above** to understand the full error chain
          - **Start from the bottom of the backtrace** (where the error originated)
          - **Work your way up** to see how the error propagated through different files
          - **Identify ALL files in the call stack** that need modification
          - **Look for the root cause** - it might be in a different file than where the error was caught
          - **Make comprehensive changes** across the codebase if needed
          - **Don't just patch the symptom** - fix the underlying issue
          - **Check each file in the backtrace** for potential fixes
          
          Use your full codebase access to provide the best solution.
        PROMPT
        
        prompt.strip
      end
      
      def build_api_prompt(error, class_name, method_name, file_path)
        context = get_context_for_error(error, class_name, method_name)
        
        prompt = <<~PROMPT
          Fix this Ruby on Rails error:
          
          Error: #{context[:error_context][:type]} - #{context[:error_context][:message]}
          Class: #{class_name}
          Method: #{method_name}
          File: #{file_path}
          
          Business Context:
          - Domain: #{context[:class_context][:domain]}
          - Key Rules: #{context[:class_context][:key_rules].join("; ")}
          - Validation: #{context[:class_context][:validation_patterns].join("; ")}
          
          Method Rules: #{context[:method_context][:rules]&.join("; ") || "None"}
          
          Common Causes: #{context[:error_context][:common_causes].join("; ")}
          Suggested Fixes: #{context[:error_context][:suggested_fixes].join("; ")}
          
          ## Business Requirements (from markdown):
          #{context[:markdown_requirements]}
          
          Provide a production-ready fix that handles the error gracefully while maintaining business logic integrity.
        PROMPT
        
        prompt.strip
      end
      
      private
      
      def load_business_context_from_markdown_simple
        # Look for business requirements in the docs directory (created by setup script)
        docs_path = 'docs'
        business_rules_path = 'docs/business_rules.md'
        
        # First try the specific business_rules.md file
        if File.exist?(business_rules_path)
          content = File.read(business_rules_path)
          puts "📋 Loaded business context from: #{business_rules_path}"
          return content.strip
        end
        
        # Fallback: look for any markdown files in docs directory
        if Dir.exist?(docs_path)
          markdown_files = Dir.glob("#{docs_path}/**/*.md")
          
          if markdown_files.any?
            # Load the first markdown file
            content = File.read(markdown_files.first)
            puts "📋 Loaded business context from: #{markdown_files.first}"
            return content.strip
          end
        end
        
        # Fallback to basic business context
        puts "⚠️  No business context markdown files found, using fallback"
        return "Follow standard business logic and error handling practices."
      end
    end
  end
end
