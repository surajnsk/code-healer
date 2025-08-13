module CodeHealer
  # Dynamic Business Context Loader for Large Applications
  # Intelligently loads and provides business context for any class/method
  class BusinessContextLoader
    class << self
      def load_context_for_class(class_name)
        context = load_base_context
        domain_context = find_domain_for_class(class_name)
        
        if domain_context
          context.merge!(domain_context)
          context[:class_specific] = load_class_specific_context(class_name, domain_context)
        end
        
        context
      end
      
      def load_context_for_method(class_name, method_name)
        class_context = load_context_for_class(class_name)
        method_context = load_method_specific_context(class_name, method_name, class_context)
        
        class_context.merge!(method_context)
      end
      
      def find_domain_for_class(class_name)
        domains = load_domains_from_config
        
        # Direct class match
        domains.each do |domain_name, domain_config|
          if domain_config['classes']&.key?(class_name)
            return {
              domain: domain_name,
              domain_config: domain_config,
              class_config: domain_config['classes'][class_name]
            }
          end
        end
        
        # Pattern matching for similar classes
        domains.each do |domain_name, domain_config|
          if matches_domain_pattern?(class_name, domain_name)
            return {
              domain: domain_name,
              domain_config: domain_config,
              class_config: infer_class_config(class_name, domain_config)
            }
          end
        end
        
        # Default domain based on class name patterns
        default_domain = infer_default_domain(class_name)
        if default_domain && domains[default_domain]
          return {
            domain: default_domain,
            domain_config: domains[default_domain],
            class_config: infer_class_config(class_name, domains[default_domain])
          }
        end
        
        nil
      end
      
      def load_method_specific_context(class_name, method_name, class_context)
        return {} unless class_context[:class_config]
        
        method_config = class_context[:class_config]['methods']&.dig(method_name)
        
        if method_config
          {
            method_specific: method_config,
            error_handling: method_config['error_handling'],
            logging: method_config['logging'],
            return_values: method_config['return_values']
          }
        else
          # Infer method context based on method name patterns
          infer_method_context(method_name, class_context)
        end
      end
      
      private
      
      def load_base_context
        business_context_file = Rails.root.join('config', 'business_context.yml')
        
        if File.exist?(business_context_file)
          YAML.load_file(business_context_file)
        else
          default_context
        end
      end
      
      def load_domains_from_config
        context = load_base_context
        context['domains'] || {}
      end
      
      def load_class_specific_context(class_name, domain_context)
        domain_context[:class_config] || infer_class_config(class_name, domain_context[:domain_config])
      end
      
      def matches_domain_pattern?(class_name, domain_name)
        patterns = {
          'user_management' => /User|Session|Auth|Profile/,
          'inventory_management' => /Product|Inventory|Stock|Catalog/,
          'order_management' => /Order|Cart|Checkout|Fulfillment/,
          'payment_processing' => /Payment|Transaction|Gateway|Refund/,
          'analytics_reporting' => /Analytics|Report|Metrics|Dashboard/
        }
        
        pattern = patterns[domain_name]
        pattern&.match?(class_name)
      end
      
      def infer_default_domain(class_name)
        case class_name
        when /User|Session|Auth/
          'user_management'
        when /Product|Inventory|Stock/
          'inventory_management'
        when /Order|Cart|Checkout/
          'order_management'
        when /Payment|Transaction/
          'payment_processing'
        when /Analytics|Report|Metrics/
          'analytics_reporting'
        else
          'general'
        end
      end
      
      def infer_class_config(class_name, domain_config)
        {
          'description' => "Auto-inferred configuration for #{class_name}",
          'business_criticality' => domain_config['criticality'] || 'medium',
          'data_privacy' => domain_config['data_sensitivity'] || 'standard',
          'methods' => infer_methods_for_class(class_name, domain_config)
        }
      end
      
      def infer_methods_for_class(class_name, domain_config)
        # Common method patterns by domain
        patterns = {
          'user_management' => {
            'authenticate' => {
              'description' => 'User authentication',
              'error_handling' => 'secure_fallback',
              'logging' => 'security_audit'
            },
            'update_profile' => {
              'description' => 'Update user profile',
              'error_handling' => 'validation_errors',
              'logging' => 'audit_trail'
            }
          },
          'inventory_management' => {
            'update_stock' => {
              'description' => 'Update inventory stock',
              'error_handling' => 'stock_validation',
              'logging' => 'inventory_audit'
            },
            'calculate_availability' => {
              'description' => 'Calculate product availability',
              'error_handling' => 'graceful_fallback',
              'logging' => 'inventory_metrics'
            }
          },
          'order_management' => {
            'process_payment' => {
              'description' => 'Process order payment',
              'error_handling' => 'payment_failure',
              'logging' => 'payment_audit'
            },
            'update_status' => {
              'description' => 'Update order status',
              'error_handling' => 'status_validation',
              'logging' => 'order_audit'
            }
          }
        }
        
        domain_name = domain_config['description']&.downcase&.gsub(/\s+/, '_')
        patterns[domain_name] || {}
      end
      
      def infer_method_context(method_name, class_context)
        # Infer based on method name patterns
        case method_name.to_s
        when /authenticate|login/
          {
            method_specific: {
              'description' => 'Authentication method',
              'error_handling' => 'secure_fallback',
              'logging' => 'security_audit',
              'return_values' => {
                'success' => 'user_object',
                'failure' => 'nil_with_logging'
              }
            }
          }
        when /update|save/
          {
            method_specific: {
              'description' => 'Update method',
              'error_handling' => 'validation_errors',
              'logging' => 'audit_trail',
              'return_values' => {
                'success' => 'boolean',
                'validation_failed' => 'errors_hash'
              }
            }
          }
        when /calculate|compute/
          {
            method_specific: {
              'description' => 'Calculation method',
              'error_handling' => 'calculation_error',
              'logging' => 'metrics',
              'return_values' => {
                'success' => 'numeric_result',
                'error' => 'nil_or_default'
              }
            }
          }
        when /process|execute/
          {
            method_specific: {
              'description' => 'Processing method',
              'error_handling' => 'process_failure',
              'logging' => 'process_audit',
              'return_values' => {
                'success' => 'result_object',
                'failure' => 'error_object'
              }
            }
          }
        else
          {
            method_specific: {
              'description' => "Auto-inferred method: #{method_name}",
              'error_handling' => 'graceful_handling',
              'logging' => 'info',
              'return_values' => {
                'success' => 'method_result',
                'error' => 'nil_or_default'
              }
            }
          }
        end
      end
      
      def default_context
        {
          'project' => {
            'type' => 'Rails Application',
            'business_domain' => 'General Application',
            'description' => 'Default business context'
          },
          'coding_standards' => {
            'error_handling' => 'comprehensive',
            'logging' => 'structured',
            'validation' => 'strict',
            'performance' => 'optimized',
            'security' => 'high'
          },
          'business_rules' => {
            # Structured error_resolution removed in favor of markdown requirements
          }
        }
      end
    end
  end
end 