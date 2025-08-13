require_relative 'mcp_tools'
require_relative 'mcp_prompts'

module CodeHealer
  class McpServer
    class << self
      def initialize_server
        puts "🤖 Initializing MCP Server for intelligent evolution..."

        # Load context and business rules
        @codebase_context = load_codebase_context
        @business_rules = load_business_rules

        # Initialize MCP server with tools (simplified for now)
        @server = CodeHealer::MCP::Server.new(
          name: "code_healer_server",
          version: "1.0.0",
          tools: [
            ErrorAnalysisTool,
            CodeFixTool,
            ContextAnalysisTool
          ],
          server_context: {
            codebase_context: @codebase_context,
            business_rules: @business_rules
          }
        )

        puts "✅ MCP Server initialized successfully with tools"
      end
      
      def get_codebase_context(class_name, method_name)
        # Get rich context for a class and method
        {
          class_info: analyze_class(class_name),
          method_info: analyze_method(class_name, method_name),
          dependencies: find_dependencies(class_name),
          business_context: get_business_context(class_name),
          evolution_history: get_evolution_history(class_name, method_name),
          similar_patterns: find_similar_patterns(class_name, method_name),
          markdown_requirements: load_business_requirements_from_markdown
        }
      end
      
      def analyze_error(error, context)
        puts "🧠 MCP analyzing error: #{error.class} - #{error.message}"
        
        # Extract class and method names from context
        class_name = context[:class_name] || 'UnknownClass'
        method_name = context[:method_name] || 'unknown_method'
        
        # Use MCP tool to analyze error
        if defined?(ErrorAnalysisTool)
          result = ErrorAnalysisTool.call(
            error_type: error.class.name,
            error_message: error.message,
            class_name: class_name,
            method_name: method_name,
            server_context: { codebase_context: context }
          )
          
          puts "✅ MCP analysis complete"
          # Parse the JSON response from MCP tool
          JSON.parse(result.content.first[:text])
        else
          puts "⚠️  ErrorAnalysisTool not available, using fallback analysis"
          # Fallback analysis
          {
            severity: 'medium',
            impact: 'moderate',
            root_cause: 'division by zero',
            suggested_fixes: ['add_zero_division_check', 'add_input_validation'],
            risks: 'low'
          }
        end
      end
      
      def generate_contextual_fix(error, analysis, context)
        puts "🧠 MCP generating contextual fix..."
        
        # Extract class and method names from context
        class_name = context[:class_name] || 'UnknownClass'
        method_name = context[:method_name] || 'unknown_method'
        
        puts "🔍 Debug: class_name = #{class_name}, method_name = #{method_name}"
        
        # Use MCP tool to generate fix
        if defined?(CodeFixTool)
          result = CodeFixTool.call(
            error_type: error.class.name,
            error_message: error.message,
            class_name: class_name,
            method_name: method_name,
            analysis: analysis,
            context: context,
            server_context: { 
              codebase_context: @codebase_context,
              business_rules: @business_rules
            }
          )
          
          puts "✅ MCP generated intelligent fix"
          # Parse the JSON response from MCP tool
          JSON.parse(result.content.first[:text])
        else
          puts "⚠️  CodeFixTool not available, using fallback fix generation"
          # Fallback fix generation
          generate_fallback_fix(error, class_name, method_name)
        end
      end
      
      private
      
      def generate_fallback_fix(error, class_name, method_name)
        case error.class.name
        when 'ZeroDivisionError'
          {
            fix_type: 'input_validation',
            code: "def #{method_name}(a, b)\n  return 0 if b == 0\n  a / b\nend",
            description: "Added zero division check",
            risk_level: 'low'
          }
        when 'NoMethodError'
          {
            fix_type: 'nil_check',
            code: "def #{method_name}(items)\n  return 0 if items.nil? || items.empty?\n  items.sum { |item| item[:price] * item[:quantity] }\nend",
            description: "Added nil and empty checks",
            risk_level: 'low'
          }
        else
          {
            fix_type: 'error_handling',
            code: "def #{method_name}(*args)\n  begin\n    # Original implementation\n    super\n  rescue => e\n    Rails.logger.error(\"Error in #{method_name}: \#{e.message}\")\n    raise e\n  end\nend",
            description: "Added error handling wrapper",
            risk_level: 'medium'
          }
        end
      end
      
      def load_codebase_context
        business_context_file = Rails.root.join('config', 'business_context.yml')
        
        if File.exist?(business_context_file)
          YAML.load_file(business_context_file)
        else
          # Fallback to default context
          {
            project_type: 'Rails Application',
            business_domain: 'Self-Evolving System',
            coding_standards: {
              error_handling: 'comprehensive',
              logging: 'detailed',
              validation: 'strict',
              performance: 'optimized'
            },
            common_patterns: {
              calculator_operations: {
                divide: 'should handle zero division gracefully',
                multiply: 'should handle overflow',
                add: 'should handle type conversion'
              }
            }
          }
        end
      end
      
      def load_business_rules
        # Load from YAML config
        business_context_file = Rails.root.join('config', 'business_context.yml')
        yaml_rules = {}
        
        # Also load from business requirements documents
        markdown_rules = load_business_requirements_from_markdown
        
        # Prefer only markdown-derived requirements
        yaml_rules.merge(markdown_rules)
      end
      
      def load_business_requirements_from_markdown
        requirements = {}
        
        # Look for business requirements in various locations
        search_paths = [
          'business_requirements',
          'docs/business_requirements',
          'requirements',
          'docs/requirements'
        ]
        
        search_paths.each do |path|
          if Dir.exist?(path)
            Dir.glob("#{path}/**/*.md").each do |file|
              content = File.read(file)
              # Simply include the content without rigid pattern matching
              requirements['markdown_requirements'] ||= []
              requirements['markdown_requirements'] << {
                file: file,
                content: content.strip
              }
            end
          end
        end
        
        requirements
      end
      
      def analyze_class(class_name)
        {
          name: class_name,
          type: determine_class_type(class_name),
          responsibilities: analyze_class_responsibilities(class_name),
          complexity: calculate_class_complexity(class_name),
          test_coverage: get_test_coverage(class_name),
          documentation: get_documentation_status(class_name)
        }
      end
      
      def analyze_method(class_name, method_name)
        {
          name: method_name,
          signature: get_method_signature(class_name, method_name),
          complexity: calculate_method_complexity(class_name, method_name),
          usage_patterns: analyze_usage_patterns(class_name, method_name),
          performance: analyze_performance_characteristics(class_name, method_name),
          error_prone_areas: identify_error_prone_areas(class_name, method_name)
        }
      end
      
      def find_dependencies(class_name)
        {
          models: find_model_dependencies(class_name),
          services: find_service_dependencies(class_name),
          external_apis: find_external_api_dependencies(class_name),
          database: find_database_dependencies(class_name),
          gems: find_gem_dependencies(class_name)
        }
      end
      
      def get_business_context(class_name)
        {
          domain: determine_business_domain(class_name),
          criticality: assess_business_criticality(class_name),
          regulatory_requirements: identify_regulatory_requirements(class_name),
          sla_requirements: get_sla_requirements(class_name),
          user_impact: assess_user_impact(class_name)
        }
      end
      
      def get_evolution_history(class_name, method_name)
        {
          previous_evolutions: get_previous_evolutions(class_name, method_name),
          success_rate: calculate_evolution_success_rate(class_name, method_name),
          common_patterns: identify_common_evolution_patterns(class_name, method_name),
          performance_impact: analyze_historical_performance_impact(class_name, method_name)
        }
      end
      
      def find_similar_patterns(class_name, method_name)
        {
          similar_methods: find_similar_methods(class_name, method_name),
          similar_errors: find_similar_errors(class_name, method_name),
          best_practices: find_best_practices(class_name, method_name),
          anti_patterns: identify_anti_patterns(class_name, method_name)
        }
      end
      
      # Helper methods (simplified for brevity)
      def determine_class_type(class_name)
        if class_name.include?('Controller')
          'controller'
        elsif class_name.include?('Service')
          'service'
        elsif class_name.include?('Model')
          'model'
        else
          'utility'
        end
      end
      
      def analyze_class_responsibilities(class_name)
        ['data_processing', 'business_logic', 'error_handling']
      end
      
      def calculate_class_complexity(class_name)
        rand(1..10)
      end
      
      def get_test_coverage(class_name)
        rand(0..100)
      end
      
      def get_documentation_status(class_name)
        ['well_documented', 'partially_documented', 'undocumented'].sample
      end
      
      def get_method_signature(class_name, method_name)
        "def #{method_name}(*args, **kwargs, &block)"
      end
      
      def calculate_method_complexity(class_name, method_name)
        rand(1..5)
      end
      
      def analyze_usage_patterns(class_name, method_name)
        ['frequently_called', 'rarely_called', 'critical_path'].sample
      end
      
      def analyze_performance_characteristics(class_name, method_name)
        ['fast', 'moderate', 'slow'].sample
      end
      
      def identify_error_prone_areas(class_name, method_name)
        ['input_validation', 'external_dependencies', 'data_processing'].sample
      end
      
      def find_model_dependencies(class_name)
        []
      end
      
      def find_service_dependencies(class_name)
        []
      end
      
      def find_external_api_dependencies(class_name)
        []
      end
      
      def find_database_dependencies(class_name)
        []
      end
      
      def find_gem_dependencies(class_name)
        []
      end
      
      def determine_business_domain(class_name)
        ['finance', 'ecommerce', 'user_management', 'data_processing'].sample
      end
      
      def assess_business_criticality(class_name)
        ['high', 'medium', 'low'].sample
      end
      
      def identify_regulatory_requirements(class_name)
        []
      end
      
      def get_sla_requirements(class_name)
        '99.9%'
      end
      
      def assess_user_impact(class_name)
        ['high', 'medium', 'low'].sample
      end
      
      def get_previous_evolutions(class_name, method_name)
        []
      end
      
      def calculate_evolution_success_rate(class_name, method_name)
        rand(0.7..1.0)
      end
      
      def identify_common_evolution_patterns(class_name, method_name)
        []
      end
      
      def analyze_historical_performance_impact(class_name, method_name)
        'improved'
      end
      
      def find_similar_methods(class_name, method_name)
        []
      end
      
      def find_similar_errors(class_name, method_name)
        []
      end
      
      def find_best_practices(class_name, method_name)
        []
      end
      
      def identify_anti_patterns(class_name, method_name)
        []
      end
    end
  end
end 