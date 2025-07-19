#!/usr/bin/env ruby
# frozen_string_literal: true

# Vector Store Example with rdawn + OpenAI
# This example demonstrates how to create and use OpenAI Vector Stores
# Equivalent to the Python version but using rdawn tools

require 'rdawn'
require 'raix'
require 'openai'
require 'tempfile'
require 'fileutils'

# Check if OpenAI API key is set
unless ENV['OPENAI_API_KEY']
  puts "❌ Error: Please set your OpenAI API key:"
  puts "export OPENAI_API_KEY='your-openai-api-key-here'"
  puts ""
  puts "Get your API key at: https://platform.openai.com/api-keys"
  exit 1
end

puts "🗂️ Vector Store Example with rdawn + OpenAI"
puts "=" * 50
puts "Demonstrating how to create and use OpenAI Vector Stores"
puts ""

# Configure Raix with the working pattern
Raix.configure do |config|
  config.openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
end

# Create rdawn tools
file_upload_tool = Rdawn::Tools::FileUploadTool.new(api_key: ENV['OPENAI_API_KEY'])
vector_store_tool = Rdawn::Tools::VectorStoreTool.new(api_key: ENV['OPENAI_API_KEY'])
file_search_tool = Rdawn::Tools::FileSearchTool.new(api_key: ENV['OPENAI_API_KEY'])

begin
  # Step 1: Create a sample text file to upload
  puts "=== Step 1: Creating a sample text file ==="
  sample_text = <<~TEXT
    This is a sample document about artificial intelligence and machine learning.
    
    AI systems can process large amounts of data and extract meaningful insights.
    Vector stores are useful for storing and retrieving information using semantic similarity.
    
    Machine learning algorithms can identify patterns in data that humans might miss.
    Natural language processing enables computers to understand and generate human language.
    
    Modern AI applications include:
    - Chatbots and virtual assistants
    - Image recognition and computer vision
    - Recommendation systems
    - Autonomous vehicles
    - Medical diagnosis assistance
    
    Vector databases enable efficient similarity search across large datasets.
    They convert text into high-dimensional vectors that capture semantic meaning.
    
    OpenAI's embedding models can transform text into vectors that preserve contextual relationships.
    This enables powerful search capabilities based on meaning rather than exact keyword matches.
  TEXT

  # Create temporary file
  temp_file = Tempfile.new(['sample_document', '.txt'])
  temp_file.write(sample_text)
  temp_file.close
  
  puts "✅ Created sample file at: #{temp_file.path}"
  puts "📄 File size: #{File.size(temp_file.path)} bytes"
  puts ""

  # Step 2: Upload the file to OpenAI
  puts "=== Step 2: Uploading the file to OpenAI ==="
  puts "🔄 Uploading file..."
  
  upload_result = file_upload_tool.upload_file(
    file_path: temp_file.path,
    purpose: 'assistants'
  )
  
  if upload_result.nil? || upload_result.empty?
    puts "❌ Error: Failed to upload file"
    exit 1
  end
  
  file_id = upload_result['id'] || upload_result[:id]
  puts "✅ File uploaded successfully!"
  puts "📁 File ID: #{file_id}"
  puts "📊 File details: #{upload_result['filename'] || upload_result[:filename]} (#{upload_result['bytes'] || upload_result[:bytes]} bytes)"
  puts ""

  # Step 3: Create a vector store with the uploaded file
  puts "=== Step 3: Creating a vector store with the file ==="
  puts "🔄 Creating vector store..."
  
  vector_store_result = vector_store_tool.create_vector_store(
    name: 'AI Knowledge Base',
    file_ids: [file_id]
  )
  
  if vector_store_result.nil? || vector_store_result.empty?
    puts "❌ Error: Failed to create vector store"
    exit 1
  end
  
  vector_store_id = vector_store_result['id'] || vector_store_result[:id]
  puts "✅ Vector store created successfully!"
  puts "🗂️ Vector Store ID: #{vector_store_id}"
  puts "📝 Vector Store Name: #{vector_store_result['name'] || vector_store_result[:name]}"
  puts "📊 File Count: #{vector_store_result['file_counts'] || vector_store_result[:file_counts]}"
  puts ""

  # Wait a moment for processing
  puts "⏳ Waiting for vector store to process file..."
  sleep 3
  puts ""

  # Step 4: Query the vector store
  puts "=== Step 4: Querying the vector store ==="
  
  queries = [
    "What is artificial intelligence?",
    "How do vector stores work?",
    "What are some applications of AI?",
    "Tell me about machine learning algorithms"
  ]
  
  queries.each_with_index do |query, index|
    puts "#{index + 1}. Query: \"#{query}\""
    puts "🔍 Searching..."
    
    begin
      search_result = file_search_tool.search_files(
        query: query,
        vector_store_ids: [vector_store_id],
        max_results: 3
      )
      
      if search_result && search_result[:content]
        puts "✅ Search successful!"
        puts "📄 Result:"
        puts search_result[:content]
        puts "📊 Confidence: #{search_result[:confidence] || 'N/A'}"
      else
        puts "⚠️ No results found for this query"
      end
    rescue => e
      puts "❌ Search error: #{e.message}"
    end
    
    puts "─" * 30
  end
  
  # Step 5: Advanced query with LLM integration
  puts "=== Step 5: Advanced query with LLM integration ==="
  puts "🤖 Using LLM to analyze search results..."
  
  # Create working LLM interface
  class WorkingLLMInterface
    include Raix::ChatCompletion
    
    def initialize(model)
      @model = model
    end
    
    def execute_llm_call(prompt:, model_params: {})
      transcript.clear
      transcript << { user: prompt }
      chat_completion(openai: @model)
    end
  end
  
  llm_interface = WorkingLLMInterface.new('gpt-4o-mini')
  
  # Search for AI applications and then ask LLM to summarize
  search_result = file_search_tool.search_files(
    query: "applications of artificial intelligence",
    vector_store_ids: [vector_store_id],
    max_results: 5
  )
  
  if search_result && search_result[:content]
    enhanced_prompt = <<~PROMPT
      Based on the following information from a vector store search about AI applications:
      
      #{search_result[:content]}
      
      Please provide a structured summary of AI applications mentioned in the text. 
      Format your response as a numbered list with brief explanations.
    PROMPT
    
    llm_response = llm_interface.execute_llm_call(
      prompt: enhanced_prompt,
      model_params: { temperature: 0.7, max_tokens: 300 }
    )
    
    puts "✅ LLM Analysis Complete!"
    puts "🤖 AI Summary of Applications:"
    puts llm_response
  else
    puts "⚠️ Could not retrieve search results for LLM analysis"
  end

rescue => e
  puts "❌ Error during execution: #{e.message}"
  puts "🔧 Error details: #{e.backtrace.first(3).join("\n")}"
  
ensure
  # Step 6: Cleanup
  puts "\n=== Step 6: Cleanup ==="
  
  # Clean up the temporary file
  begin
    temp_file.unlink if temp_file
    puts "✅ Temporary file cleaned up"
  rescue => e
    puts "⚠️ Could not clean up temporary file: #{e.message}"
  end
  
  # Note: In a real application, you might want to clean up the uploaded file and vector store
  # but for this example, we'll leave them for inspection
  puts "📝 Note: OpenAI file and vector store were left for inspection"
  puts "   File ID: #{file_id}" if defined?(file_id)
  puts "   Vector Store ID: #{vector_store_id}" if defined?(vector_store_id)
end

puts "\n" + "=" * 50
puts "🎉 Vector Store Example Complete!"
puts ""
puts "💡 This example demonstrated:"
puts "   • File upload to OpenAI"
puts "   • Vector store creation"
puts "   • Semantic search queries"
puts "   • LLM integration with search results"
puts "   • Error handling and cleanup"
puts ""
puts "💰 Estimated cost: ~$0.01-0.05 (file processing + queries + LLM calls)" 