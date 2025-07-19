#!/usr/bin/env ruby
# frozen_string_literal: true

# Working rdawn + OpenAI Example
# This example demonstrates real OpenAI API calls with rdawn-like functionality
# Uses the proven patterns from our tests

require 'rdawn'
require 'raix'
require 'openai'

# Check if OpenAI API key is set
unless ENV['OPENAI_API_KEY']
  puts "❌ Error: Please set your OpenAI API key:"
  puts "export OPENAI_API_KEY='your-openai-api-key-here'"
  puts ""
  puts "Get your API key at: https://platform.openai.com/api-keys"
  exit 1
end

puts "🤖 Working rdawn + OpenAI Example"
puts "=" * 40
puts "Making a real API call to OpenAI to get latest Trump news..."

# Configure Raix with the working pattern
Raix.configure do |config|
  config.openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
end

# Create a working LLM interface using proven patterns
class WorkingLLMInterface
  include Raix::ChatCompletion
  
  def initialize(model)
    @model = model
  end
  
  def execute_llm_call(prompt:, model_params: {})
    # Clear any previous transcript
    transcript.clear
    
    # Add the prompt to the transcript
    case prompt
    when String
      transcript << { user: prompt }
    when Array
      prompt.each { |msg| transcript << msg }
    when Hash
      transcript << prompt
    else
      raise "Invalid prompt format: #{prompt.class}"
    end
    
    # Execute chat completion using the working pattern
    chat_completion(openai: @model)
  end
end

# Create a simple task structure like rdawn
class SimpleTask
  attr_accessor :task_id, :name, :status, :input_data, :output_data
  
  def initialize(task_id:, name:, input_data:)
    @task_id = task_id
    @name = name
    @input_data = input_data
    @status = :pending
    @output_data = {}
  end
  
  def mark_completed(output)
    @status = :completed
    @output_data = output
  end
  
  def mark_failed(error)
    @status = :failed
    @output_data = { error: error }
  end
end

# Create a simple workflow result structure
class SimpleWorkflowResult
  attr_accessor :status, :tasks
  
  def initialize
    @status = :pending
    @tasks = {}
  end
end

# Simulate rdawn workflow execution
puts "🚀 Calling OpenAI API..."
puts "Model: gpt-4o-mini"
puts "-" * 40

begin
  # Create the task
  task = SimpleTask.new(
    task_id: 'ai_response',
    name: 'Get AI Response',
    input_data: {
      prompt: "What are the latest news developments about Trump? Please provide a brief summary of recent news.",
      model_params: {
        temperature: 0.7,
        max_tokens: 300
      }
    }
  )
  
  # Create LLM interface
  llm_interface = WorkingLLMInterface.new('gpt-4o-mini')
  
  # Execute the task
  task.status = :running
  
  prompt = task.input_data[:prompt]
  model_params = task.input_data[:model_params] || {}
  
  # Execute the LLM call
  response = llm_interface.execute_llm_call(prompt: prompt, model_params: model_params)
  
  # Mark task as completed with rdawn-like output structure
  task.mark_completed({
    task_id: task.task_id,
    executed_at: Time.now,
    input_processed: task.input_data,
    llm_response: response,
    type: :llm_task
  })
  
  # Create workflow result
  result = SimpleWorkflowResult.new
  result.status = :completed
  result.tasks[task.task_id] = task
  
  # Display result like rdawn
  if result.status == :completed
    task_data = result.tasks['ai_response'].output_data
    
    # Check if there was an error
    if task_data[:error]
      puts "❌ Error: #{task_data[:error]}"
    else
      ai_response = task_data[:llm_response]
      
      puts "✅ Success!"
      puts ""
      puts "🤖 AI Response:"
      puts ai_response
      puts ""
      puts "✨ Real OpenAI API response received successfully!"
    end
  else
    puts "❌ Failed with status: #{result.status}"
  end
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts ""
  puts "💡 Common issues:"
  puts "   • Invalid API key"
  puts "   • No API credits"
  puts "   • Network issues"
  puts "   • Rate limiting"
  puts ""
  puts "🔧 Check your OpenAI account at: https://platform.openai.com/"
end

puts "=" * 40
puts "�� Example complete!" 