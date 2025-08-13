# frozen_string_literal: true

module CodeHealer
  # MCP Prompt for error fixing workflow
  class ErrorFixPrompt < MCP::Prompt
    prompt_name "error_fix_workflow"
    description "Complete workflow for analyzing and fixing errors with context awareness"
    arguments [
      MCP::Prompt::Argument.new(
        name: "error_type",
        description: "Type of error to fix",
        required: true
      ),
      MCP::Prompt::Argument.new(
        name: "error_message",
        description: "Error message details",
        required: true
      ),
      MCP::Prompt::Argument.new(
        name: "class_name",
        description: "Class where error occurred",
        required: true
      ),
      MCP::Prompt::Argument.new(
        name: "method_name",
        description: "Method where error occurred",
        required: true
      )
    ]

    class << self
      def template(args, server_context:)
        context = server_context[:codebase_context]
        
        MCP::Prompt::Result.new(
          description: "Error Fix Workflow for #{args['class_name']}##{args['method_name']}",
          messages: [
            MCP::Prompt::Message.new(
              role: "system",
              content: MCP::Content::Text.new(build_system_prompt(args, context))
            ),
            MCP::Prompt::Message.new(
              role: "user",
              content: MCP::Content::Text.new(build_user_prompt(args, context))
            ),
            MCP::Prompt::Message.new(
              role: "assistant",
              content: MCP::Content::Text.new(build_assistant_response(args, context))
            )
          ]
        )
      end
      
      private
      
      def build_system_prompt(args, context)
        <<~PROMPT
          You are an expert Ruby developer and code evolution specialist. You have access to a comprehensive error analysis and code generation system.
          
          Your role is to:
          1. Analyze errors with rich context
          2. Generate intelligent, production-ready fixes
          3. Validate fixes against business requirements
          4. Provide recommendations for testing and monitoring
          
          Available tools:
          - ErrorAnalysisTool: Analyzes errors with context
          - CodeFixTool: Generates intelligent code fixes
          - ContextAnalysisTool: Validates fixes and provides recommendations
          
          Business Context:
          - Project Type: #{context[:project_type]}
          - Business Domain: #{context[:business_domain]}
          - Coding Standards: #{context[:coding_standards]}
          - Common Patterns: #{context[:common_patterns]}
        PROMPT
      end
      
      def build_user_prompt(args, context)
        <<~PROMPT
          Please analyze and fix the following error:
          
          Error Type: #{args['error_type']}
          Error Message: #{args['error_message']}
          Class: #{args['class_name']}
          Method: #{args['method_name']}
          
          Please provide:
          1. Error analysis with severity and impact assessment
          2. Intelligent code fix that addresses the specific error
          3. Validation of the fix against business requirements
          4. Recommendations for testing and monitoring
        PROMPT
      end
      
      def build_assistant_response(args, context)
        <<~RESPONSE
          I'll help you analyze and fix this error using our intelligent evolution system.
          
          Let me start by analyzing the error with rich context, then generate an intelligent fix, and finally validate it against our business requirements.
          
          This workflow will ensure the fix is:
          - Context-aware and business-appropriate
          - Production-ready with proper error handling
          - Validated for syntax, performance, and security
          - Accompanied by testing and monitoring recommendations
        RESPONSE
      end
    end
  end
end 