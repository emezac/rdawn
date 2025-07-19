# frozen_string_literal: true

require 'rails/generators/base'

module Rdawn
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        desc "Install rdawn in your Rails application"
        
        source_root File.expand_path('templates', __dir__)
        
        def create_initializer
          create_file "config/initializers/rdawn.rb", initializer_content
        end
        
        def create_workflow_directory
          empty_directory "app/workflows"
          create_file "app/workflows/.keep", ""
        end
        
        def create_workflow_handlers_directory
          empty_directory "app/workflows/handlers"
          create_file "app/workflows/handlers/.keep", ""
        end
        
        def show_readme
          readme "README" if behavior == :invoke
        end
        
        private
        
        def initializer_content
          <<~RUBY
            # frozen_string_literal: true
            
            # Rdawn Configuration
            # Configure rdawn for your Rails application
            
            # Load rdawn Rails integration
            require 'rdawn/rails'
            
            # Configure rdawn
            Rdawn.configure do |config|
              # LLM Configuration
              config.llm_api_key = ENV['OPENAI_API_KEY'] || Rails.application.credentials.openai_api_key
              config.llm_model = 'gpt-4o-mini'  # or 'gpt-4', 'gpt-3.5-turbo'
              config.llm_provider = 'openai'    # Currently only OpenAI supported
              
              # Default configuration for all agents
              config.default_model_params = {
                temperature: 0.7,
                max_tokens: 1000
              }
            end
            
            # Register advanced tools (optional but recommended)
            api_key = ENV['OPENAI_API_KEY'] || Rails.application.credentials.openai_api_key
            Rdawn::Tools.register_advanced_tools(api_key: api_key)
            
            # Configure Rails-specific settings
            Rdawn::Rails.configure do |config|
              # Active Job configuration
              config.default_queue_adapter = :#{Rails.application.config.active_job.queue_adapter || 'async'}
              config.default_queue_name = :rdawn
              config.enable_active_job_integration = true
            end
            
            # Rails-specific tools are automatically registered:
            # - 'action_cable' / 'turbo_stream' - Real-time UI updates (requires turbo-rails)
            #
            # To enable real-time features, add to your Gemfile:
            # gem 'turbo-rails'
            # gem 'redis' # for Action Cable in production
            
            # Example workflow handler registration
            # Register your workflow handlers here or in separate files
            # 
            # Example:
            # module WorkflowHandlers
            #   class UserOnboarding
            #     def self.call(input_data, workflow_variables)
            #       user = User.find(input_data['user_id'])
            #       # Your onboarding logic here
            #       { success: true, user: user.attributes }
            #     end
            #   end
            # end
          RUBY
        end
      end
    end
  end
end 