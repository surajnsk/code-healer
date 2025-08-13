require 'git'

module CodeHealer
  class GlobalHandler
    def self.setup_global_error_handling
      # Override the default exception handler for unhandled exceptions
      at_exit do
        if $!
          handle_global_error($!)
        end
      end
      
      # Set up a global error handler for specific error types
      setup_method_error_handling
    end
    
    def self.setup_method_error_handling
      # Override method_missing to catch NoMethodError
      Object.class_eval do
        alias_method :original_method_missing, :method_missing
        
        def method_missing(method_name, *args, &block)
          begin
            original_method_missing(method_name, *args, &block)
          rescue NoMethodError => e
            CodeHealer::GlobalHandler.handle_method_error(e, self.class, method_name)
            raise e # Re-raise the error after handling
          end
        end
      end
    end
    
    def self.handle_global_error(error)
      puts "\n=== Global Error Handler Triggered ==="
      puts "Error: #{error.class} - #{error.message}"
      
      # Get the backtrace to find the file and method
      if error.backtrace && error.backtrace.first
        file_line = error.backtrace.first
        if file_line =~ /(.+):(\d+):in `(.+)'/
          file_path = $1
          line_number = $2
          method_name = $3
          
          # Try to determine the class name from the file path
          class_name = determine_class_name(file_path)
          
          if class_name && method_name
            puts "File: #{file_path}"
            puts "Class: #{class_name}"
            puts "Method: #{method_name}"
            
            # Handle the error using our evolution system
            handle_method_error(error, class_name, method_name, file_path)
          end
        end
      end
    end
    
    def self.handle_method_error(error, class_name, method_name, file_path = nil)
      puts "\n=== Method Error Handler Triggered ==="
      puts "Error: #{error.class} - #{error.message}"
      puts "Class: #{class_name}"
      puts "Method: #{method_name}"
      
      # If file_path is not provided, try to find it
      unless file_path
        file_path = find_file_for_class(class_name)
      end
      
      if file_path && File.exist?(file_path)
        puts "File: #{file_path}"
        
        # Use our evolution system to fix the method
        success = CodeHealer::ReliableEvolution.handle_error(
          error, 
          class_name, 
          method_name, 
          file_path
        )
        
        if success
          puts "✅ Method evolution successful!"
          # Reload the class to get the updated method
          load file_path
        else
          puts "❌ Method evolution failed"
        end
      else
        puts "Could not find file for class: #{class_name}"
      end
    end
    
    private
    
    def self.determine_class_name(file_path)
      return nil unless File.exist?(file_path)
      
      content = File.read(file_path)
      if content =~ /class\s+(\w+)/
        return $1
      end
      
      nil
    end
    
    def self.find_file_for_class(class_name)
      # Look in common Rails directories
      search_paths = [
        'app/models',
        'app/controllers',
        'app/services',
        'lib'
      ]
      
      search_paths.each do |path|
        if Dir.exist?(path)
          Dir.glob("#{path}/**/*.rb").each do |file|
            content = File.read(file)
            if content =~ /class\s+#{class_name}/
              return file
            end
          end
        end
      end
      
      nil
    end
  end
end 