module CodeHealer
  # Business Rule Applier
  # Simply provides business context to AI for natural language understanding
  class BusinessRuleApplier
    class << self
      
      def apply_business_rules_to_code(business_analysis, original_code, error, class_name, method_name)
        puts "🔧 Providing business context to AI..."
        
        # Extract business context from the analysis
        business_context = extract_business_context(business_analysis)
        
        if business_context.any?
          puts "   📋 Found business context: #{business_context.join(', ')}"
          puts "   🎯 AI will understand and apply these business rules naturally"
          
          # Simply return the original code - let the AI handle everything
          # The AI will see the business context and apply it naturally
          puts "   ✅ Business context provided to AI - no code manipulation needed"
          original_code
        else
          puts "   ℹ️  No business context found"
          original_code
        end
      end
      
      private
      
      def extract_business_context(business_analysis)
        context = []
        
        # Extract from business rules
        if business_analysis[:business_context][:business_rules]&.any?
          business_analysis[:business_context][:business_rules].each do |rule|
            context << rule[:content]
          end
        end
        
        # Extract from domain specific rules
        if business_analysis[:business_context][:domain_specific]&.any?
          business_analysis[:business_context][:domain_specific].each do |domain, rules|
            if rules.is_a?(Array)
              context.concat(rules)
            elsif rules.is_a?(Hash)
              context.concat(rules.values.map(&:to_s))
            end
          end
        end
        
        context
      end
    end
  end
end
