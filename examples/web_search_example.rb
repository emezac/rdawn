#!/usr/bin/env ruby
# frozen_string_literal: true

# Web Search Example with rdawn + OpenAI
# This example demonstrates how to use OpenAI's web search tool for real-time information
# Based on OpenAI's web search tool documentation

require 'rdawn'
require 'rdawn/tools'
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

puts "🌐 Web Search Example with rdawn + OpenAI"
puts "=" * 50
puts "Demonstrating real-time web search capabilities"
puts ""

# Configure Raix with the working pattern
Raix.configure do |config|
  config.openai_client = OpenAI::Client.new(api_key: ENV['OPENAI_API_KEY'])
end

# Create rdawn web search tool using the convenience method
web_search_tool = Rdawn::Tools.web_search_tool(api_key: ENV['OPENAI_API_KEY'])

begin
  # Step 1: Basic web search
  puts "=== Step 1: Basic Web Search ==="
  puts "🔍 Searching for latest positive news..."
  
  search_result = web_search_tool.search(
    query: "What was a positive news story from today?",
    context_size: 'medium',
    model: 'gpt-4o'
  )
  
  puts "✅ Search successful!"
  puts "🌐 Query: #{search_result[:query]}"
  puts "📄 Result:"
  puts search_result[:content]
  puts "📊 Context size: #{search_result[:context_size]}"
  puts "💰 Usage: #{search_result[:usage]}"
  puts ""

  # Step 2: Web search with location context
  puts "=== Step 2: Location-Based Web Search ==="
  puts "🗺️ Searching for restaurants in London..."
  
  london_search = web_search_tool.search(
    query: "What are the best restaurants around Granary Square?",
    context_size: 'medium',
    user_location: {
      type: 'approximate',
      country: 'GB',
      city: 'London',
      region: 'London'
    },
    model: 'gpt-4o'
  )
  
  puts "✅ Location search successful!"
  puts "🌐 Query: #{london_search[:query]}"
  puts "📍 Location: London, GB"
  puts "📄 Result:"
  puts london_search[:content]
  puts ""

  # Step 3: News search with different context sizes
  puts "=== Step 3: News Search with Different Context Sizes ==="
  
  news_queries = [
    { query: "Latest AI developments 2025", context_size: 'low' },
    { query: "What's happening in tech industry today?", context_size: 'medium' },
    { query: "Recent breakthroughs in renewable energy", context_size: 'high' }
  ]
  
  news_queries.each_with_index do |search_config, index|
    puts "#{index + 1}. Testing context size: #{search_config[:context_size]}"
    puts "   Query: \"#{search_config[:query]}\""
    puts "🔍 Searching..."
    
    begin
      result = web_search_tool.search_news(
        query: search_config[:query],
        context_size: search_config[:context_size],
        model: 'gpt-4o'
      )
      
             puts "✅ Search successful!"
       puts "📄 Summary: #{result[:content][0..200]}..." if result[:content]
       puts "📊 Context: #{result[:context_size]} | Usage: #{result[:usage]}"
     rescue => e
       puts "❌ Search error: #{e.message}"
     end
    
    puts "─" * 40
  end

  # Step 4: Recent information search
  puts "=== Step 4: Recent Information Search ==="
  puts "📅 Searching for recent events..."
  
  recent_searches = [
    { query: "SpaceX launches", timeframe: "today" },
    { query: "stock market performance", timeframe: "this week" },
    { query: "climate change initiatives", timeframe: "this month" }
  ]
  
  recent_searches.each_with_index do |search_config, index|
    puts "#{index + 1}. Recent #{search_config[:timeframe]}: \"#{search_config[:query]}\""
    puts "🔍 Searching..."
    
    begin
      result = web_search_tool.search_recent(
        query: search_config[:query],
        timeframe: search_config[:timeframe],
        context_size: 'medium',
        model: 'gpt-4o'
      )
      
             puts "✅ Search successful!"
       puts "📄 Summary: #{result[:content][0..150]}..." if result[:content]
     rescue => e
       puts "❌ Search error: #{e.message}"
     end
    
    puts "─" * 30
  end

  # Step 5: Filtered web search
  puts "=== Step 5: Filtered Web Search ==="
  puts "🎯 Searching with specific filters..."
  
  filtered_searches = [
    {
      query: "machine learning",
      filters: { site: "arxiv.org", custom: "recent papers" },
      description: "Academic papers from arXiv"
    },
    {
      query: "ruby programming tutorial",
      filters: { filetype: "pdf", custom: "beginner guide" },
      description: "PDF tutorials for beginners"
    },
    {
      query: "OpenAI API documentation",
      filters: { site: "openai.com", custom: "latest updates" },
      description: "Official OpenAI docs"
    }
  ]
  
  filtered_searches.each_with_index do |search_config, index|
    puts "#{index + 1}. #{search_config[:description]}"
    puts "   Query: \"#{search_config[:query]}\""
    puts "   Filters: #{search_config[:filters]}"
    puts "🔍 Searching..."
    
    begin
      result = web_search_tool.search_with_filters(
        query: search_config[:query],
        filters: search_config[:filters],
        context_size: 'medium',
        model: 'gpt-4o'
      )
      
             puts "✅ Filtered search successful!"
       puts "📄 Summary: #{result[:content][0..200]}..." if result[:content]
     rescue => e
       puts "❌ Search error: #{e.message}"
     end
    
    puts "─" * 30
  end

  # Step 6: Multiple search queries
  puts "=== Step 6: Multiple Search Queries ==="
  puts "🔄 Running multiple searches in batch..."
  
  multiple_queries = [
    "What are the latest developments in quantum computing?",
    "How is AI being used in healthcare today?",
    "What are the top tech trends for 2025?",
    "Recent breakthroughs in space exploration"
  ]
  
  results = web_search_tool.multi_search(
    queries: multiple_queries,
    context_size: 'medium',
    model: 'gpt-4o'
  )
  
  puts "✅ Batch search completed!"
  puts "📊 Processed #{results.length} queries:"
  
  results.each_with_index do |result, index|
    if result[:error]
      puts "#{index + 1}. ❌ Error: #{result[:error]}"
         else
       puts "#{index + 1}. ✅ \"#{result[:query]}\""
       puts "    Summary: #{result[:content][0..120]}..." if result[:content]
     end
  end

  # Step 7: Integration with LLM for analysis
  puts "\n=== Step 7: LLM Integration and Analysis ==="
  puts "🤖 Using web search results with LLM analysis..."
  
  # Search for current tech trends
  tech_search = web_search_tool.search(
    query: "What are the biggest technology trends in 2025?",
    context_size: 'high',
    model: 'gpt-4o'
  )
  
  if tech_search[:content]
    puts "✅ Web Search Analysis Complete!"
    puts "🤖 Current Tech Trends Analysis:"
    puts "📊 Search Query: #{tech_search[:query]}"
    puts "📄 Comprehensive Results:"
    puts tech_search[:content]
    puts "💰 Usage: #{tech_search[:usage]}"
    puts ""
    puts "🔍 This data can be further processed by LLM for structured analysis:"
    puts "   • Extract top 5 most significant trends"
    puts "   • Analyze potential impact on businesses"
    puts "   • Provide recommendations for developers"
    puts "   • Format with bullet points and explanations"
  else
    puts "⚠️ Could not retrieve search results for LLM analysis"
  end

rescue => e
  puts "❌ Error during execution: #{e.message}"
  puts "🔧 Error details: #{e.backtrace.first(3).join("\n")}"
end

puts "\n" + "=" * 50
puts "🎉 Web Search Example Complete!"
puts ""
puts "💡 This example demonstrated:"
puts "   • Basic web search with real-time results"
puts "   • Location-based search queries"
puts "   • Different context sizes (low, medium, high)"
puts "   • Recent information searches"
puts "   • Filtered searches with specific criteria"
puts "   • Batch processing of multiple queries"
puts "   • LLM integration for result analysis"
puts ""
puts "💰 Estimated cost: ~$0.05-0.20 (multiple searches + LLM analysis)"
puts "📚 Learn more: https://platform.openai.com/docs/guides/web-search" 