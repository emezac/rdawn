# frozen_string_literal: true

module Rdawn
  module Rails
    module Tools
      # ActionCableTool enables real-time UI updates through Turbo Streams and Action Cable
      # This tool allows rdawn agents to send live updates to client interfaces, creating
      # interactive and fluid copilot experiences.
      class ActionCableTool
        def initialize(application_context: nil)
          @application_context = application_context
        end

        # Primary entry point for the tool
        # @param input [Hash] Input parameters for the action
        # @return [Hash] Result of the operation
        def call(input)
          validate_rails_dependencies!
          
          action_type = input['action_type'] || input[:action_type]
          
          case action_type
          when 'turbo_stream', 'render_turbo_stream'
            render_turbo_stream(input)
          when 'broadcast', 'broadcast_to_channel'
            broadcast_to_channel(input)
          else
            {
              success: false,
              error: "Unknown action_type: #{action_type}. Use 'turbo_stream' or 'broadcast'"
            }
          end
        rescue => e
          handle_error(e, "ActionCableTool execution failed")
        end

        # Renders and broadcasts a Turbo Stream update
        # @param input [Hash] Parameters for Turbo Stream rendering
        #   - target: DOM ID to target
        #   - action: Turbo action (:append, :replace, :remove, etc.)
        #   - partial: Rails partial path (optional)
        #   - locals: Variables for the partial (optional)
        #   - content: Raw HTML content (optional)
        #   - streamable: The object/channel to stream to
        def render_turbo_stream(input)
          target = input['target'] || input[:target]
          turbo_action = input['turbo_action'] || input[:turbo_action] || input['action'] || input[:action] || 'replace'
          streamable = input['streamable'] || input[:streamable]
          
          # Validate required parameters
          return error_response("Missing required parameter: 'target'") unless target
          return error_response("Missing required parameter: 'streamable'") unless streamable
          
          # Validate turbo action
          valid_actions = %w[append prepend replace update remove before after]
          unless valid_actions.include?(turbo_action.to_s)
            return error_response("Invalid turbo_action: #{turbo_action}. Valid actions: #{valid_actions.join(', ')}")
          end

          begin
            if input['partial'] || input[:partial]
              # Render using a Rails partial
              partial_path = input['partial'] || input[:partial]
              locals = input['locals'] || input[:locals] || {}
              
              # Broadcast the partial render
              Turbo::StreamsChannel.broadcast_render_to(
                streamable,
                target: target,
                action: turbo_action.to_sym,
                partial: partial_path,
                locals: locals
              )
              
              success_response(
                message: "Turbo Stream broadcasted successfully",
                details: {
                  target: target,
                  action: turbo_action,
                  partial: partial_path,
                  streamable: streamable_description(streamable)
                }
              )
              
            elsif input['content'] || input[:content]
              # Render using raw HTML content
              content = input['content'] || input[:content]
              
              Turbo::StreamsChannel.broadcast_action_to(
                streamable,
                action: turbo_action.to_sym,
                target: target,
                content: content
              )
              
              success_response(
                message: "Turbo Stream broadcasted successfully",
                details: {
                  target: target,
                  action: turbo_action,
                  content_length: content.length,
                  streamable: streamable_description(streamable)
                }
              )
              
            else
              error_response("Either 'partial' or 'content' must be provided for Turbo Stream rendering")
            end
            
          rescue => e
            handle_error(e, "Failed to broadcast Turbo Stream")
          end
        end

        # Broadcasts data to an Action Cable channel
        # @param input [Hash] Parameters for channel broadcasting
        #   - streamable: The object or channel identifier
        #   - data: Hash of data to broadcast
        #   - channel: Optional channel class name (if not using streamable)
        def broadcast_to_channel(input)
          streamable = input['streamable'] || input[:streamable]
          data = input['data'] || input[:data]
          channel_class = input['channel'] || input[:channel]
          
          return error_response("Either 'streamable' or 'channel' must be provided") unless streamable || channel_class
          return error_response("Missing required parameter: 'data'") unless data
          return error_response("'data' must be a Hash") unless data.is_a?(Hash)

          begin
            if streamable
              # Broadcast to a specific streamable object (e.g., User, Project)
              if streamable.respond_to?(:to_gid_param)
                # Handle Active Record objects
                ActionCable.server.broadcast(
                  "#{streamable.class.name.downcase}_#{streamable.to_gid_param}",
                  data
                )
                streamable_desc = "#{streamable.class.name} ID:#{streamable.id}"
              else
                # Handle string identifiers
                ActionCable.server.broadcast(streamable.to_s, data)
                streamable_desc = streamable.to_s
              end
              
              success_response(
                message: "Successfully broadcasted to channel",
                details: {
                  streamable: streamable_desc,
                  data_keys: data.keys,
                  broadcast_time: Time.current
                }
              )
              
            elsif channel_class
              # Broadcast using a specific channel class
              channel = channel_class.constantize
              channel.broadcast_to(streamable || 'global', data)
              
              success_response(
                message: "Successfully broadcasted via channel class",
                details: {
                  channel: channel_class,
                  data_keys: data.keys,
                  broadcast_time: Time.current
                }
              )
            end
            
          rescue NameError => e
            handle_error(e, "Channel class not found: #{channel_class}")
          rescue => e
            handle_error(e, "Failed to broadcast to channel")
          end
        end

        private

        def validate_rails_dependencies!
          unless defined?(::Rails)
            raise Rdawn::Errors::ConfigurationError, "Rails is required for ActionCableTool"
          end
          
          unless defined?(::Turbo)
            raise Rdawn::Errors::ConfigurationError, "Turbo (Hotwire) is required for ActionCableTool. Add 'turbo-rails' to your Gemfile."
          end
          
          unless defined?(::ActionCable)
            raise Rdawn::Errors::ConfigurationError, "Action Cable is required for ActionCableTool"
          end
        end

        def success_response(message:, details: {})
          {
            success: true,
            message: message,
            details: details,
            executed_at: Time.current,
            tool: 'ActionCableTool'
          }
        end

        def error_response(message)
          {
            success: false,
            error: message,
            executed_at: Time.current,
            tool: 'ActionCableTool'
          }
        end

        def handle_error(exception, context)
          error_message = "#{context}: #{exception.message}"
          
          # Log the full error in development/test
          if ::Rails.env.development? || ::Rails.env.test?
            ::Rails.logger.error "ActionCableTool Error: #{error_message}"
            ::Rails.logger.error exception.backtrace.join("\n") if exception.backtrace
          end
          
          error_response(error_message)
        end

        def streamable_description(streamable)
          if streamable.respond_to?(:to_gid_param)
            "#{streamable.class.name} ID:#{streamable.id}"
          else
            streamable.to_s
          end
        end
      end
    end
  end
end 