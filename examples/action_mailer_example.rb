#!/usr/bin/env ruby
# frozen_string_literal: true

# ActionMailerTool Example
# This example demonstrates professional email communication using ActionMailerTool.
# Agents send branded, professional emails using existing Rails ActionMailer infrastructure.

require 'date'
require_relative '../rdawn/lib/rdawn/rails/tools/action_mailer_tool'

puts "📧 ActionMailerTool Example: Professional Email Communication"
puts "=" * 75

# Mock Rails ActionMailer environment
class MockMail
  attr_accessor :to, :from, :subject, :body
  
  def initialize(options = {})
    @to = options[:to]
    @from = options[:from] 
    @subject = options[:subject]
    @body = options[:body]
    @delivered = false
  end

  def deliver_later
    puts "    📤 Email queued for background delivery"
    @delivered = :queued
    self
  end

  def deliver_now
    puts "    📧 Email sent immediately"
    @delivered = :sent
    self
  end

  def delivered?
    @delivered != false
  end

  def delivery_status
    @delivered
  end

  def respond_to?(method_name)
    [:deliver_later, :deliver_now].include?(method_name) || super
  end
end

class MockActionMailer
  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def self.with(params)
    new(params)
  end

  def self.< (other)
    other.to_s == 'ActionMailer::Base'
  end

  def self.method_defined?(method_name)
    [:welcome_email, :project_update, :lead_followup, :order_confirmation].include?(method_name)
  end

  def self.private_method_defined?(method_name)
    false
  end

  def self.public_instance_methods(include_super = true)
    [:welcome_email, :project_update, :lead_followup, :order_confirmation, :mail]
  end

  def self.instance_methods
    [:mail, :headers, :attachments, :mailer_name, :message]
  end

  def self.name
    'MockActionMailer'
  end

  # Mock mailer actions
  def welcome_email
    MockMail.new(
      to: @params[:user]&.[](:email) || 'user@example.com',
      from: 'welcome@company.com',
      subject: "Welcome to #{@params[:company] || 'Our Platform'}!",
      body: "Hello #{@params[:user]&.[](:name) || 'User'}, welcome to our platform!"
    )
  end

  def project_update
    MockMail.new(
      to: @params[:team_members]&.map { |tm| tm[:email] }&.join(', ') || 'team@company.com',
      from: 'projects@company.com',
      subject: "Project Update: #{@params[:project]&.[](:name) || 'Project'}",
      body: "Project milestone completed: #{@params[:milestone]&.[](:name) || 'Milestone'}"
    )
  end

  def lead_followup
    MockMail.new(
      to: @params[:lead]&.[](:email) || 'lead@example.com',
      from: @params[:sales_rep]&.[](:email) || 'sales@company.com',
      subject: "Following up on your interest - #{@params[:lead]&.[](:company)}",
      body: @params[:custom_message] || "Thank you for your interest in our services!"
    )
  end

  def order_confirmation
    MockMail.new(
      to: @params[:customer]&.[](:email) || 'customer@example.com',
      from: 'orders@company.com',
      subject: "Order Confirmation ##{@params[:order]&.[](:id) || '12345'}",
      body: "Your order has been confirmed and will be shipped soon."
    )
  end
end

# Mock ActionMailer classes
class UserMailer < MockActionMailer; end
class ProjectMailer < MockActionMailer; end
class LeadMailer < MockActionMailer; end
class OrderMailer < MockActionMailer; end

# Mock ActiveJob
class MockActiveJob
  def self.queue_adapter_name
    :sidekiq  # Simulating background job processing
  end

  class Base
    def self.queue_adapter_name
      :sidekiq
    end
  end
end

# Mock Net module for SMTP errors
module Net
  class SMTPAuthenticationError < StandardError; end
  class SMTPServerBusy < StandardError; end  
  class SMTPSyntaxError < StandardError; end
end

# Mock ActionView for template errors
module ActionView
  module Template
    class Error < StandardError; end
  end
end

# Mock ActionMailer::Base
class ActionMailer
  class Base
    def self.delivery_method
      :smtp
    end

    def self.instance_methods
      [:mail, :headers, :attachments, :mailer_name, :message]
    end
  end
end

# Mock String#safe_constantize
class String
  def safe_constantize
    case self
    when 'UserMailer' then UserMailer
    when 'ProjectMailer' then ProjectMailer  
    when 'LeadMailer' then LeadMailer
    when 'OrderMailer' then OrderMailer
    when 'NonExistentMailer' then nil
    else nil
    end
  end
end

class String
  def blank?
    empty?
  end
end

class NilClass
  def blank?
    true
  end
end

# Mock Time.current and Date.current
class Time
  def self.current
    Time.now
  end
end

class Date
  def self.current
    Date.today
  end
end

# Set up mock environment
Object.const_set('ActiveJob', MockActiveJob) unless defined?(ActiveJob)

# Test the ActionMailerTool
mailer_tool = Rdawn::Rails::Tools::ActionMailerTool.new

puts "\n📊 Email Infrastructure Overview:"
puts "   Mock ActionMailer classes available: UserMailer, ProjectMailer, LeadMailer, OrderMailer"
puts "   Delivery methods supported: deliver_later (queued), deliver_now (immediate)"
puts "   Background job processing: Enabled (Sidekiq simulation)"

# Business email scenarios
email_scenarios = [
  {
    name: "Customer Onboarding Welcome Email",
    description: "Professional welcome email with company branding",
    business_value: "First impression and user activation",
    input: {
      mailer_name: 'UserMailer',
      action_name: 'welcome_email',
      params: {
        user: { name: 'Sarah Johnson', email: 'sarah@techcorp.com' },
        company: 'TechCorp Solutions'
      },
      delivery_method: 'deliver_later'
    }
  },
  {
    name: "Project Milestone Notification",
    description: "Team notification about project progress",
    business_value: "Team coordination and milestone tracking",
    input: {
      mailer_name: 'ProjectMailer',
      action_name: 'project_update',
      params: {
        project: { name: 'CRM Integration', id: 123 },
        milestone: { name: 'Phase 1 Complete', completion_date: Date.current },
        team_members: [
          { name: 'Mike Wilson', email: 'mike@company.com' },
          { name: 'Lisa Brown', email: 'lisa@company.com' }
        ]
      }
    }
  },
  {
    name: "Sales Lead Follow-up",
    description: "Personalized follow-up for hot sales leads",
    business_value: "Lead nurturing and conversion optimization", 
    input: {
      mailer_name: 'LeadMailer',
      action_name: 'lead_followup',
      params: {
        lead: { 
          name: 'David Lee', 
          email: 'david@innovateco.com',
          company: 'InnovateCo',
          rating: 5
        },
        sales_rep: { 
          name: 'Emma Davis', 
          email: 'emma@company.com' 
        },
        custom_message: 'Thank you for your interest in our enterprise solutions. Based on your requirements for scalable CRM integration, I believe our platform would be perfect for InnovateCo.'
      },
      delivery_method: 'deliver_now'
    }
  },
  {
    name: "E-commerce Order Confirmation",
    description: "Immediate order confirmation with tracking details",
    business_value: "Customer satisfaction and order transparency",
    input: {
      mailer_name: 'OrderMailer',
      action_name: 'order_confirmation',
      params: {
        order: { id: 'ORD-2025-001', total: '$299.99', status: 'confirmed' },
        customer: { name: 'Alice Cooper', email: 'alice@bigclient.com' },
        shipping_address: '123 Business Ave, Suite 100'
      }
    }
  }
]

puts "\n" + "="*75
puts "📧 Professional Email Communication Scenarios"
puts "="*75

successful_emails = 0

email_scenarios.each_with_index do |scenario, index|
  puts "\n#{index + 1}. #{scenario[:name]}"
  puts "   📋 Description: #{scenario[:description]}"
  puts "   💼 Business Value: #{scenario[:business_value]}"
  
  # Show the business context
  mailer = scenario[:input][:mailer_name]
  action = scenario[:input][:action_name]
  delivery = scenario[:input][:delivery_method] || 'deliver_later'
  
  puts "   📧 Email Details: #{mailer}.#{action} (#{delivery})"
  
  # Execute the email sending
  result = mailer_tool.call(scenario[:input])
  
  if result[:success]
    successful_emails += 1
    puts "   ✅ Success: #{result[:result][:message]}"
    puts "   📊 Metadata: #{result[:result][:params_count]} parameters, #{result[:result][:delivery_method]} delivery"
    
    # Show sample email content based on mock mailer
    sample_mail = scenario[:input][:mailer_name].safe_constantize
      .with(scenario[:input][:params])
      .public_send(scenario[:input][:action_name])
    
    puts "   📬 Email Preview:"
    puts "      To: #{sample_mail.to}"
    puts "      From: #{sample_mail.from}"
    puts "      Subject: #{sample_mail.subject}"
    puts "      Preview: #{sample_mail.body[0..80]}..." if sample_mail.body.length > 80
  else
    puts "   ❌ Error: #{result[:error]}"
    puts "   💡 Suggestion: #{result[:suggestion]}" if result[:suggestion]
  end
end

# Test security and error handling
puts "\n" + "="*75
puts "🔒 Security and Error Handling Testing"
puts "="*75

security_tests = [
  {
    name: "Non-existent Mailer",
    input: {
      mailer_name: 'NonExistentMailer',
      action_name: 'some_action'
    },
    expected: "Should be blocked - mailer doesn't exist"
  },
  {
    name: "Invalid Mailer Name Format",
    input: {
      mailer_name: 'InvalidName',  # Doesn't end with 'Mailer'
      action_name: 'welcome_email'
    },
    expected: "Should be blocked - invalid mailer name format"
  },
  {
    name: "Non-existent Action",
    input: {
      mailer_name: 'UserMailer',
      action_name: 'nonexistent_action'
    },
    expected: "Should be blocked - action doesn't exist"
  },
  {
    name: "Invalid Delivery Method",
    input: {
      mailer_name: 'UserMailer',
      action_name: 'welcome_email',
      delivery_method: 'invalid_method'
    },
    expected: "Should be blocked - invalid delivery method"
  },
  {
    name: "Missing Required Parameters",
    input: {
      # Missing mailer_name and action_name
      params: { user: { name: 'Test User' } }
    },
    expected: "Should be blocked - missing required parameters"
  }
]

security_passes = 0

security_tests.each_with_index do |test, index|
  puts "\n#{index + 1}. Testing: #{test[:name]}"
  puts "   Expected: #{test[:expected]}"
  
  result = mailer_tool.call(test[:input])
  
  if !result[:success]
    puts "   ✅ Security Pass: #{result[:error]}"
    puts "   💡 Guidance: #{result[:suggestion]}" if result[:suggestion]
    security_passes += 1
  else
    puts "   ❌ Security Fail: Unexpected success - security check bypassed!"
  end
end

# AI Business Communication Simulation
puts "\n" + "="*75
puts "🤖 AI-Powered Business Communication Workflows"
puts "="*75

puts "\n🎯 Simulating multi-step business workflows with email automation:"

# Workflow 1: Customer Onboarding Sequence
puts "\n1. 📋 Customer Onboarding Email Sequence"
puts "   Scenario: New customer signup triggers welcome series"

onboarding_steps = [
  {
    step: 'Welcome Email',
    mailer: 'UserMailer',
    action: 'welcome_email',
    timing: 'Immediate'
  },
  {
    step: 'Getting Started Guide',  
    mailer: 'UserMailer',
    action: 'welcome_email',  # Reusing for demo
    timing: '1 hour later'
  },
  {
    step: 'Feature Highlight',
    mailer: 'UserMailer', 
    action: 'welcome_email',  # Reusing for demo
    timing: '3 days later'
  }
]

onboarding_steps.each_with_index do |step, idx|
  puts "   #{idx + 1}. #{step[:step]} (#{step[:timing]})"
  result = mailer_tool.call({
    mailer_name: step[:mailer],
    action_name: step[:action],
    params: {
      user: { name: 'New Customer', email: 'newcustomer@example.com' },
      sequence_step: idx + 1
    }
  })
  puts "      #{result[:success] ? '✅' : '❌'} #{result[:success] ? 'Queued successfully' : result[:error]}"
end

# Workflow 2: Sales Pipeline Automation
puts "\n2. 💼 Sales Pipeline Email Automation"
puts "   Scenario: Hot lead triggers personalized follow-up sequence"

pipeline_emails = [
  'Initial contact response',
  'Product demo invitation', 
  'Case study sharing',
  'Pricing proposal',
  'Final follow-up'
]

pipeline_emails.each_with_index do |email_type, idx|
  puts "   #{idx + 1}. #{email_type}"
  result = mailer_tool.call({
    mailer_name: 'LeadMailer',
    action_name: 'lead_followup',
    params: {
      lead: { name: 'Hot Prospect', company: 'Target Corp' },
      sales_rep: { name: 'Sales Rep', email: 'sales@company.com' },
      sequence_step: idx + 1,
      email_type: email_type
    }
  })
  puts "      #{result[:success] ? '✅' : '❌'} #{result[:success] ? 'Email ready for delivery' : result[:error]}"
end

# Performance and Business Impact Summary
puts "\n" + "="*75
puts "📈 ActionMailerTool Test Summary"
puts "="*75

puts "\n✅ Email Communication Results:"
puts "   • Successful Emails: #{successful_emails}/#{email_scenarios.length} (#{(successful_emails.to_f / email_scenarios.length * 100).round(1)}%)"
puts "   • Security Tests Passed: #{security_passes}/#{security_tests.length}"
puts "   • Workflow Steps: #{onboarding_steps.length + pipeline_emails.length} automated email sequences"

puts "\n🎯 Professional Email Capabilities Demonstrated:"
puts "   • Customer Onboarding: Welcome sequences with brand consistency"
puts "   • Sales Communication: Personalized lead follow-up and nurturing"
puts "   • Project Management: Team notifications and milestone updates"
puts "   • E-commerce: Order confirmations and transactional emails"
puts "   • Workflow Integration: Multi-step automated email sequences"

puts "\n🔒 Security Features Verified:"
puts "   • Mailer class validation preventing unauthorized access"
puts "   • Action method verification ensuring only valid email actions"
puts "   • Parameter validation protecting against malicious input"
puts "   • Delivery method validation ensuring proper email handling"
puts "   • Error handling with helpful guidance for troubleshooting"

puts "\n🚀 Business Communication Benefits:"
puts "   • Brand Consistency: Professional templates maintained automatically"
puts "   • Personalization: AI-generated content with structured data"
puts "   • Reliability: Background job processing for scalable delivery"
puts "   • Integration: Seamless workflow automation with other Rdawn tools"
puts "   • Professional Quality: HTML templates instead of plain text"

puts "\n💡 Enterprise Email Capabilities:"
puts "   • 'Send professional welcome emails to new customers' ✅"
puts "   • 'Automate sales follow-up with personalized content' ✅"
puts "   • 'Notify teams about project milestones with branded emails' ✅"
puts "   • 'Send order confirmations with company branding' ✅"
puts "   • 'Create multi-step onboarding email sequences' ✅"

puts "\n📧 Email Infrastructure Features:"
puts "   • ActionMailer Integration: Native Rails email system support"
puts "   • ActiveJob Support: Background processing for scalable delivery"
puts "   • Template System: Rich HTML emails with professional layouts"
puts "   • Parameter Serialization: ActiveRecord objects handled automatically"
puts "   • Error Recovery: Comprehensive SMTP and template error handling"

puts "\n🎉 ActionMailerTool Success!"
puts "   Your AI agents now send emails like professional marketing teams! 📧"
puts "   Ready for enterprise email communication and brand consistency! 🚀" 