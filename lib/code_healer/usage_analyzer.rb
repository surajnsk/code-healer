module CodeHealer
  class UsageAnalyzer
    class << self
      def analyze_usage(klass, usage_data)
        new(klass, usage_data).analyze
      end
    end

    attr_reader :klass, :usage_data, :logger

    def initialize(klass, usage_data)
      @klass = klass
      @usage_data = usage_data
      @logger = Logger.new(Rails.root.join('log', 'self_evolving.log'))
    end

    def analyze
      return false unless valid_usage_data?

      begin
        patterns = detect_patterns
        return false if patterns.empty?

        patterns.each do |pattern|
          propose_method(pattern)
        end

        true
      rescue => e
        logger.error("Usage analysis failed: #{e.message}")
        false
      end
    end

    private

    def valid_usage_data?
      # Implement your validation logic here
      # For example: minimum data points, required fields, etc.
      usage_data.is_a?(Array) && usage_data.length >= 5
    end

    def detect_patterns
      # This is where you'd implement your pattern detection logic
      # For now, we'll return a simple example pattern
      [
        {
          type: 'filter',
          frequency: 10,
          parameters: { days: 30 },
          suggested_method: 'active_since'
        }
      ]
    end

    def propose_method(pattern)
      method_name = pattern[:suggested_method]
      context = {
        pattern_type: pattern[:type],
        frequency: pattern[:frequency],
        parameters: pattern[:parameters],
        detected_at: Time.current
      }

      success = Core.evolve_method(klass, method_name, context)

      if success
        log_successful_proposal(pattern)
      else
        log_failed_proposal(pattern)
      end
    end

    def log_successful_proposal(pattern)
      logger.info({
        timestamp: Time.current,
        event: 'successful_proposal',
        class: klass.name,
        pattern: pattern
      }.to_json)
    end

    def log_failed_proposal(pattern)
      logger.info({
        timestamp: Time.current,
        event: 'failed_proposal',
        class: klass.name,
        pattern: pattern
      }.to_json)
    end
  end
end 