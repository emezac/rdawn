# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module Rdawn
  class LLMInterface
    def initialize(provider: :openai, api_key: nil, model: nil, **options)
      @provider = provider
      @api_key = api_key || ENV['OPENROUTER_API_KEY'] || ENV['OPENAI_API_KEY'] || ENV['RDAWN_LLM_API_KEY']
      @model = model || 'gpt-4o-mini'
      @options = options
      
      # Advanced features
      @use_file_search = options.delete(:use_file_search) || false
      @vector_store_ids = options.delete(:vector_store_ids) || []
      @use_web_search = options.delete(:use_web_search) || false
      @web_search_context_size = options.delete(:web_search_context_size) || 'medium'
      
      validate_configuration!
    end

    def execute_llm_call(prompt:, model_params: {})
      # Merge default model params with provided ones
      merged_params = default_model_params.merge(model_params)
      
      # Check if we should use advanced features
      use_file_search = merged_params.delete(:use_file_search) || @use_file_search
      vector_store_ids = merged_params.delete(:vector_store_ids) || @vector_store_ids
      use_web_search = merged_params.delete(:use_web_search) || @use_web_search
      web_search_context_size = merged_params.delete(:web_search_context_size) || @web_search_context_size
      
      # Use advanced features if enabled
      if use_file_search && !vector_store_ids.empty?
        return execute_file_search_call(prompt, vector_store_ids, merged_params)
      elsif use_web_search
        return execute_web_search_call(prompt, web_search_context_size, merged_params)
      end
      
      # Direct OpenAI API call (bypassing Raix for now)
      execute_openai_direct(prompt, merged_params)
    rescue Rdawn::Errors::ConfigurationError
      raise # Re-raise configuration errors as-is
    rescue => e
      raise Rdawn::Errors::TaskExecutionError, "LLM call failed: #{e.message}"
    end

    def execute_file_search_call(prompt, vector_store_ids, model_params)
      # Load the file search tool
      require_relative 'tools/file_search_tool'
      
      file_search_tool = Rdawn::Tools::FileSearchTool.new(api_key: @api_key)
      
      # Extract query from prompt
      query = extract_query_from_prompt(prompt)
      
      # Search files
      search_results = file_search_tool.search_files(
        query: query,
        vector_store_ids: vector_store_ids,
        max_results: model_params.delete(:max_file_search_results) || 5,
        model: @model
      )
      
      # Use the search results content as the LLM response
      search_results[:content] || "No relevant information found in the files."
    end

    def execute_web_search_call(prompt, context_size, model_params)
      # Load the web search tool
      require_relative 'tools/web_search_tool'
      
      web_search_tool = Rdawn::Tools::WebSearchTool.new(api_key: @api_key)
      
      # Extract query from prompt
      query = extract_query_from_prompt(prompt)
      
      # Search web
      search_results = web_search_tool.search(
        query: query,
        context_size: context_size,
        model: @model
      )
      
      # Use the search results content as the LLM response
      search_results[:content] || "No relevant information found on the web."
    end

    private

    def validate_configuration!
      if @api_key.nil? || @api_key.empty?
        raise Rdawn::Errors::ConfigurationError, 
          "API key is required. Set OPENAI_API_KEY environment variable."
      end
      
      if @provider != :openai
        raise Rdawn::Errors::ConfigurationError, 
          "Only OpenAI provider is supported in this version. Set provider to :openai"
      end
    end

    def default_model_params
      {
        temperature: 0.7,
        max_tokens: 1000
      }
    end

    def execute_openai_direct(prompt, model_params)
      # Build messages array
      messages = case prompt
      when String
                   [{ role: 'user', content: prompt }]
      when Array
                   prompt
      when Hash
                   [prompt]
      else
        raise Rdawn::Errors::TaskExecutionError, "Invalid prompt format: #{prompt.class}"
      end
      
      # Build request payload
      payload = {
        model: @model,
        messages: messages,
        temperature: model_params[:temperature],
        max_tokens: model_params[:max_tokens]
      }

      # Make HTTP request to OpenAI
      response = make_openai_request(payload)
      
      # Extract content from response
      if response['choices'] && response['choices'].any?
        response['choices'][0]['message']['content']
      else
        raise Rdawn::Errors::TaskExecutionError, "No response content from OpenAI"
      end
    end

    def make_openai_request(payload)
      uri = URI('https://api.openai.com/v1/chat/completions')
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{@api_key}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.generate(payload)
      
      response = http.request(request)
      
      case response.code.to_i
      when 200
        JSON.parse(response.body)
      when 401
        raise Rdawn::Errors::ConfigurationError, "Invalid API key"
      when 429
        raise Rdawn::Errors::TaskExecutionError, "Rate limit exceeded"
      else
        error_body = JSON.parse(response.body) rescue { 'error' => { 'message' => response.body } }
        error_message = error_body.dig('error', 'message') || "HTTP #{response.code}"
        raise Rdawn::Errors::TaskExecutionError, "OpenAI API error: #{error_message}"
      end
    rescue JSON::ParserError => e
      raise Rdawn::Errors::TaskExecutionError, "Invalid JSON response from OpenAI: #{e.message}"
    end

    def extract_query_from_prompt(prompt)
      # Simple extraction - in a real implementation, this might be more sophisticated
      case prompt
      when String
        prompt
      when Array
        prompt.last.is_a?(Hash) ? prompt.last[:content] || prompt.last['content'] : prompt.last.to_s
      when Hash
        prompt[:content] || prompt['content'] || prompt.to_s
      else
        prompt.to_s
      end
    end
  end
end 