#!/usr/bin/env ruby
# frozen_string_literal: true

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path('../rdawn/lib', __dir__))

require 'rdawn'
require 'logger'

# Example demonstrating the CronTool for scheduling tasks, workflows, and tools

# Set up logging
logger = Logger.new(STDOUT)
logger.level = Logger::INFO

puts "🕐 Rdawn CronTool Demo"
puts "=" * 50

# Register advanced tools with API key
api_key = ENV['OPENAI_API_KEY']
unless api_key
  puts "⚠️  Warning: OPENAI_API_KEY not set. Some features may not work."
end

# Register all advanced tools
Rdawn::Tools.register_advanced_tools(api_key: api_key)

# Initialize the CronTool
cron_tool = Rdawn::Tools::CronTool.new(logger: logger)

puts "✅ CronTool initialized successfully"
puts "   Scheduler status: #{cron_tool.scheduler.up? ? 'Running' : 'Stopped'}"
puts

# Example 1: Schedule a simple task with cron expression
puts "📅 Example 1: Schedule a simple task with cron expression"
puts "-" * 50

simple_task = proc do |input_data|
  puts "🎯 Executing simple task at #{Time.now}"
  puts "   Input data: #{input_data}"
  
  {
    message: "Simple task completed successfully",
    executed_at: Time.now,
    input_received: input_data
  }
end

# Schedule a task to run every minute
task_result = cron_tool.schedule_task(
  name: "daily_report",
  cron_expression: "*/1 * * * *", # Every minute for demo
  task_proc: simple_task,
  input_data: { report_type: "daily", format: "json" }
)

puts "✅ Task scheduled: #{task_result[:name]}"
puts "   Job ID: #{task_result[:job_id]}"
puts "   Next execution: #{task_result[:next_time]}"
puts

# Example 2: Schedule a one-time task
puts "📅 Example 2: Schedule a one-time task"
puts "-" * 50

one_time_task = proc do |input_data|
  puts "🎯 Executing one-time task at #{Time.now}"
  puts "   Message: #{input_data[:message]}"
  
  {
    message: "One-time task completed",
    executed_at: Time.now,
    special_data: input_data
  }
end

# Schedule a task to run in 30 seconds
one_time_result = cron_tool.schedule_once(
  name: "welcome_message",
  at_time: Time.now + 30,
  task_proc: one_time_task,
  input_data: { message: "Welcome to Rdawn CronTool!" }
)

puts "✅ One-time task scheduled: #{one_time_result[:name]}"
puts "   Execution time: #{one_time_result[:at_time]}"
puts

# Example 3: Schedule a recurring task with interval
puts "📅 Example 3: Schedule a recurring task with interval"
puts "-" * 50

recurring_task = proc do |input_data|
  puts "🎯 Executing recurring task at #{Time.now}"
  puts "   Counter: #{input_data[:counter] || 0}"
  
  # Simulate some work
  sleep(1)
  
  {
    message: "Recurring task completed",
    executed_at: Time.now,
    counter: (input_data[:counter] || 0) + 1
  }
end

# Schedule a task to run every 30 seconds
recurring_result = cron_tool.schedule_recurring(
  name: "heartbeat_monitor",
  interval: "30s",
  task_proc: recurring_task,
  input_data: { counter: 0, monitor_type: "heartbeat" }
)

puts "✅ Recurring task scheduled: #{recurring_result[:name]}"
puts "   Interval: #{recurring_result[:interval]}"
puts "   Next execution: #{recurring_result[:next_time]}"
puts

# Example 4: Schedule a task to execute a tool
puts "📅 Example 4: Schedule a task to execute a tool"
puts "-" * 50

# Schedule a task to run web search every 5 minutes
if api_key
  web_search_result = cron_tool.schedule_recurring(
    name: "news_monitor",
    interval: "5m",
    tool_name: "web_search",
    input_data: {
      query: "latest Ruby programming news",
      context_size: "medium"
    }
  )

  puts "✅ Tool execution scheduled: #{web_search_result[:name]}"
  puts "   Tool: web_search"
  puts "   Next execution: #{web_search_result[:next_time]}"
else
  puts "⚠️  Skipping web search example (no API key provided)"
end
puts

# Example 5: Set up callbacks for job events
puts "📅 Example 5: Set up callbacks for job events"
puts "-" * 50

# Before execution callback
cron_tool.set_callback(
  event: 'before_execution',
  callback_proc: proc do |job_name, job|
    puts "🔄 About to execute job: #{job_name}"
  end
)

# After execution callback
cron_tool.set_callback(
  event: 'after_execution',
  callback_proc: proc do |job_name, job, result|
    puts "✅ Job completed: #{job_name} with result: #{result.class}"
  end
)

# Error callback
cron_tool.set_callback(
  event: 'on_error',
  callback_proc: proc do |job_name, job, error|
    puts "❌ Job failed: #{job_name} with error: #{error.message}"
  end
)

puts "✅ Callbacks configured for job events"
puts

# Example 6: List all scheduled jobs
puts "📅 Example 6: List all scheduled jobs"
puts "-" * 50

jobs_list = cron_tool.list_jobs
puts "📋 Total jobs: #{jobs_list[:total_jobs]}"
puts "   Active jobs: #{jobs_list[:active_jobs]}"
puts

jobs_list[:jobs].each do |job|
  puts "   📌 #{job[:name]} (#{job[:type]})"
  puts "      Status: #{job[:status]}"
  puts "      Schedule: #{job[:schedule]}"
  puts "      Executions: #{job[:executions]}"
  puts "      Next time: #{job[:next_time]}"
  puts
end

# Example 7: Get detailed job information
puts "📅 Example 7: Get detailed job information"
puts "-" * 50

begin
  job_info = cron_tool.get_job(name: "daily_report")
  puts "📋 Job details for 'daily_report':"
  puts "   Job ID: #{job_info[:job_id]}"
  puts "   Status: #{job_info[:status]}"
  puts "   Type: #{job_info[:type]}"
  puts "   Executions: #{job_info[:executions]}"
  puts "   Created: #{job_info[:created_at]}"
  puts "   Next time: #{job_info[:next_time]}"
rescue => e
  puts "❌ Error getting job info: #{e.message}"
end
puts

# Example 8: Execute a job immediately
puts "📅 Example 8: Execute a job immediately"
puts "-" * 50

begin
  immediate_result = cron_tool.execute_job_now(name: "daily_report")
  puts "✅ Job executed immediately: #{immediate_result[:name]}"
  puts "   Executed at: #{immediate_result[:executed_at]}"
  puts "   Result: #{immediate_result[:result]}"
rescue => e
  puts "❌ Error executing job: #{e.message}"
end
puts

# Example 9: Get scheduler statistics
puts "📅 Example 9: Get scheduler statistics"
puts "-" * 50

stats = cron_tool.get_statistics
puts "📊 Scheduler Statistics:"
puts "   Status: #{stats[:scheduler_status]}"
puts "   Total jobs: #{stats[:total_jobs]}"
puts "   Active jobs: #{stats[:active_jobs]}"
puts "   Completed jobs: #{stats[:completed_jobs]}"
puts "   Failed jobs: #{stats[:failed_jobs]}"
puts "   Uptime: #{stats[:uptime]} seconds"
puts "   Threads: #{stats[:threads]}"
puts

# Example 10: Using the ToolRegistry execute method
puts "📅 Example 10: Using the ToolRegistry execute method"
puts "-" * 50

# Use the cron tool through the registry
registry_result = Rdawn::ToolRegistry.execute('cron_schedule_task', {
  name: "registry_test",
  cron_expression: "*/2 * * * *", # Every 2 minutes
  tool_name: "cron_get_statistics"
})

puts "✅ Task scheduled via registry: #{registry_result[:name]}"
puts "   Job ID: #{registry_result[:job_id]}"
puts

# Let the scheduler run for a bit to demonstrate execution
puts "📅 Letting scheduler run for 2 minutes to demonstrate execution..."
puts "   (You should see job executions above)"
puts

# Wait for some executions
sleep(120)

# Final statistics
final_stats = cron_tool.get_statistics
puts "📊 Final Statistics:"
puts "   Completed jobs: #{final_stats[:completed_jobs]}"
puts "   Failed jobs: #{final_stats[:failed_jobs]}"
puts

# Example 11: Unschedule a job
puts "📅 Example 11: Unschedule a job"
puts "-" * 50

begin
  unschedule_result = cron_tool.unschedule_job(name: "daily_report")
  puts "✅ Job unscheduled: #{unschedule_result[:name]}"
  puts "   Unscheduled at: #{unschedule_result[:unscheduled_at]}"
rescue => e
  puts "❌ Error unscheduling job: #{e.message}"
end
puts

# Final job list
final_jobs = cron_tool.list_jobs
puts "📋 Final job count: #{final_jobs[:total_jobs]} total, #{final_jobs[:active_jobs]} active"
puts

# Example 12: Stop the scheduler
puts "📅 Example 12: Stop the scheduler"
puts "-" * 50

stop_result = cron_tool.stop_scheduler
puts "✅ Scheduler stopped: #{stop_result[:status]}"
puts "   Stopped at: #{stop_result[:stopped_at]}"
puts

puts "🎉 CronTool demo completed!"
puts "=" * 50
puts
puts "Key features demonstrated:"
puts "• Cron expression scheduling"
puts "• One-time task scheduling"
puts "• Recurring interval scheduling"
puts "• Tool execution scheduling"
puts "• Job management (list, get, execute, unschedule)"
puts "• Event callbacks"
puts "• Statistics tracking"
puts "• ToolRegistry integration"
puts
puts "For more information, see the rdawn documentation." 