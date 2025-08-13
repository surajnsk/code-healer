module CodeHealer
  # Business Context Analyzer
  # Reads business context from files and applies business rules before evolution
  # Works like a developer analyzing business requirements before fixing bugs
  class BusinessContextAnalyzer
    class << self
      
      def analyze_error_for_business_context(error, class_name, method_name, file_path)
        puts "🔍 DEBUG: analyze_error_for_business_context called with:"
        puts "   - error: #{error.class} (#{error.message})"
        puts "   - class_name: #{class_name.inspect}"
        puts "   - method_name: #{method_name.inspect}"
        puts "   - file_path: #{file_path.inspect}"
        
        puts "🔍 Analyzing business context for #{class_name}##{method_name} error..."
        
        # Load business context from various sources
        puts "   🔍 DEBUG: About to call load_business_context..."
        business_context = load_business_context(file_path, class_name, method_name)
        puts "   🔍 DEBUG: load_business_context returned: #{business_context.keys}"
        
        # Analyze the error against business rules
        puts "   🔍 DEBUG: About to call analyze_error_against_business_rules..."
        analysis_result = analyze_error_against_business_rules(error, business_context, class_name, method_name)
        puts "   🔍 DEBUG: analyze_error_against_business_rules returned: #{analysis_result.keys}"
        
        # Determine evolution strategy based on business context
        puts "   🔍 DEBUG: About to call determine_evolution_strategy..."
        evolution_strategy = determine_evolution_strategy(analysis_result, error, class_name, method_name)
        puts "   🔍 DEBUG: determine_evolution_strategy returned: #{evolution_strategy.keys}"
        
        puts "   📋 Business context analysis complete"
        puts "   🎯 Evolution strategy: #{evolution_strategy[:strategy]}"
        puts "   💼 Business impact: #{evolution_strategy[:business_impact]}"
        
        {
          business_context: business_context,
          analysis: analysis_result,
          evolution_strategy: evolution_strategy
        }
      end
      
      private
      
      def load_business_context(file_path, class_name, method_name)
        puts "     🔍 DEBUG: load_business_context called with:"
        puts "       - file_path: #{file_path.inspect}"
        puts "       - class_name: #{class_name.inspect}"
        puts "       - method_name: #{method_name.inspect}"
        
        puts "     🔍 DEBUG: About to call load_requirements_documents..."
        requirements = load_requirements_documents(file_path, class_name, method_name)
        puts "     🔍 DEBUG: load_requirements_documents returned #{requirements.length} documents"
        
        puts "     🔍 DEBUG: About to call load_business_rules_documents..."
        business_rules = load_business_rules_documents(file_path, class_name, method_name)
        puts "     🔍 DEBUG: load_business_rules_documents returned #{business_rules.length} documents"
        
        puts "     🔍 DEBUG: About to call load_error_handling_documents..."
        error_handling = load_error_handling_documents(file_path, class_name, method_name)
        puts "     🔍 DEBUG: load_error_handling_documents returned #{error_handling.length} documents"
        
        puts "     🔍 DEBUG: About to call load_user_experience_documents..."
        user_experience = load_user_experience_documents(file_path, class_name, method_name)
        puts "     🔍 DEBUG: load_user_experience_documents returned #{user_experience.length} documents"
        
        puts "     🔍 DEBUG: About to call load_domain_specific_context..."
        domain_specific = load_domain_specific_context(class_name, method_name)
        puts "     🔍 DEBUG: load_domain_specific_context returned: #{domain_specific.inspect}"
        
        context = {
          requirements: requirements,
          business_rules: business_rules,
          error_handling: error_handling,
          user_experience: user_experience,
          domain_specific: domain_specific
        }
        
        puts "     🔍 DEBUG: Final context keys: #{context.keys}"
        puts "     🔍 DEBUG: Total sources: #{context.values.flatten.length}"
        puts "   📚 Loaded business context from #{context.values.flatten.length} sources"
        context
      end
      
      def load_requirements_documents(file_path, class_name = nil, method_name = nil)
        documents = []
        puts "       🔍 DEBUG: load_requirements_documents called with file_path: #{file_path.inspect}, class_name: #{class_name.inspect}, method_name: #{method_name.inspect}"
        
        # Look for requirements documents in various locations
        search_paths = [
          File.dirname(file_path),
          Rails.root.join('business_requirements'),
          Rails.root.join('docs'),
          Rails.root.join('requirements'),
          Rails.root.join('PRD'),
          Rails.root.join('specs')
        ]
        
        search_paths.each do |search_path|
          next unless Dir.exist?(search_path)
          
          Dir.glob(File.join(search_path, '**/*.{md,txt,yml,yaml}')).each do |doc_path|
            next unless File.readable?(doc_path)
            
            content = File.read(doc_path)
            if content.match?(/requirement|must|should|shall/i)
              relevance = class_name && method_name ? calculate_relevance(content, class_name, method_name) : 0.5
              documents << {
                path: doc_path,
                type: 'requirement',
                content: content,
                relevance: relevance
              }
            end
          end
        end
        
        documents.sort_by { |doc| -doc[:relevance] }
      end
      
      def load_business_rules_documents(file_path, class_name = nil, method_name = nil)
        documents = []
        puts "       🔍 DEBUG: load_business_rules_documents called with file_path: #{file_path.inspect}, class_name: #{class_name.inspect}, method_name: #{method_name.inspect}"
        
        # Look for business rules documents
        search_paths = [
          File.dirname(file_path),
          Rails.root.join('business_requirements'),
          Rails.root.join('business_rules'),
          Rails.root.join('rules'),
          Rails.root.join('policies')
        ]
        
        puts "       🔍 DEBUG: Search paths: #{search_paths.map(&:to_s)}"
        
        search_paths.each do |search_path|
          puts "       🔍 DEBUG: Checking search path: #{search_path}"
          puts "       🔍 DEBUG: Directory exists? #{Dir.exist?(search_path)}"
          
          next unless Dir.exist?(search_path)
          
          puts "       🔍 DEBUG: Searching for documents in: #{search_path}"
          found_files = Dir.glob(File.join(search_path, '**/*.{md,txt,yml,yaml}'))
          puts "       🔍 DEBUG: Found #{found_files.length} files: #{found_files.map { |f| File.basename(f) }}"
          
          found_files.each do |doc_path|
            puts "       🔍 DEBUG: Checking file: #{doc_path}"
            puts "       🔍 DEBUG: File readable? #{File.readable?(doc_path)}"
            
            next unless File.readable?(doc_path)
            
            content = File.read(doc_path)
            puts "       🔍 DEBUG: File content preview: #{content[0..100]}..."
            
            if content.match?(/business rule|rule|policy/i)
              puts "       🔍 DEBUG: File matches business rule pattern!"
              relevance = class_name && method_name ? calculate_relevance(content, class_name, method_name) : 0.5
              documents << {
                path: doc_path,
                type: 'business_rule',
                content: content,
                relevance: relevance
              }
            else
              puts "       🔍 DEBUG: File does NOT match business rule pattern"
            end
          end
        end
        
        puts "       🔍 DEBUG: Total business rule documents found: #{documents.length}"
        documents.sort_by { |doc| -doc[:relevance] }
      end
      
      def load_error_handling_documents(file_path, class_name = nil, method_name = nil)
        documents = []
        
        # Look for error handling documentation
        search_paths = [
          File.dirname(file_path),
          Rails.root.join('docs'),
          Rails.root.join('error_handling'),
          Rails.root.join('troubleshooting')
        ]
        
        search_paths.each do |search_path|
          next unless Dir.exist?(search_path)
          
          Dir.glob(File.join(search_path, '**/*.{md,txt,yml,yaml}')).each do |doc_path|
            next unless File.readable?(doc_path)
            
            content = File.read(doc_path)
            if content.match?(/error|exception|failure|nil|null/i)
              relevance = class_name && method_name ? calculate_relevance(content, class_name, method_name) : 0.5
              documents << {
                path: doc_path,
                type: 'error_handling',
                content: content,
                relevance: relevance
              }
            end
          end
        end
        
        documents.sort_by { |doc| -doc[:relevance] }
      end
      
      def load_user_experience_documents(file_path, class_name = nil, method_name = nil)
        documents = []
        
        # Look for UX documentation
        search_paths = [
          File.dirname(file_path),
          Rails.root.join('docs'),
          Rails.root.join('ux'),
          Rails.root.join('user_experience')
        ]
        
        search_paths.each do |search_path|
          next unless Dir.exist?(search_path)
          
          Dir.glob(File.join(search_path, '**/*.{md,txt,yml,yaml}')).each do |doc_path|
            next unless File.readable?(doc_path)
            
            content = File.read(doc_path)
            if content.match?(/user experience|ux|user interface|ui/i)
              relevance = class_name && method_name ? calculate_relevance(content, class_name, method_name) : 0.5
              documents << {
                path: doc_path,
                type: 'user_experience',
                content: content,
                relevance: relevance
              }
            end
          end
        end
        
        documents.sort_by { |doc| -doc[:relevance] }
      end
      
      def load_domain_specific_context(class_name, method_name)
        # Load domain-specific business context
        domain = determine_domain(class_name)
        
        case domain
        when 'order_management'
          load_order_management_context(class_name, method_name)
        when 'user_management'
          load_user_management_context(class_name, method_name)
        when 'payment_processing'
          load_payment_processing_context(class_name, method_name)
        when 'calculator_operations'
          load_calculator_context(class_name, method_name)
        else
          load_general_context(class_name, method_name)
        end
      end
      
      def load_order_management_context(class_name, method_name)
        context = {}

        if method_name.to_s.include?('validate')
          context[:validation_rules] = [
            'All order items must have valid price and quantity',
            'Validation errors should provide clear user feedback',
            'System should not crash due to invalid data'
          ]
        end
        
        context
      end
      
      def load_calculator_context(class_name, method_name)
        context = {}
        
        if method_name.to_s.include?('divide')
          context[:division_rules] = [
            'Division by zero should be handled gracefully',
            'Return appropriate fallback values',
            'Log division errors for audit purposes'
          ]
        end
        
        context
      end
      
      def load_general_context(class_name, method_name)
        {
          general_rules: [
            'Errors should not crash the system',
            'Provide meaningful error messages',
            'Maintain system stability'
          ]
        }
      end
      
      def calculate_relevance(content, class_name, method_name)
        relevance = 0.0
        
        # Check for class name mentions
        if content.downcase.include?(class_name.downcase)
          relevance += 0.4
        end
        
        # Check for method name mentions
        if content.downcase.include?(method_name.to_s.downcase)
          relevance += 0.3
        end
        
        # Check for related terms
        related_terms = ['error', 'exception', 'nil', 'validation', 'calculation']
        related_terms.each do |term|
          if content.downcase.include?(term)
            relevance += 0.1
          end
        end
        
        relevance
      end
      
      def determine_domain(class_name)
        case class_name.to_s.downcase
        when /order|payment|invoice/
          'order_management'
        when /user|auth|session/
          'user_management'
        when /payment|transaction|gateway/
          'payment_processing'
        when /calculator|math|compute/
          'calculator_operations'
        else
          'general'
        end
      end
      
      def analyze_error_against_business_rules(error, business_context, class_name, method_name)
        analysis = {
          error_type: error.class.name,
          error_message: error.message,
          business_impact: 'unknown',
          user_experience_impact: 'unknown',
          compliance_issues: [],
          recommended_actions: []
        }
        
        # Analyze business impact
        analysis[:business_impact] = assess_business_impact(error, business_context, class_name, method_name)
        
        # Analyze user experience impact
        analysis[:user_experience_impact] = assess_user_experience_impact(error, business_context, class_name, method_name)
        
        # Check compliance with business rules
        analysis[:compliance_issues] = check_compliance(error, business_context, class_name, method_name)
        
        # Generate recommended actions
        analysis[:recommended_actions] = generate_recommended_actions(error, business_context, class_name, method_name)
        
        analysis
      end
      
      def assess_business_impact(error, business_context, class_name, method_name)
        error_text = error.message.downcase
        
        if error_text.include?('nil') || error_text.include?('null')
          # Check if this is a critical business operation
          if method_name.to_s.include?('calculate') || method_name.to_s.include?('total')
            return 'high' # Critical business operation
          else
            return 'medium' # Standard operation
          end
        elsif error_text.include?('division') || error_text.include?('zero')
          return 'medium' # Mathematical operation error
        else
          return 'low' # General error
        end
      end
      
      def assess_user_experience_impact(error, business_context, class_name, method_name)
        error_text = error.message.downcase
        
        if error_text.include?('nil') || error_text.include?('null')
          return 'high' # User will see broken functionality
        elsif error_text.include?('division') || error_text.include?('zero')
          return 'medium' # Mathematical error, may be confusing
        else
          return 'low' # General error
        end
      end
      
      def check_compliance(error, business_context, class_name, method_name)
        compliance_issues = []
        
        # Check against business rules
        business_context[:business_rules].each do |rule|
          if rule[:content].downcase.include?('must') || rule[:content].downcase.include?('shall')
            if !rule[:content].downcase.include?('error') && !rule[:content].downcase.include?('exception')
              compliance_issues << "Business rule violation: #{rule[:content][0..100]}..."
            end
          end
        end
        
        compliance_issues
      end
      
      def generate_recommended_actions(error, business_context, class_name, method_name)
        actions = []
        
        # Analyze error type and suggest actions
        if error.message.downcase.include?('nil') || error.message.downcase.include?('null')
          actions << 'Implement nil value validation'
          actions << 'Add default value handling'
          actions << 'Provide user-friendly error messages'
        end
        
        if error.message.downcase.include?('division') || error.message.downcase.include?('zero')
          actions << 'Add division by zero protection'
          actions << 'Implement mathematical error handling'
          actions << 'Return appropriate fallback values'
        end
        
        # Add business rule specific actions
        business_context[:business_rules].each do |rule|
          if rule[:content].downcase.include?('return') && rule[:content].downcase.include?('nil')
            actions << "Apply business rule: #{rule[:content][0..100]}..."
          end
        end
        
        actions.uniq
      end
      
      def determine_evolution_strategy(analysis_result, error, class_name, method_name)
        strategy = {
          strategy: 'standard_error_handling',
          business_impact: analysis_result[:business_impact],
          user_experience_impact: analysis_result[:user_experience_impact],
          priority: 'normal',
          approach: 'defensive_programming'
        }
        
        # Determine strategy based on business impact
        case analysis_result[:business_impact]
        when 'high'
          strategy[:strategy] = 'business_critical_fix'
          strategy[:priority] = 'high'
          strategy[:approach] = 'robust_error_handling'
        when 'medium'
          strategy[:strategy] = 'enhanced_error_handling'
          strategy[:priority] = 'medium'
          strategy[:approach] = 'graceful_degradation'
        when 'low'
          strategy[:strategy] = 'standard_error_handling'
          strategy[:priority] = 'low'
          strategy[:approach] = 'basic_error_handling'
        end
        
        # Adjust based on user experience impact
        if analysis_result[:user_experience_impact] == 'high'
          strategy[:approach] = 'user_experience_focused'
        end
        
        strategy
      end
    end
  end
end
