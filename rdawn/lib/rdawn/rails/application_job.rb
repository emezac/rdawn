# frozen_string_literal: true

module Rdawn
  module Rails
    # Base job class for all rdawn Active Job classes
    class ApplicationJob < ActiveJob::Base
      # Set default queue for rdawn jobs
      queue_as do
        Rdawn::Rails.configuration.default_queue_name
      end
      
      # Automatically retry jobs that fail due to temporary issues
      retry_on StandardError, wait: :exponentially_longer, attempts: 3
      
      # Discard jobs that fail due to configuration or validation errors
      discard_on Rdawn::Errors::ConfigurationError
      discard_on Rdawn::Errors::VariableResolutionError
      
      # Common error handling for all rdawn jobs
      rescue_from StandardError do |exception|
        # Log the error with context
        Rails.logger.error "Rdawn job failed: #{exception.class.name} - #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        
        # Re-raise to let Active Job handle retry logic
        raise exception
      end
      
      protected
      
      # Helper method to safely execute workflows with error handling
      def safe_workflow_execution(&block)
        begin
          yield
        rescue Rdawn::Errors::RdawnError => e
          Rails.logger.error "Rdawn workflow error: #{e.class.name} - #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unexpected error in rdawn workflow: #{e.class.name} - #{e.message}"
          raise Rdawn::Errors::TaskExecutionError, "Workflow execution failed: #{e.message}"
        end
      end
      
      # Helper method to build workflow context with Rails-specific data
      def build_workflow_context(additional_context = {})
        {
          rails_env: Rails.env,
          timestamp: Time.current,
          job_id: job_id,
          job_class: self.class.name
        }.merge(additional_context)
      end
    end
  end
end 