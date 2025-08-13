module CodeHealer
  # Context-Aware Prompt Builder for Large Applications
  # Builds intelligent prompts using rich business context
  class ContextAwarePromptBuilder
    class << self
      def build_error_fix_prompt(error, class_name, method_name, context)
        business_context = context[:business_context]
        domain_context = context[:domain_context]
        method_context = context[:method_specific_context]
        
        <<~PROMPT
          You are an expert Ruby developer and code evolution specialist for a #{business_context['project']['business_domain']} application.
          
          ## ERROR DETAILS
          Type: #{error.class.name}
          Message: #{error.message}
          Class: #{class_name}
          Method: #{method_name}
          
          ## BUSINESS CONTEXT
          #{build_business_context_section(business_context, domain_context)}
          
          ## METHOD-SPECIFIC CONTEXT
          #{build_method_context_section(method_context, method_name)}
          
          ## DOMAIN REQUIREMENTS
          #{build_domain_requirements_section(domain_context, business_context)}
          
          ## CODING STANDARDS
          #{build_coding_standards_section(business_context)}
          
          ## ERROR-SPECIFIC REQUIREMENTS
          #{build_error_specific_requirements(error, business_context)}
          
          ## CODE REQUIREMENTS
          - Generate ONLY the complete method implementation (def #{method_name}...end)
          - Include comprehensive error handling specific to #{error.class.name}
          - Add business-appropriate logging using Rails.logger
          - Include input validation and parameter checking
          - Follow Ruby best practices and conventions
          - Ensure the fix is production-ready and secure
          - Add performance considerations where relevant
          - Include proper return values and error responses
          - Use the exact method name: #{method_name}
          - Consider domain-specific business rules and compliance requirements
          
          Generate a complete, intelligent fix for the #{method_name} method that specifically addresses the #{error.class.name}:
        PROMPT
      end
      
      private
      
      def build_business_context_section(business_context, domain_context)
        return "No business context available." unless business_context
        
        <<~CONTEXT
          **Project**: #{business_context['project']['description']}
          **Domain**: #{domain_context || 'General'}
          **Criticality**: #{business_context['class_specific']&.dig('business_criticality') || 'medium'}
          **Data Privacy**: #{business_context['class_specific']&.dig('data_privacy') || 'standard'}
          **SLA Requirements**: #{business_context['domain_config']&.dig('sla_requirements') || '99.9%'}
          **Compliance**: #{business_context['domain_config']&.dig('compliance')&.join(', ') || 'Standard'}
        CONTEXT
      end
      
      def build_method_context_section(method_context, method_name)
        return "No method-specific context available." unless method_context
        
        <<~METHOD
          **Method Description**: #{method_context['description'] || "Auto-inferred method: #{method_name}"}
          **Error Handling Strategy**: #{method_context['error_handling'] || 'graceful_handling'}
          **Logging Level**: #{method_context['logging'] || 'info'}
          **Return Values**: #{format_return_values(method_context['return_values'])}
        METHOD
      end
      
      def build_domain_requirements_section(domain_context, business_context)
        return "No domain-specific requirements." unless domain_context
        
        domain_config = business_context['domain_config']
        return "No domain configuration available." unless domain_config
        
        <<~DOMAIN
          **Domain**: #{domain_context}
          **Description**: #{domain_config['description']}
          **Criticality**: #{domain_config['criticality']}
          **Data Consistency**: #{domain_config['data_consistency'] || 'standard'}
          **Security Level**: #{domain_config['security'] || 'standard'}
          **Performance Requirements**: #{format_performance_requirements(domain_context, business_context)}
        DOMAIN
      end
      
      def build_coding_standards_section(business_context)
        return "No coding standards defined." unless business_context['coding_standards']
        
        standards = business_context['coding_standards']
        
        <<~STANDARDS
          **Error Handling**: #{standards['error_handling']}
          **Logging**: #{standards['logging']}
          **Validation**: #{standards['validation']}
          **Performance**: #{standards['performance']}
          **Security**: #{standards['security']}
          **Documentation**: #{standards['documentation']}
          **Testing**: #{standards['testing']}
        STANDARDS
      end
      
      def build_error_specific_requirements(error, business_context)
        # Previously extracted structured error rules removed. Use textual markdown/business context only.
        error_rules = nil
        
        if error_rules
          <<~ERROR
            **Strategy**: #{error_rules['strategy']}
            **Return Value**: #{error_rules['return_value']}
            **Logging**: #{error_rules['logging']}
            **User Experience**: #{error_rules['user_experience']}
            **Business Impact**: #{error_rules['business_impact']}
            **Default Return**: #{error_rules['default_return']}
          ERROR
        else
          <<~ERROR
            **Strategy**: defensive_programming
            **Return Value**: nil_or_default
            **Logging**: error_level
            **User Experience**: graceful_degradation
            **Business Impact**: variable
          ERROR
        end
      end
      
      def format_return_values(return_values)
        return "Standard return values" unless return_values
        
        return_values.map { |key, value| "#{key}: #{value}" }.join(", ")
      end
      
      def format_performance_requirements(domain_context, business_context)
        performance_config = business_context['performance_requirements']&.dig(domain_context)
        
        if performance_config
          "Response Time: #{performance_config['response_time']}, " \
          "Memory: #{performance_config['memory_usage']}, " \
          "CPU: #{performance_config['cpu_usage']}, " \
          "DB Queries: #{performance_config['database_queries']}"
        else
          "Standard performance requirements"
        end
      end
    end
  end
end 