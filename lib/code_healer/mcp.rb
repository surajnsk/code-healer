# frozen_string_literal: true

module CodeHealer
  module MCP
    # Base class for MCP tools
    class Tool
      class << self
        def description(desc = nil)
          @description = desc if desc
          @description
        end
        
        def input_schema(schema = nil)
          @input_schema = schema if schema
          @input_schema
        end
        
        def annotations(annotations = nil)
          @annotations = annotations if annotations
          @annotations
        end
      end
    end
    
    # Response class for MCP tools
    class Tool::Response
      attr_reader :content
      
      def initialize(content)
        @content = content
      end
    end
    
    # Base class for MCP prompts
    class Prompt
      class << self
        def prompt_name(name = nil)
          @prompt_name = name if name
          @prompt_name
        end
        
        def description(desc = nil)
          @description = desc if desc
          @description
        end
        
        def arguments(args = nil)
          @arguments = args if args
          @arguments
        end
      end
    end
    
    # Argument class for MCP prompts
    class Prompt::Argument
      attr_reader :name, :description, :required
      
      def initialize(name:, description:, required: false)
        @name = name
        @description = description
        @required = required
      end
    end
    
    # Result class for MCP prompts
    class Prompt::Result
      attr_reader :description, :messages
      
      def initialize(description:, messages:)
        @description = description
        @messages = messages
      end
    end
    
    # Message class for MCP prompts
    class Prompt::Message
      attr_reader :role, :content
      
      def initialize(role:, content:)
        @role = role
        @content = content
      end
    end
    
    # Content classes for MCP prompts
    module Content
      class Text
        attr_reader :text
        
        def initialize(text)
          @text = text
        end
      end
    end
    
    # Server class for MCP
    class Server
      attr_reader :name, :version, :tools, :server_context
      
      def initialize(name:, version:, tools:, server_context:)
        @name = name
        @version = version
        @tools = tools
        @server_context = server_context
      end
    end
  end
end
