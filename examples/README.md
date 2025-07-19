# rdawn Examples

This directory contains a simple working example of the rdawn gem with real OpenAI integration.

## 🚀 Quick Start

### Prerequisites

1. **Ruby 3.0+** installed
2. **rdawn gem** installed (`gem install rdawn`)
3. **OpenAI API key** from https://platform.openai.com/api-keys

### Setup

1. **Set your OpenAI API key:**
   ```bash
   export OPENAI_API_KEY="sk-your-actual-api-key-here"
   ```

2. **Run the examples:**
   ```bash
   cd examples
   ruby simple_example.rb                    # Basic LLM integration
   ruby vector_store_example.rb              # Vector store demonstration
   ruby web_search_example.rb                # Web search with real-time info
   ruby markdown_example.rb                  # Markdown editing with AI + Marksmith
   ruby legal_review_workflow_example.rb     # Complete legal workflow (advanced)
   ruby cron_example.rb                      # Task scheduling with cron expressions
   ```

### Expected Output

```
🤖 Working rdawn + OpenAI Example
========================================
Making a real API call to OpenAI to get latest Trump news...
🚀 Calling OpenAI API...
Model: gpt-4o-mini
----------------------------------------
✅ Success!

🤖 AI Response:
As of my last update in October 2023, I don't have access to real-time news updates. However, I can summarize some of the key developments regarding Donald Trump up to that point:

1. **Legal Challenges**: Trump has faced multiple legal challenges, including criminal charges related to his business practices, election interference, and classified documents. These cases have been ongoing, with various court dates and hearings scheduled.

2. **2024 Presidential Campaign**: Trump has been actively campaigning for the 2024 presidential election, maintaining a strong presence in Republican primaries. He has been holding rallies and making public appearances to solidify his support among GOP voters.

3. **Public Statements and Controversies**: Trump has continued to make headlines with his statements on social media and in public speeches, often addressing his legal issues, criticizing opponents, and discussing his vision for the country.

4. **Polls and Support**: Despite his legal troubles, Trump has remained a leading figure in Republican polls, often showing strong support among party members.

For the most current updates, I recommend checking reliable news sources.

✨ Real OpenAI API response received successfully!
========================================
🎉 Example complete!
```

## 📋 What This Example Shows

- ✅ **Real OpenAI API calls** (no mocks)
- ✅ **Basic rdawn workflow** with one AI task
- ✅ **Proper configuration** for OpenAI integration
- ✅ **Error handling** with helpful messages
- ✅ **Cost-effective** using `gpt-4o-mini` model

## 🗂️ Vector Store Example

The `vector_store_example.rb` demonstrates comprehensive OpenAI Vector Store functionality:

### Features Demonstrated

- **File Upload**: Upload documents to OpenAI
- **Vector Store Creation**: Create and configure vector stores  
- **Semantic Search**: Query documents using natural language
- **LLM Integration**: Analyze search results with AI
- **Error Handling**: Robust error handling and cleanup

### What It Does

1. **Creates sample content** about AI and machine learning
2. **Uploads file** to OpenAI for processing
3. **Creates vector store** with semantic search capabilities
4. **Performs queries** like "What is artificial intelligence?"
5. **Integrates with LLM** to analyze and summarize results
6. **Handles cleanup** of temporary files

### Expected Results

- **File Upload**: Successfully processes and uploads sample document
- **Vector Store**: Creates indexed, searchable knowledge base
- **Semantic Search**: Returns relevant, context-aware responses
- **LLM Analysis**: Provides structured summaries and insights
- **Cost**: ~$0.01-0.05 per run (includes file processing + queries + LLM calls)

## 🌐 Web Search Example

The `web_search_example.rb` demonstrates OpenAI's web search capabilities for real-time information:

### Features Demonstrated

- **Basic Web Search**: Get current news and real-time information
- **Location-Based Search**: Query with geographic context
- **Context Sizes**: Test different search depths (low, medium, high)
- **Recent Information**: Search for events with timeframes
- **Filtered Searches**: Use specific filters and criteria
- **Batch Processing**: Run multiple searches efficiently
- **LLM Integration**: Analyze search results with AI

### What It Does

1. **Basic searches** for current positive news stories
2. **Location-based searches** for restaurants in London
3. **Context size testing** with different query depths
4. **Recent event searches** with timeframes (today, this week, this month)
5. **Filtered searches** for specific sites and file types
6. **Batch processing** of multiple queries
7. **LLM integration** for analyzing and summarizing results

### Expected Results

- **Real-time Information**: Current news, events, and data
- **Location Context**: Geographic search results
- **Varied Depth**: Different levels of detail based on context size
- **Structured Output**: Formatted results with citations
- **Cost**: ~$0.05-0.20 per run (multiple searches + LLM analysis)

## 💰 Cost

- **Simple Example**: ~$0.001 per run using `gpt-4o-mini`
- **Vector Store Example**: ~$0.01-0.05 per run (includes file processing + queries + LLM calls)
- **Web Search Example**: ~$0.05-0.20 per run (multiple searches + LLM analysis)
- **Markdown Tool Example**: ~$0.10-0.50 per run (multiple AI operations)
- **Legal Review Workflow**: ~$0.50-2.00 per run (comprehensive workflow)

## ⚖️ Legal Review Workflow Example

The `legal_review_workflow_example.rb` demonstrates a complete context-aware legal contract review system:

### Advanced Features Demonstrated

- **Vector Store Integration**: Document storage and semantic search
- **Long-Term Memory (LTM)**: Context retention across reviews
- **File Search with LLM**: Semantic document retrieval
- **DirectHandlerTask**: Custom business logic processing
- **Enhanced Variable Resolution**: Complex data structure navigation
- **Web Search Integration**: Recent legal updates and developments
- **AI-Powered Analysis**: Comprehensive contract review and recommendations
- **Workflow Orchestration**: Multi-stage automated legal analysis

### What It Does

1. **Creates Legal Knowledge Base** with internal guidelines and standard clauses
2. **Sets up Long-Term Memory** for context retention
3. **Analyzes Draft Contract** to extract key topics and clauses
4. **Searches Internal Documents** for relevant guidelines (parallel)
5. **Searches Web Updates** for recent legal developments (parallel)
6. **Synthesizes Findings** with AI-powered legal analysis
7. **Saves to LTM** for future reference and context
8. **Generates Reports** in structured markdown format
9. **Creates Risk Assessment** matrix and templates

### Expected Results

- **Comprehensive Legal Analysis**: Topic extraction, compliance checking, risk assessment
- **Internal Guidelines Compliance**: Automated checking against company policies
- **Recent Legal Updates**: Current developments affecting contract terms
- **Structured Recommendations**: High/medium/low priority action items
- **Long-Term Context**: Memory retention for future similar contracts
- **Professional Reports**: Markdown-formatted legal review documents
- **Cost**: ~$0.50-2.00 per run (comprehensive multi-stage workflow)

### Real-World Applications

Perfect for:
- Law firms automating contract review
- Corporate legal departments
- Compliance teams
- Contract management systems
- Legal technology platforms

## 📝 Markdown Tool Example

The `markdown_example.rb` demonstrates comprehensive markdown editing capabilities with Marksmith integration:

### Features Demonstrated

- **AI-Powered Generation**: Generate markdown content with different styles and lengths
- **Intelligent Editing**: Edit content with AI assistance while preserving style
- **Template Creation**: Multiple template types (README, blog, API docs, articles)
- **Formatting & Validation**: Format content and validate syntax
- **Table of Contents**: Generate TOC in different styles (bullet, numbered, links)
- **HTML Conversion**: Convert markdown to HTML with GitHub styling
- **AI Suggestions**: Get improvement suggestions for readability, structure, grammar, SEO
- **Marksmith Integration**: Generate form helpers for Rails applications
- **Batch Processing**: Process multiple files simultaneously
- **Complete Workflows**: End-to-end automation examples

### What It Does

1. **AI Content Generation** with customizable styles and lengths
2. **Smart content editing** with AI assistance
3. **Template creation** for various document types
4. **Format validation** and syntax checking
5. **TOC generation** in multiple styles
6. **HTML conversion** with GitHub-style rendering
7. **AI-powered suggestions** for content improvement
8. **Marksmith form fields** for Rails integration
9. **Batch file processing** for multiple documents
10. **Complete workflow automation** from generation to publication

### Expected Results

- **AI-Generated Content**: Professional, well-structured markdown content
- **Template Variety**: README, blog posts, API documentation, articles
- **Format Validation**: Syntax checking and issue detection
- **GitHub-Style HTML**: Properly rendered HTML with syntax highlighting
- **Marksmith Integration**: Rails form helpers for GitHub-style editing
- **Cost**: ~$0.10-0.50 per run (multiple AI operations)

### Marksmith Integration

The example shows how to:
- Generate Marksmith-compatible form fields
- Create Rails form helpers for GitHub-style editing
- Integrate AI-powered content generation with form inputs
- Use fallback textareas when Marksmith is not available

## 🕐 Cron Tool Example

The `cron_example.rb` demonstrates comprehensive task scheduling capabilities using the rufus-scheduler gem:

### Features Demonstrated

- **Cron Expression Scheduling**: Schedule tasks with standard cron expressions
- **One-Time Scheduling**: Schedule tasks to run at specific future times
- **Recurring Intervals**: Schedule tasks with simple intervals (30s, 5m, 1h, 1d)
- **Tool Execution**: Schedule rdawn tools to run automatically
- **Workflow Integration**: Schedule complete workflows (when available)
- **Job Management**: List, inspect, execute, and unschedule jobs
- **Event Callbacks**: Set up before/after execution and error callbacks
- **Statistics Tracking**: Monitor job execution statistics
- **ToolRegistry Integration**: Use cron functionality through the tool registry

### What It Does

1. **Schedule a daily task** with cron expression `"0 9 * * *"` (9 AM daily)
2. **Schedule one-time tasks** for specific future times
3. **Schedule recurring tasks** with simple intervals like `"30s"` or `"5m"`
4. **Schedule tool execution** to run web searches, markdown generation, etc.
5. **Set up event callbacks** for monitoring job lifecycle
6. **List and inspect** all scheduled jobs
7. **Execute jobs immediately** outside their normal schedule
8. **Track statistics** about job execution success/failure
9. **Manage scheduler** lifecycle (start, stop, restart)
10. **ToolRegistry integration** for seamless rdawn integration

### Expected Results

- **Automated Task Execution**: Tasks run automatically on schedule
- **Flexible Scheduling**: Support for cron expressions and simple intervals
- **Real-time Monitoring**: Live job execution with callbacks
- **Statistics Tracking**: Detailed execution metrics
- **Error Handling**: Graceful error handling with callbacks
- **Integration**: Seamless integration with rdawn workflows and tools
- **Cost**: Minimal overhead - only pays for scheduled tool/workflow execution

### Real-World Applications

Perfect for:
- Automated report generation
- Scheduled data processing
- Periodic web scraping
- Automated backups
- Scheduled notifications
- Maintenance tasks
- Workflow automation
- Background job scheduling

## 🛠️ Troubleshooting

### Common Issues

**API Key Not Set:**
```
❌ Error: Please set your OpenAI API key
```
**Solution:** Export your API key as shown above

**Invalid API Key:**
```
❌ Error: the server responded with status 401
```
**Solution:** Check your API key and ensure billing is set up

**No API Credits:**
```
❌ Error: insufficient quota
```
**Solution:** Add credits to your OpenAI account

**Rate Limiting:**
```
❌ Error: Rate limit exceeded
```
**Solution:** Wait a moment and try again

### Debugging

1. **Check your API key:**
   ```bash
   echo $OPENAI_API_KEY
   ```

2. **Test API connectivity:**
   ```bash
   curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models
   ```

3. **Check your OpenAI account:**
   - Visit https://platform.openai.com/account/billing
   - Ensure you have credits and billing is set up

## 🔧 How It Works

The example demonstrates the basic rdawn workflow:

1. **Configure rdawn** with your OpenAI API key
2. **Create a workflow** with a unique ID and name
3. **Add an AI task** with a prompt and model parameters
4. **Create an LLM interface** configured for OpenAI
5. **Create an agent** with the workflow and LLM interface
6. **Run the workflow** and get the AI response

## 🚀 Next Steps

Once this example works:

1. **Modify the prompt** to test different AI responses
2. **Add more tasks** to create multi-step workflows
3. **Integrate with Rails** applications
4. **Build custom tools** and DirectHandlerTasks
5. **Create production workflows** for your use case

## 🔗 Resources

- [rdawn Documentation](../rdawn/README.md)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Get OpenAI API Key](https://platform.openai.com/api-keys)

---

**Ready to test?** 

1. Set your OpenAI API key: `export OPENAI_API_KEY="your-key-here"`
2. Run basic example: `ruby simple_example.rb`  
3. Run vector store example: `ruby vector_store_example.rb`
4. Run web search example: `ruby web_search_example.rb`
5. Run markdown example: `ruby markdown_example.rb`
6. Run legal workflow example: `ruby legal_review_workflow_example.rb`
7. Run cron example: `ruby cron_example.rb`

All examples demonstrate real OpenAI API integration with rdawn! 🚀 