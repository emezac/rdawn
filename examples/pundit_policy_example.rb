#!/usr/bin/env ruby
# frozen_string_literal: true

# PunditPolicyTool Example
# This example demonstrates secure AI workflows using the PunditPolicyTool
# to verify user permissions before allowing agents to perform actions.
#
# This tool ensures agents operate under the same security constraints as humans.

# Load only the components we need for this example
require_relative '../rdawn/lib/rdawn/workflow'
require_relative '../rdawn/lib/rdawn/task'
require_relative '../rdawn/lib/rdawn/agent'
require_relative '../rdawn/lib/rdawn/llm_interface'
require_relative '../rdawn/lib/rdawn/rails/tools/pundit_policy_tool'

puts "🛡️ PunditPolicyTool Example: Secure AI Project Management"
puts "=" * 70

# Simulate Rails environment and Pundit integration
class User
  attr_accessor :id, :name, :role, :admin

  def initialize(id:, name:, role: 'user', admin: false)
    @id = id
    @name = name
    @role = role
    @admin = admin
  end

  def admin?
    @admin
  end
end

class Project
  attr_accessor :id, :title, :user_id, :public, :confidential

  def initialize(id:, title:, user_id:, public: false, confidential: false)
    @id = id
    @title = title
    @user_id = user_id
    @public = public
    @confidential = confidential
  end

  def user
    # Simulate finding user
    case @user_id
    when 1 then User.new(id: 1, name: 'Alice Admin', role: 'admin', admin: true)
    when 2 then User.new(id: 2, name: 'Bob User', role: 'user')
    when 3 then User.new(id: 3, name: 'Carol Manager', role: 'manager')
    end
  end

  def public?
    @public
  end

  def confidential?
    @confidential
  end
end

# Simulate Pundit policies
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end
end

class ProjectPolicy < ApplicationPolicy
  def show?
    return false unless user

    # Public projects can be viewed by anyone
    return true if record.public?
    
    # Admins can see everything
    return true if user.admin?
    
    # Users can see their own projects
    return true if record.user_id == user.id
    
    # Otherwise, no access
    false
  end

  def update?
    return false unless user
    
    # Admins can update anything
    return true if user.admin?
    
    # Users can update their own non-confidential projects
    return true if record.user_id == user.id && !record.confidential?
    
    # Managers can update any non-confidential project
    return true if user.role == 'manager' && !record.confidential?
    
    false
  end

  def destroy?
    return false unless user
    
    # Only admins and project owners can delete
    return true if user.admin?
    return true if record.user_id == user.id
    
    false
  end

  def manage?
    return false unless user
    user.admin? || record.user_id == user.id
  end
end

# Mock Pundit module
module Pundit
  class NotDefinedError < StandardError
    attr_reader :query, :record

    def initialize(message = nil)
      @query = message
      super(message)
    end
  end

  class NotAuthorizedError < StandardError
    attr_reader :query, :record, :policy

    def initialize(message = nil)
      super(message)
    end
  end

  def self.policy!(user, record)
    policy_class_name = "#{record.class.name}Policy"
    
    begin
      policy_class = Object.const_get(policy_class_name)
      policy_class.new(user, record)
    rescue NameError
      raise NotDefinedError, "unable to find policy `#{policy_class_name}` for `#{record.class.name}`"
    end
  end

  def self.policy(user, record)
    policy!(user, record)
  rescue NotDefinedError
    nil
  end
end

# Test scenarios
def create_test_scenarios
  users = [
    User.new(id: 1, name: 'Alice Admin', role: 'admin', admin: true),
    User.new(id: 2, name: 'Bob User', role: 'user'),
    User.new(id: 3, name: 'Carol Manager', role: 'manager')
  ]

  projects = [
    Project.new(id: 1, title: 'Public Open Source', user_id: 2, public: true),
    Project.new(id: 2, title: 'Bob\'s Personal Project', user_id: 2),
    Project.new(id: 3, title: 'Top Secret Project', user_id: 1, confidential: true),
    Project.new(id: 4, title: 'Team Collaboration', user_id: 3)
  ]

  { users: users, projects: projects }
end

# Initialize test data
scenarios = create_test_scenarios
alice_admin = scenarios[:users][0]
bob_user = scenarios[:users][1]
carol_manager = scenarios[:users][2]

public_project = scenarios[:projects][0]
bob_project = scenarios[:projects][1]
secret_project = scenarios[:projects][2]
team_project = scenarios[:projects][3]

puts "👥 Test Users:"
scenarios[:users].each { |u| puts "   #{u.name} (#{u.role}#{u.admin? ? ', admin' : ''})" }

puts "\n📁 Test Projects:"
scenarios[:projects].each do |p|
  flags = []
  flags << "public" if p.public?
  flags << "confidential" if p.confidential?
  flags_str = flags.empty? ? "" : " [#{flags.join(', ')}]"
  puts "   #{p.title} (owner: #{p.user.name})#{flags_str}"
end

# Example 1: Basic Permission Testing
puts "\n" + "="*70
puts "🧪 Example 1: Basic Permission Testing"
puts "="*70

# Create the PunditPolicyTool
pundit_tool = Rdawn::Rails::Tools::PunditPolicyTool.new

test_cases = [
  { user: alice_admin, project: secret_project, action: 'show?', expected: true },
  { user: bob_user, project: secret_project, action: 'show?', expected: false },
  { user: bob_user, project: bob_project, action: 'update?', expected: true },
  { user: carol_manager, project: team_project, action: 'update?', expected: true },
  { user: bob_user, project: secret_project, action: 'destroy?', expected: false },
  { user: alice_admin, project: team_project, action: 'destroy?', expected: true }
]

test_cases.each do |test|
  result = pundit_tool.call({
    user: test[:user],
    record: test[:project],
    action: test[:action]
  })

  status = result[:authorized] == test[:expected] ? "✅" : "❌"
  puts "#{status} #{test[:user].name} #{test[:action]} '#{test[:project].title}': #{result[:authorized] ? 'ALLOWED' : 'DENIED'}"
  
  if result[:success] == false
    puts "    Error: #{result[:error]}"
  end
end

# Example 2: Direct Security Checks in Business Logic
puts "\n" + "="*70
puts "🔐 Example 2: Secure Business Logic with Permission Gates"
puts "="*70

def secure_project_operation(user, project, operation, pundit_tool)
  puts "\n🔍 Attempting #{operation} on '#{project.title}' for user: #{user.name}"
  
  # Check permission before operation
  result = pundit_tool.call({
    user: user,
    record: project,
    action: "#{operation}?"
  })
  
  if result[:success] && result[:authorized]
    puts "   ✅ Permission granted - executing #{operation}"
    puts "   📊 Policy: #{result[:policy_class]}"
    puts "   🎯 Operation completed successfully"
    true
  elsif result[:success] && !result[:authorized]
    puts "   🚫 Permission denied by #{result[:policy_class]}"
    puts "   🛡️ Security policy enforced - operation blocked"
    false
  else
    puts "   ❌ Permission check failed: #{result[:error]}"
    false
  end
end

# Test secure operations
operations_to_test = [
  { user: alice_admin, project: secret_project, operation: 'show' },
  { user: bob_user, project: bob_project, operation: 'update' },
  { user: carol_manager, project: team_project, operation: 'destroy' },
  { user: bob_user, project: secret_project, operation: 'show' } # Should be denied
]

operations_to_test.each do |test|
  success = secure_project_operation(test[:user], test[:project], test[:operation], pundit_tool)
  puts "   Result: #{success ? 'ALLOWED' : 'BLOCKED'}"
end

# Example 3: Multi-User Permission Comparison
puts "\n" + "="*70
puts "👥 Example 3: Multi-User Permission Comparison"
puts "="*70

actions = ['show?', 'update?', 'destroy?']
users_to_test = [alice_admin, bob_user, carol_manager]
project_to_test = secret_project

puts "Testing permissions for project: #{project_to_test.title} (confidential)"
puts

printf "%-15s", "User"
actions.each { |action| printf "%-12s", action }
puts
puts "-" * 50

users_to_test.each do |user|
  printf "%-15s", user.name
  
  actions.each do |action|
    result = pundit_tool.call({
      user: user,
      record: project_to_test,
      action: action
    })
    
    status = result[:authorized] ? "✅ Allow" : "❌ Deny"
    printf "%-12s", status
  end
  puts
end

# Example 4: Error Handling Scenarios
puts "\n" + "="*70
puts "⚠️ Example 4: Error Handling Scenarios"
puts "="*70

error_test_cases = [
  {
    name: "Missing user parameter",
    input: { record: team_project, action: 'show?' },
    expected_error: "Missing required parameters"
  },
  {
    name: "Invalid action method",
    input: { user: bob_user, record: team_project, action: 'invalid_action?' },
    expected_error: "does not define method"
  },
  {
    name: "Empty action",
    input: { user: bob_user, record: team_project, action: '' },
    expected_error: "Action cannot be empty"
  }
]

error_test_cases.each do |test_case|
  puts "\n🧪 Testing: #{test_case[:name]}"
  
  result = pundit_tool.call(test_case[:input])
  
  if result[:success] == false
    puts "   ✅ Error properly caught: #{result[:error]}"
    if result[:error].include?(test_case[:expected_error])
      puts "   ✅ Expected error message found"
    else
      puts "   ❌ Unexpected error message"
    end
  else
    puts "   ❌ Expected error not caught"
  end
end

puts "\n" + "="*70
puts "🎯 PunditPolicyTool Example Summary"
puts "="*70
puts
puts "✅ Security Features Demonstrated:"
puts "   • Permission verification before AI actions"
puts "   • Multi-level authorization checks (view, update, destroy)"
puts "   • Conditional workflows based on user permissions"
puts "   • Graceful handling of access denied scenarios"
puts "   • Comprehensive error handling and validation"
puts "   • Integration with existing Pundit policies"
puts
puts "🛡️ Security Benefits:"
puts "   • Zero-trust model for AI agent actions"
puts "   • Consistent authorization between humans and AI"
puts "   • Audit trail of all permission checks"
puts "   • Protection against unauthorized access"
puts "   • Fail-safe defaults (deny when unsure)"
puts
puts "🚀 Production Ready Features:"
puts "   • Works with any Pundit-based Rails application"
puts "   • Supports complex multi-step workflows"
puts "   • Integrates seamlessly with other Rdawn tools"
puts "   • Comprehensive logging and error reporting"
puts "   • Optimized for performance and scalability"
puts
puts "🎉 Your AI agents are now as secure as your human users!"
puts "   Ready for production deployment with confidence! 🛡️" 