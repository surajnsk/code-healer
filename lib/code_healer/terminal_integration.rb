require 'json'
require 'fileutils'

module CodeHealer
  class TerminalIntegration
    class << self
      def errors_dir
        return nil unless defined?(Rails) && Rails.root
        Rails.root.join('claude_terminal', 'errors')
      end
      
      def fixes_dir
        return nil unless defined?(Rails) && Rails.root
        Rails.root.join('claude_terminal', 'fixes')
      end
      
      def setup_directories
        return unless errors_dir && fixes_dir
        FileUtils.mkdir_p(errors_dir)
        FileUtils.mkdir_p(fixes_dir)
      end
      
      def report_error(error, context = {})
        return nil unless errors_dir
        setup_directories
        
        error_id = generate_error_id
        error_data = {
          timestamp: Time.current.strftime("%Y-%m-%d %H:%M:%S"),
          error_id: error_id,
          error: {
            type: error.class.name,
            message: error.message,
            backtrace: error.backtrace&.first(10)
          },
          context: context,
          app_state: {
            rails_env: defined?(Rails) ? Rails.env : 'unknown',
            request_id: Thread.current[:request_id],
            user_agent: context[:user_agent],
            params: context[:params]
          },
          codebase_context: {
            controller: context[:controller_name],
            action: context[:action_name],
            model: context[:model_name],
            method: context[:method_name]
          }
        }
        
        # Write error for Claude Terminal to process
        File.write(
          errors_dir.join("#{error_id}.json"),
          JSON.pretty_generate(error_data)
        )
        
        if defined?(Rails) && Rails.logger
          Rails.logger.info "🤖 Error reported to Claude Terminal: #{error_id}"
        end
        error_id
      end
      
      def check_for_fix(error_id, timeout: 30)
        return nil unless fixes_dir
        fix_file = fixes_dir.join("#{error_id}_fix.json")
        
        # Wait for Claude Terminal to provide a fix
        timeout.times do
          if File.exist?(fix_file)
            fix_data = JSON.parse(File.read(fix_file))
            File.delete(fix_file) # Clean up
            return fix_data
          end
          sleep 1
        end
        
        nil # No fix available within timeout
      end
      
      private
      
      def self.generate_error_id
        "error_#{Time.current.to_i}_#{SecureRandom.hex(4)}"
      end
    end
  end
end