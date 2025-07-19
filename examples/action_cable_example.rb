#!/usr/bin/env ruby
# frozen_string_literal: true

# ActionCableTool Example
# This example demonstrates real-time UI updates using the ActionCableTool
# in a Rails application with Hotwire and Turbo Streams.
#
# ✅ Based on successful Fat Free CRM integration test with AI lead analysis

require_relative '../rdawn/lib/rdawn'

puts "🚀 ActionCableTool Example: Real-time Project Analysis"
puts "=" * 60

# This example simulates a Rails application environment
# In a real Rails app, these would be actual ActiveRecord models
class MockProject
  attr_accessor :id, :name, :description, :status
  
  def initialize(id:, name:, description:, status: 'pending')
    @id = id
    @name = name  
    @description = description
    @status = status
  end
  
  def to_gid_param
    "project_#{@id}"
  end
  
  def class
    OpenStruct.new(name: 'Project')
  end
end

class MockUser
  attr_accessor :id, :name, :email
  
  def initialize(id:, name:, email:)
    @id = id
    @name = name
    @email = email
  end
  
  def to_gid_param
    "user_#{@id}"
  end
  
  def class
    OpenStruct.new(name: 'User')
  end
end

# Example 1: Real-time Project Status Updates
def real_time_project_analysis_example
  puts "\n📊 Example 1: Real-time Project Analysis Workflow"
  puts "-" * 50
  
  # Mock project and user
  project = MockProject.new(
    id: 123,
    name: "AI-Powered CRM Enhancement",
    description: "Integrate AI features into existing CRM system to improve user productivity and data insights."
  )
  
  user = MockUser.new(id: 456, name: "Sarah Developer", email: "sarah@example.com")
  
  # Create the workflow
  workflow = Rdawn::Workflow.new(
    workflow_id: "analyze_project_#{project.id}",
    name: "AI Project Analysis with Real-time Updates"
  )
  
  # Task 1: Notify analysis start
  start_notification = Rdawn::Task.new(
    task_id: '1',
    name: 'Notify Analysis Start',
    tool_name: 'turbo_stream',
    input_data: {
      action_type: 'turbo_stream',
      streamable: project,
      target: 'project_status',
      turbo_action: 'replace',
      content: '<div class="bg-blue-50 p-4 rounded border-l-4 border-blue-500">
                  <h3 class="text-blue-800 font-semibold">🔍 AI Analysis in Progress</h3>
                  <p class="text-blue-600 text-sm mt-1">Analyzing project scope and requirements...</p>
                </div>'
    }
  )
  start_notification.next_task_id_on_success = '2'
  
  # Task 2: Progress update during analysis
  progress_update = Rdawn::Task.new(
    task_id: '2',
    name: 'Show Progress',
    tool_name: 'action_cable',
    input_data: {
      action_type: 'broadcast',
      streamable: user,
      data: {
        type: 'analysis_progress',
        project_id: project.id,
        message: 'Analyzing requirements and dependencies...',
        progress: 25,
        total_steps: 100
      }
    }
  )
  progress_update.next_task_id_on_success = '3'
  
  # Task 3: AI Analysis (simulated)
  analysis_task = Rdawn::Tasks::DirectHandlerTask.new(
    task_id: '3',
    name: 'Perform AI Analysis',
    handler: proc do |input_data, workflow_vars|
      # Simulate AI analysis
      sleep(1) # Simulate processing time
      
      analysis_result = {
        summary: "The AI-Powered CRM Enhancement project shows strong potential for improving user productivity by 40%.",
        recommendations: [
          "Implement AI-driven lead scoring system",
          "Add automated email response suggestions",
          "Create intelligent data validation workflows"
        ],
        risk_assessment: "Low risk - Good technical foundation exists",
        estimated_timeline: "12-16 weeks",
        complexity_score: 7.5
      }
      
      { ai_analysis: analysis_result }
    end
  )
  analysis_task.next_task_id_on_success = '4'
  
  # Task 4: Update UI with results
  results_update = Rdawn::Task.new(
    task_id: '4',
    name: 'Display Analysis Results',
    tool_name: 'turbo_stream',
    input_data: {
      action_type: 'turbo_stream',
      streamable: project,
      target: 'project_analysis',
      turbo_action: 'replace',
      content: '<div class="bg-green-50 p-6 rounded border-l-4 border-green-500">
                  <h3 class="text-green-800 font-bold text-lg">✅ Analysis Complete!</h3>
                  <div class="mt-4 space-y-3">
                    <div>
                      <h4 class="font-semibold text-green-700">Summary:</h4>
                      <p class="text-green-600">${ai_analysis.summary}</p>
                    </div>
                    <div>
                      <h4 class="font-semibold text-green-700">Complexity Score:</h4>
                      <div class="text-green-600">${ai_analysis.complexity_score}/10</div>
                    </div>
                    <div>
                      <h4 class="font-semibold text-green-700">Timeline:</h4>
                      <div class="text-green-600">${ai_analysis.estimated_timeline}</div>
                    </div>
                  </div>
                </div>'
    }
  )
  results_update.next_task_id_on_success = '5'
  
  # Task 5: Broadcast completion to team
  team_notification = Rdawn::Task.new(
    task_id: '5',
    name: 'Notify Team',
    tool_name: 'turbo_stream',
    input_data: {
      action_type: 'turbo_stream',
      streamable: project,
      target: 'team_activity',
      turbo_action: 'prepend',
      content: '<div class="flex items-center p-3 bg-white border rounded-lg shadow-sm">
                  <div class="flex-shrink-0">
                    <span class="inline-flex items-center justify-center h-8 w-8 rounded-full bg-green-100">
                      🤖
                    </span>
                  </div>
                  <div class="ml-3">
                    <p class="text-sm text-gray-900">
                      AI analysis completed for <strong>' + project.name + '</strong>
                    </p>
                    <p class="text-xs text-gray-500">Just now • Automated analysis</p>
                  </div>
                </div>'
    }
  )
  
  # Build the workflow
  workflow.add_task(start_notification)
  workflow.add_task(progress_update)  
  workflow.add_task(analysis_task)
  workflow.add_task(results_update)
  workflow.add_task(team_notification)
  
  # Configure LLM interface (though we're using DirectHandlerTask for this example)
  llm_interface = Rdawn::LLMInterface.new(
    provider: :openai,
    api_key: ENV['OPENAI_API_KEY'] || 'demo-key',
    model: 'gpt-4o-mini'
  )
  
  # Create and run the agent
  agent = Rdawn::Agent.new(workflow: workflow, llm_interface: llm_interface)
  
  puts "🎯 Starting real-time project analysis workflow..."
  puts "   Project: #{project.name}"
  puts "   User: #{user.name}"
  puts "   Workflow ID: #{workflow.workflow_id}"
  
  # Execute the workflow with initial context
  result = agent.run(initial_input: {
    project: project,
    user: user,
    started_at: Time.current
  })
  
  puts "\n✅ Workflow completed successfully!"
  puts "   Status: #{result.status}"
  puts "   Tasks executed: #{result.tasks.length}"
  
  # Show what would have been broadcast
  puts "\n📺 Real-time Updates That Would Be Sent:"
  result.tasks.each do |task_id, task|
    if task.tool_name == 'turbo_stream' && task.output_data[:success]
      puts "   🎯 #{task.name}: DOM update to '#{task.input_data[:target]}'"
      puts "      Action: #{task.input_data[:turbo_action]}"
      puts "      Target: #{task.input_data[:streamable].class.name} ID:#{task.input_data[:streamable].id}"
    elsif task.tool_name == 'action_cable' && task.output_data[:success]
      puts "   📡 #{task.name}: Broadcast to #{task.input_data[:streamable].class.name}"
      puts "      Data: #{task.input_data[:data][:type]}"
    end
  end
  
  result
end

# Example 2: Error Handling with User Feedback  
def error_handling_example
  puts "\n⚠️  Example 2: Error Handling with Real-time Feedback"
  puts "-" * 50
  
  project = MockProject.new(id: 789, name: "Error Demo Project", description: "Demo")
  
  workflow = Rdawn::Workflow.new(
    workflow_id: "error_demo",
    name: "Error Handling Demo"
  )
  
  # Task that will fail
  failing_task = Rdawn::Tasks::DirectHandlerTask.new(
    task_id: '1',
    name: 'Simulated Failure',
    handler: proc do |input_data, workflow_vars|
      raise StandardError, "Simulated analysis failure"
    end
  )
  failing_task.next_task_id_on_failure = 'error_notification'
  
  # Error notification task
  error_task = Rdawn::Task.new(
    task_id: 'error_notification', 
    name: 'Show Error to User',
    tool_name: 'turbo_stream',
    input_data: {
      action_type: 'turbo_stream',
      streamable: project,
      target: 'project_status',
      turbo_action: 'replace',
      content: '<div class="bg-red-50 p-4 rounded border-l-4 border-red-500">
                  <h3 class="text-red-800 font-semibold">❌ Analysis Failed</h3>
                  <p class="text-red-600 text-sm mt-1">Unable to complete analysis. Please try again or contact support.</p>
                  <button class="mt-2 px-3 py-1 bg-red-100 text-red-700 rounded text-sm hover:bg-red-200">
                    Retry Analysis
                  </button>
                </div>'
    }
  )
  
  workflow.add_task(failing_task)
  workflow.add_task(error_task)
  
  llm_interface = Rdawn::LLMInterface.new(
    provider: :openai,
    api_key: ENV['OPENAI_API_KEY'] || 'demo-key', 
    model: 'gpt-4o-mini'
  )
  
  agent = Rdawn::Agent.new(workflow: workflow, llm_interface: llm_interface)
  
  puts "🎯 Demonstrating error handling..."
  result = agent.run(initial_input: { project: project })
  
  puts "✅ Error handling completed!"
  puts "   Workflow Status: #{result.status}"
  
  error_task_result = result.tasks['error_notification']
  if error_task_result && error_task_result.output_data[:success]
    puts "   📺 Error notification sent to user successfully"
  end
  
  result
end

# Main execution
if __FILE__ == $0
  begin
    # Run examples
    real_time_project_analysis_example
    error_handling_example
    
    puts "\n" + "=" * 60
    puts "🎉 ActionCableTool Examples Complete!"
    puts "\nIn a real Rails application, these updates would:"
    puts "• Show live progress indicators to users"
    puts "• Update multiple browser windows simultaneously" 
    puts "• Enable real-time collaboration features"
    puts "• Provide immediate feedback on AI operations"
    puts "\nTo use in your Rails app:"
    puts "1. Add 'gem turbo-rails' to your Gemfile"
    puts "2. Configure Action Cable with Redis (production)"
    puts "3. Use <%= turbo_stream_from @model %> in your views"
    puts "4. Create workflows with 'turbo_stream' tool tasks"
    
  rescue => e
    puts "❌ Error running examples: #{e.message}"
    puts e.backtrace.first(5).join("\n") if e.backtrace
  end
end 