#!/usr/bin/env ruby
# frozen_string_literal: true

# Markdown Tool Example with rdawn + OpenAI + Marksmith
# This example demonstrates comprehensive markdown editing capabilities including:
# - AI-powered content generation
# - Markdown editing and formatting  
# - Template creation
# - HTML conversion
# - Validation and suggestions

require 'rdawn'
require 'raix'
require 'openai'
require 'fileutils'

# Check if OpenAI API key is set
unless ENV['OPENAI_API_KEY']
  puts "❌ Error: Please set your OpenAI API key:"
  puts "export OPENAI_API_KEY='your-openai-api-key-here'"
  puts ""
  puts "Get your API key at: https://platform.openai.com/api-keys"
  exit 1
end

puts "📝 Markdown Tool Example with rdawn + OpenAI"
puts "=" * 50
puts "Demonstrating comprehensive markdown editing capabilities"
puts ""

# Configure Raix
Raix.configure do |config|
  config.openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
end

# Create rdawn markdown tool
markdown_tool = Rdawn::Tools::MarkdownTool.new(api_key: ENV['OPENAI_API_KEY'])

# Create temporary directory for examples
temp_dir = File.join(Dir.tmpdir, 'rdawn_markdown_examples')
FileUtils.mkdir_p(temp_dir)

begin
  # Step 1: Generate AI-powered markdown content
  puts "=== Step 1: AI-Powered Markdown Generation ==="
  puts "📝 Generating technical article about Ruby on Rails..."
  
  generation_result = markdown_tool.generate_markdown(
    prompt: "Best practices for Ruby on Rails development in 2025",
    style: 'technical',
    length: 'medium',
    model: 'gpt-4o-mini'
  )
  
  puts "✅ Generation successful!"
  puts "📊 Word count: #{generation_result[:word_count]}"
  puts "🎨 Style: #{generation_result[:style]}"
  puts "📏 Length: #{generation_result[:length]}"
  puts "📄 Sample content:"
  puts generation_result[:markdown][0..300] + "..."
  puts ""
  
  # Save generated content for further use
  generated_file = File.join(temp_dir, 'generated_article.md')
  File.write(generated_file, generation_result[:markdown])
  
  # Step 2: Edit existing markdown with AI
  puts "=== Step 2: AI-Powered Markdown Editing ==="
  puts "✏️ Editing the generated content to be more beginner-friendly..."
  
  edit_result = markdown_tool.edit_markdown(
    markdown: generation_result[:markdown],
    instructions: "Make this content more beginner-friendly by adding explanations for technical terms and including more examples",
    model: 'gpt-4o-mini',
    preserve_style: true
  )
  
  puts "✅ Edit successful!"
  puts "📊 Word count before: #{edit_result[:word_count_before]}"
  puts "📊 Word count after: #{edit_result[:word_count_after]}"
  puts "📈 Changes summary: #{edit_result[:changes_summary]}"
  puts "📄 Sample edited content:"
  puts edit_result[:edited_markdown][0..300] + "..."
  puts ""
  
  # Save edited content
  edited_file = File.join(temp_dir, 'edited_article.md')
  File.write(edited_file, edit_result[:edited_markdown])
  
  # Step 3: Create markdown templates
  puts "=== Step 3: Markdown Template Creation ==="
  puts "📋 Creating various markdown templates..."
  
  template_types = [
    { type: 'readme', title: 'My Awesome Project', author: 'John Developer' },
    { type: 'blog_post', title: 'Getting Started with Rails', author: 'Jane Writer', tags: ['rails', 'ruby', 'tutorial'] },
    { type: 'api_docs', title: 'REST API', author: 'API Team' },
    { type: 'article', title: 'Ruby Best Practices', author: 'Expert Developer', tags: ['ruby', 'best-practices'] }
  ]
  
  template_results = []
  template_types.each do |template_config|
    result = markdown_tool.create_template(**template_config)
    template_results << result
    
    puts "✅ Created #{result[:type]} template: \"#{result[:title]}\""
    puts "   Author: #{result[:author]}"
    puts "   Tags: #{result[:tags].join(', ')}" if result[:tags].any?
    
    # Save template
    template_file = File.join(temp_dir, "template_#{result[:type]}.md")
    File.write(template_file, result[:template_markdown])
    
    puts "   💾 Saved to: #{template_file}"
  end
  puts ""
  
  # Step 4: Format and validate markdown
  puts "=== Step 4: Markdown Formatting and Validation ==="
  puts "🔧 Formatting and validating markdown content..."
  
  # Test with a sample markdown that has issues
  test_markdown = <<~MARKDOWN
    # Main Title
    
    ### Skipped H2 (should be H2)
    
    This is a very long line that exceeds the typical line length limit and should be wrapped when formatting with a specific line length setting to make it more readable.
    
    - List item 1
    - List item 2
    -List item 3 (missing space)
    
    ```ruby
    def hello
      puts "Hello world"
    # Missing closing ```
    
    [Broken link](http://example.com/nonexistent)
    
    | Column 1 | Column 2
    | Data 1 | Data 2 |
    | Data 3 | Data 4
  MARKDOWN
  
  # Format the markdown
  format_result = markdown_tool.format_markdown(
    markdown: test_markdown,
    style: 'standard',
    line_length: 80
  )
  
  puts "✅ Formatting complete!"
  puts "📏 Line length limit: #{format_result[:line_length]}"
  puts "🎨 Style: #{format_result[:style]}"
  puts "📄 Sample formatted content:"
  puts format_result[:formatted_markdown][0..300] + "..."
  puts ""
  
  # Validate the markdown
  validation_result = markdown_tool.validate_markdown(
    markdown: test_markdown,
    strict: true
  )
  
  puts "📋 Validation results:"
  puts "✅ Valid: #{validation_result[:valid]}"
  puts "❌ Issues found: #{validation_result[:issue_count]}"
  
  validation_result[:issues].each do |issue|
    puts "  - #{issue[:type]}: #{issue[:message]}"
  end
  puts ""
  
  # Step 5: Generate table of contents
  puts "=== Step 5: Table of Contents Generation ==="
  puts "📑 Generating table of contents..."
  
  toc_styles = ['bullet', 'numbered', 'links']
  toc_styles.each do |style|
    toc_result = markdown_tool.generate_toc(
      markdown: edit_result[:edited_markdown],
      max_depth: 3,
      style: style
    )
    
    puts "✅ Generated #{style} TOC (#{toc_result[:headings_count]} headings):"
    puts toc_result[:toc_markdown]
    puts "─" * 40
  end
  puts ""
  
  # Step 6: Convert markdown to HTML
  puts "=== Step 6: Markdown to HTML Conversion ==="
  puts "🌐 Converting markdown to HTML..."
  
  html_result = markdown_tool.markdown_to_html(
    markdown: edit_result[:edited_markdown],
    github_style: true,
    syntax_highlighting: true
  )
  
  puts "✅ HTML conversion complete!"
  puts "🎨 GitHub style: #{html_result[:github_style]}"
  puts "🎨 Syntax highlighting: #{html_result[:syntax_highlighting]}"
  puts "📄 Sample HTML:"
  puts html_result[:html][0..300] + "..."
  puts ""
  
  # Save HTML output
  html_file = File.join(temp_dir, 'converted_article.html')
  File.write(html_file, html_result[:html])
  puts "💾 HTML saved to: #{html_file}"
  puts ""
  
  # Step 7: AI-powered content suggestions
  puts "=== Step 7: AI-Powered Content Suggestions ==="
  puts "🤖 Analyzing content for improvements..."
  
  suggestion_focuses = ['readability', 'structure', 'grammar', 'seo']
  suggestion_focuses.each do |focus|
    puts "🔍 Analyzing for #{focus}..."
    
    suggestions_result = markdown_tool.suggest_improvements(
      markdown: edit_result[:edited_markdown],
      focus: focus,
      model: 'gpt-4o-mini'
    )
    
    puts "✅ Analysis complete!"
    puts "📊 Focus: #{suggestions_result[:focus]}"
    puts "💡 Suggestions:"
    
    suggestions_result[:suggestions].each do |suggestion|
      puts "  📂 #{suggestion[:category]}"
      suggestion[:items].each do |item|
        puts "    • #{item}"
      end
    end
    puts "─" * 40
  end
  puts ""
  
  # Step 8: Marksmith integration demo
  puts "=== Step 8: Marksmith Integration Demo ==="
  puts "🚀 Creating Marksmith-compatible form fields..."
  
  marksmith_fields = [
    { field_name: 'blog_content', initial_content: generation_result[:markdown][0..500], placeholder: 'Write your blog post...' },
    { field_name: 'documentation', initial_content: '', placeholder: 'Enter documentation...' },
    { field_name: 'notes', initial_content: '# Quick Notes\n\n- Note 1\n- Note 2', placeholder: 'Add your notes...' }
  ]
  
  marksmith_fields.each do |field_config|
    field_result = markdown_tool.create_marksmith_field(**field_config)
    
    puts "✅ Created Marksmith field: #{field_result[:field_name]}"
    puts "📝 Initial content length: #{field_result[:initial_content].length} characters"
    puts "🔧 Form helper code:"
    puts field_result[:form_helper] if field_result[:form_helper]
    puts field_result[:fallback_textarea] if field_result[:fallback_textarea]
    puts "⚠️ #{field_result[:warning]}" if field_result[:warning]
    puts "─" * 40
  end
  puts ""
  
  # Step 9: Batch processing demo
  puts "=== Step 9: Batch Processing Demo ==="
  puts "📦 Processing multiple markdown files..."
  
  # Create some test files
  test_files = []
  3.times do |i|
    test_content = markdown_tool.create_template(
      type: 'article',
      title: "Test Article #{i + 1}",
      author: "Test Author #{i + 1}",
      tags: ["test", "example", "batch"]
    )
    
    test_file = File.join(temp_dir, "test_article_#{i + 1}.md")
    File.write(test_file, test_content[:template_markdown])
    test_files << test_file
  end
  
  # Batch process the files
  batch_operations = ['format', 'validate', 'generate_toc']
  batch_operations.each do |operation|
    puts "🔄 Running batch #{operation}..."
    
    batch_result = markdown_tool.batch_process(
      files: test_files,
      operation: operation,
      style: 'standard',
      max_depth: 2
    )
    
    puts "✅ Batch #{operation} complete!"
    puts "📊 Files processed: #{batch_result[:files_processed]}"
    puts "✅ Successful: #{batch_result[:successful]}"
    puts "❌ Failed: #{batch_result[:failed]}"
    puts "─" * 40
  end
  puts ""
  
  # Step 10: Create a complete markdown workflow
  puts "=== Step 10: Complete Markdown Workflow Demo ==="
  puts "🔄 Demonstrating a complete markdown workflow..."
  
  workflow_steps = [
    "1. Generate initial content",
    "2. Edit for target audience", 
    "3. Format and validate",
    "4. Generate table of contents",
    "5. Convert to HTML",
    "6. Get improvement suggestions"
  ]
  
  puts "📋 Workflow steps:"
  workflow_steps.each { |step| puts "   #{step}" }
  puts ""
  
  # Execute complete workflow
  puts "🚀 Executing complete workflow..."
  
  workflow_result = {
    generated: markdown_tool.generate_markdown(
      prompt: "Introduction to Ruby metaprogramming",
      style: 'technical',
      length: 'short'
    ),
    edited: nil,
    formatted: nil,
    toc: nil,
    html: nil,
    suggestions: nil
  }
  
  workflow_result[:edited] = markdown_tool.edit_markdown(
    markdown: workflow_result[:generated][:markdown],
    instructions: "Add more practical examples and code snippets"
  )
  
  workflow_result[:formatted] = markdown_tool.format_markdown(
    markdown: workflow_result[:edited][:edited_markdown],
    style: 'standard'
  )
  
  workflow_result[:toc] = markdown_tool.generate_toc(
    markdown: workflow_result[:formatted][:formatted_markdown],
    max_depth: 3,
    style: 'bullet'
  )
  
  workflow_result[:html] = markdown_tool.markdown_to_html(
    markdown: workflow_result[:formatted][:formatted_markdown],
    github_style: true
  )
  
  workflow_result[:suggestions] = markdown_tool.suggest_improvements(
    markdown: workflow_result[:formatted][:formatted_markdown],
    focus: 'readability'
  )
  
  puts "✅ Complete workflow executed successfully!"
  puts "📊 Final word count: #{workflow_result[:edited][:word_count_after]}"
  puts "📑 TOC headings: #{workflow_result[:toc][:headings_count]}"
  puts "🌐 HTML length: #{workflow_result[:html][:html].length} characters"
  puts "💡 Suggestions: #{workflow_result[:suggestions][:suggestions].length} categories"
  puts ""
  
  # Save final workflow result
  final_file = File.join(temp_dir, 'final_workflow_result.md')
  final_content = <<~FINAL
    # Ruby Metaprogramming Guide
    
    ## Table of Contents
    #{workflow_result[:toc][:toc_markdown]}
    
    ## Content
    #{workflow_result[:formatted][:formatted_markdown]}
    
    ## Improvement Suggestions
    #{workflow_result[:suggestions][:suggestions].map { |s| "### #{s[:category]}\n#{s[:items].map { |i| "- #{i}" }.join("\n")}" }.join("\n\n")}
  FINAL
  
  File.write(final_file, final_content)
  puts "💾 Final workflow result saved to: #{final_file}"
  
rescue => e
  puts "❌ Error during execution: #{e.message}"
  puts "🔧 Error details: #{e.backtrace.first(3).join("\n")}"
ensure
  puts "\n🧹 Cleanup: Temporary files saved in #{temp_dir}"
  puts "You can review all generated files in that directory."
end

puts "\n" + "=" * 50
puts "🎉 Markdown Tool Example Complete!"
puts ""
puts "💡 This example demonstrated:"
puts "   • AI-powered markdown content generation"
puts "   • Intelligent content editing and refinement"
puts "   • Multiple template types (README, blog, API docs, etc.)"
puts "   • Markdown formatting and validation"
puts "   • Table of contents generation (multiple styles)"
puts "   • HTML conversion with GitHub styling"
puts "   • AI-powered content improvement suggestions"
puts "   • Marksmith form field integration"
puts "   • Batch processing of multiple files"
puts "   • Complete end-to-end workflow automation"
puts ""
puts "🔧 Marksmith Integration:"
puts "   • Add 'marksmith' and 'commonmarker' gems to your Rails app"
puts "   • Include Marksmith JavaScript and CSS assets"
puts "   • Use the generated form helpers for GitHub-style editing"
puts "   • Leverage AI-powered content generation in your forms"
puts ""
puts "💰 Estimated cost: ~$0.10-0.50 (multiple AI operations)"
puts "📚 Learn more: https://github.com/avo-hq/marksmith" 