module CodeHealer
  class ErrorHandler
    class << self
      def handle_error(error, context = {})
        new(error, context).handle
      end
    end

    attr_reader :error, :context, :logger

    def initialize(error, context = {})
      @error = error
      @context = context
      @logger = Logger.new(Rails.root.join('log', 'self_evolving.log'))
      logger.debug("Initializing ErrorHandler with error: #{error.inspect}")
    end

    def handle
      logger.debug("Starting error handling for: #{error.class}")
      return false unless should_handle_error?

      begin
        evolution_context = build_evolution_context
        logger.debug("Evolution context: #{evolution_context.inspect}")
        
        # If we can't determine the class or method, create a test class
        target_class = error_class || create_test_class
        target_method = error_method || 'handle_error'
        
        logger.debug("Target class: #{target_class}, Target method: #{target_method}")
        
        success = Core.evolve_method(target_class, target_method, evolution_context)
        
        if success
          log_successful_repair
          true
        else
          log_failed_repair
          false
        end
      rescue => e
        logger.error("Error handling failed: #{e.message}")
        logger.error(e.backtrace.join("\n"))
        false
      end
    end

    private

    def should_handle_error?
      # During testing, handle all errors
      return true if Rails.env.test? || Rails.env.development?
      
      # In production, only handle specific errors
      error.is_a?(NoMethodError) || error.is_a?(ZeroDivisionError)
    end

    def error_class
      if error.respond_to?(:backtrace_locations)
        # Get the first backtrace location
        location = error.backtrace_locations&.first
        return create_test_class unless location

        # Get the label (method name) from the backtrace
        label = location.label
        return create_test_class unless label

        # Try to get the class name from the label
        if label.include?('#')
          class_name = label.split('#').first
          # Only try to constantize if it looks like a valid class name
          if class_name =~ /^[A-Z]/
            begin
              return class_name.constantize
            rescue NameError
              logger.debug("Could not constantize class name: #{class_name}")
            end
          end
        end
      end
      
      # If we couldn't determine the class, use the test class
      create_test_class
    end

    def error_method
      if error.respond_to?(:backtrace_locations)
        location = error.backtrace_locations&.first
        return 'handle_error' unless location

        label = location.label
        return 'handle_error' unless label

        if label.include?('#')
          method_name = label.split('#').last
          return method_name if method_name =~ /^[a-z]/
        end
      end
      
      'handle_error'
    end

    def create_test_class
      # Create a test class if we can't determine the original class
      Class.new do
        def self.name
          'TestClass'
        end
      end
    end

    def build_evolution_context
      {
        error_type: error.class.name,
        error_message: error.to_s,
        backtrace: error.respond_to?(:backtrace) ? error.backtrace&.first(5) : [],
        context: context
      }
    end

    def log_successful_repair
      logger.info({
        timestamp: Time.current,
        event: 'successful_repair',
        error_type: error.class.name,
        class: error_class&.name,
        method: error_method
      }.to_json)
    end

    def log_failed_repair
      logger.info({
        timestamp: Time.current,
        event: 'failed_repair',
        error_type: error.class.name,
        class: error_class&.name,
        method: error_method
      }.to_json)
    end
  end
end 