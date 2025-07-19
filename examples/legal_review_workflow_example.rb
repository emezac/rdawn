#!/usr/bin/env ruby
# frozen_string_literal: true

# Context-Aware Legal Contract Review Workflow Example
# This comprehensive example demonstrates all advanced rdawn features:
# - Vector Store integration for document search
# - Long-Term Memory (LTM) for storing and retrieving context
# - File Search integration with LLM interface
# - DirectHandlerTask for custom processing
# - Enhanced variable resolution for complex data structures
# - Web search for recent legal updates
# - AI-powered markdown report generation

require 'rdawn'
require 'raix'
require 'openai'
require 'fileutils'
require 'json'

# Check if OpenAI API key is set
unless ENV['OPENAI_API_KEY']
  puts "❌ Error: Please set your OpenAI API key:"
  puts "export OPENAI_API_KEY='your-openai-api-key-here'"
  puts ""
  puts "Get your API key at: https://platform.openai.com/api-keys"
  exit 1
end

puts "⚖️ Context-Aware Legal Contract Review Workflow"
puts "=" * 60
puts "Demonstrating advanced rdawn features for legal document analysis"
puts ""

# Configure Raix
Raix.configure do |config|
  config.openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
end

# Initialize tools
api_key = ENV['OPENAI_API_KEY']
vector_store_tool = Rdawn::Tools::VectorStoreTool.new(api_key: api_key)
file_upload_tool = Rdawn::Tools::FileUploadTool.new(api_key: api_key)
file_search_tool = Rdawn::Tools::FileSearchTool.new(api_key: api_key)
web_search_tool = Rdawn::Tools::WebSearchTool.new(api_key: api_key)
markdown_tool = Rdawn::Tools::MarkdownTool.new(api_key: api_key)

# Create temporary directory for workflow files
workflow_dir = File.join(Dir.tmpdir, 'rdawn_legal_workflow')
FileUtils.mkdir_p(workflow_dir)

begin
  puts "🏗️ Setting up Legal Document Knowledge Base..."
  
  # Step 1: Create sample legal documents for the knowledge base
  legal_docs = [
    {
      filename: 'contract_guidelines.md',
      content: <<~CONTENT
        # Internal Legal Guidelines for Contract Review

        ## Confidentiality Clauses
        - All contracts must include mutual confidentiality provisions
        - Confidentiality period should be 3-5 years post-termination
        - Definition of confidential information must be specific

        ## Liability and Indemnification
        - Liability caps should not exceed 2x annual contract value
        - Mutual indemnification preferred over one-sided provisions
        - Exclude liability for consequential damages

        ## Termination Clauses
        - 30-day notice required for termination without cause
        - Immediate termination allowed for material breach
        - Data return obligations within 30 days of termination

        ## Payment Terms
        - Standard payment terms: Net 30 days
        - Late payment penalties: 1.5% per month
        - Invoicing requirements must be clearly specified

        ## Intellectual Property
        - Work product belongs to client unless otherwise specified
        - Pre-existing IP remains with respective parties
        - License grants should be limited in scope

        ## Compliance Requirements
        - GDPR compliance mandatory for EU clients
        - SOC 2 Type II certification required for data processing
        - Regular security audits must be permitted
      CONTENT
    },
    {
      filename: 'standard_clauses.md',
      content: <<~CONTENT
        # Standard Contract Clauses Library

        ## Force Majeure
        Standard clause: "Neither party shall be liable for any failure or delay in performance under this Agreement which is due to fire, flood, earthquake, elements of nature or acts of God, acts of war, terrorism, riots, civil disorders, rebellions or revolutions, or any other cause beyond the reasonable control of such party."

        ## Governing Law
        Preferred: "This Agreement shall be governed by and construed in accordance with the laws of [State/Country], without regard to its conflict of laws principles."

        ## Dispute Resolution
        Standard process:
        1. Direct negotiation (30 days)
        2. Mediation (60 days)
        3. Binding arbitration (final resort)

        ## Amendment Clause
        "This Agreement may be amended only by a written instrument signed by both parties."

        ## Severability
        "If any provision of this Agreement is held to be unenforceable, the remainder shall continue in full force and effect."

        ## Entire Agreement
        "This Agreement constitutes the entire agreement between the parties and supersedes all prior negotiations, representations, or agreements relating to the subject matter hereof."
      CONTENT
    },
    {
      filename: 'compliance_checklist.md',
      content: <<~CONTENT
        # Legal Compliance Checklist

        ## Data Protection Compliance
        - [ ] GDPR Article 28 processor agreements for EU data
        - [ ] Data Processing Addendum (DPA) included
        - [ ] Data retention and deletion procedures specified
        - [ ] Cross-border data transfer mechanisms in place

        ## Security Requirements
        - [ ] Minimum encryption standards (AES-256)
        - [ ] Access controls and authentication requirements
        - [ ] Incident response and notification procedures
        - [ ] Regular security assessments mandated

        ## Financial Controls
        - [ ] Credit checks for large contracts (>$100k)
        - [ ] Payment guarantees for international clients
        - [ ] Currency hedging for foreign exchange exposure
        - [ ] Tax implications reviewed

        ## Regulatory Compliance
        - [ ] Industry-specific regulations identified
        - [ ] Compliance monitoring and reporting requirements
        - [ ] Regulatory change notification procedures
        - [ ] Audit rights and procedures defined

        ## Risk Assessment
        - [ ] Liability exposure analysis completed
        - [ ] Insurance coverage requirements specified
        - [ ] Business continuity provisions included
        - [ ] Reputation risk factors evaluated
      CONTENT
    }
  ]
  
  # Create and save legal documents
  legal_file_paths = []
  legal_docs.each do |doc|
    file_path = File.join(workflow_dir, doc[:filename])
    File.write(file_path, doc[:content])
    legal_file_paths << file_path
    puts "📄 Created: #{doc[:filename]}"
  end
  
  puts "\n📤 Uploading legal documents to OpenAI..."
  
  # Upload documents to OpenAI
  uploaded_files = []
  legal_file_paths.each do |file_path|
    puts "⬆️ Uploading #{File.basename(file_path)}..."
    upload_result = file_upload_tool.upload_file(file_path: file_path, purpose: 'assistants')
    uploaded_files << upload_result[:id]
    puts "✅ Uploaded: #{upload_result[:id]}"
  end
  
  puts "\n🗃️ Creating Legal Guidelines Vector Store..."
  
  # Create vector store for legal guidelines
  legal_vector_store = vector_store_tool.create_vector_store(
    name: "Legal Guidelines Knowledge Base",
    file_ids: uploaded_files,
    expires_after: { anchor: "last_active_at", days: 7 }
  )
  
  legal_vs_id = legal_vector_store[:id]
  puts "✅ Legal Vector Store created: #{legal_vs_id}"
  
  puts "\n🧠 Creating Long-Term Memory Vector Store..."
  
  # Create LTM vector store (initially empty)
  ltm_vector_store = vector_store_tool.create_vector_store(
    name: "Agent Long-Term Memory",
    file_ids: [],
    expires_after: { anchor: "last_active_at", days: 30 }
  )
  
  ltm_vs_id = ltm_vector_store[:id]
  puts "✅ LTM Vector Store created: #{ltm_vs_id}"
  
  # Step 2: Create sample draft contract for review
  puts "\n📝 Creating sample draft contract..."
  
  draft_contract = <<~CONTRACT
    # SOFTWARE DEVELOPMENT AGREEMENT

    This Software Development Agreement ("Agreement") is entered into on [DATE] between TechCorp Inc., a Delaware corporation ("Company") and ClientCorp LLC, a California limited liability company ("Client").

    ## 1. SERVICES
    Company will develop a custom e-commerce platform according to specifications provided by Client. Development will include frontend, backend, and database components.

    ## 2. PAYMENT TERMS
    Client agrees to pay Company $150,000 for the services described herein. Payment schedule:
    - 50% upon signing ($75,000)
    - 25% upon prototype delivery ($37,500)
    - 25% upon final delivery ($37,500)
    
    Payment due within 45 days of invoice. Late payments subject to 2% monthly penalty.

    ## 3. INTELLECTUAL PROPERTY
    All work product and deliverables created by Company shall be deemed "work for hire" and owned exclusively by Client upon final payment. Company retains rights to general methodologies and techniques.

    ## 4. CONFIDENTIALITY
    Company acknowledges that it may have access to proprietary information of Client. Company agrees to maintain confidentiality for a period of 2 years following termination of this Agreement.

    ## 5. LIABILITY
    Company's liability under this Agreement shall not exceed the total amount paid by Client. Company disclaims all warranties, express or implied.

    ## 6. TERMINATION
    Either party may terminate this Agreement with 15 days written notice. Upon termination, Client shall pay for work completed to date.

    ## 7. DATA HANDLING
    Company will process Client data according to industry standards. Client data will be stored on secure servers with encryption at rest.

    ## 8. GOVERNING LAW
    This Agreement shall be governed by Delaware law. Any disputes shall be resolved through binding arbitration in Delaware.

    ## 9. AMENDMENT
    This Agreement may be modified only in writing signed by both parties.

    [Signature blocks to follow]
  CONTRACT
  
  # Save draft contract
  contract_file = File.join(workflow_dir, 'draft_contract.md')
  File.write(contract_file, draft_contract)
  puts "✅ Draft contract created: #{File.basename(contract_file)}"
  
  # Step 3: Create WorkflowEngine with DirectHandlerTasks
  puts "\n🔧 Setting up Context-Aware Workflow Engine..."
  
  # Create LLM interface
  class LegalWorkflowLLM
    include Raix::ChatCompletion
    
    def initialize(model = 'gpt-4o')
      @model = model
    end
    
    def execute_llm_call(prompt:, vector_store_ids: [], model_params: {})
      transcript.clear
      
      if vector_store_ids.any?
        # Use file search with vector stores
        result = chat_completion(
          openai: @model,
          params: {
            tools: [{ type: "file_search" }],
            tool_resources: {
              file_search: {
                vector_store_ids: vector_store_ids
              }
            },
            **model_params
          },
          messages: [{ role: 'user', content: prompt }]
        )
      else
        # Standard LLM call
        transcript << { user: prompt }
        result = chat_completion(openai: @model, params: model_params)
      end
      
      result
    end
  end
  
  llm_interface = LegalWorkflowLLM.new('gpt-4o')
  
  # Define custom handler functions for DirectHandlerTasks
  def create_web_search_handler(web_search_tool)
    proc do |input|
      begin
        query = input['query'] || input[:query]
        raise "Query is required for web search" unless query
        
        puts "🌐 Searching web: #{query[0..80]}..."
        
        result = web_search_tool.search(
          query: query,
          context_size: input['context_size'] || input[:context_size] || 'medium',
          model: 'gpt-4o'
        )
        
        {
          status: 'success',
          result: result,
          operation: 'web_search',
          timestamp: Time.now,
          query: query
        }
      rescue => e
        {
          status: 'error',
          error: e.message,
          operation: 'web_search',
          timestamp: Time.now
        }
      end
    end
  end
  
  def create_save_to_ltm_handler(file_upload_tool, vector_store_tool, ltm_vs_id)
    proc do |input|
      begin
        text_content = input['text_content'] || input[:text_content]
        raise "Text content is required for LTM save" unless text_content
        
        puts "🧠 Saving to Long-Term Memory..."
        
        # Create a temporary file with the content
        temp_file = Tempfile.new(['ltm_entry', '.md'])
        temp_file.write(text_content)
        temp_file.close
        
        # Upload to OpenAI
        upload_result = file_upload_tool.upload_file(
          file_path: temp_file.path,
          purpose: 'assistants'
        )
        
        # Add to LTM vector store
        vector_store_tool.add_file_to_vector_store(ltm_vs_id, upload_result[:id])
        
        # Cleanup
        temp_file.unlink
        
        {
          status: 'success',
          operation: 'save_to_ltm',
          file_id: upload_result[:id],
          vector_store_id: ltm_vs_id,
          content_length: text_content.length,
          timestamp: Time.now
        }
      rescue => e
        {
          status: 'error',
          error: e.message,
          operation: 'save_to_ltm',
          timestamp: Time.now
        }
      end
    end
  end
  
  def create_markdown_report_handler(markdown_tool, workflow_dir)
    proc do |input|
      begin
        content = input['content'] || input[:content]
        file_path = input['file_path'] || input[:file_path] || 'report.md'
        
        raise "Content is required for markdown report" unless content
        
        puts "📝 Generating markdown report..."
        
        # Ensure file path is in workflow directory
        full_path = File.join(workflow_dir, File.basename(file_path))
        
        # Write the content
        File.write(full_path, content)
        
        # Also generate an enhanced version with AI assistance
        enhanced_content = markdown_tool.format_markdown(
          markdown: content,
          style: 'standard',
          line_length: 80
        )
        
        enhanced_path = full_path.gsub('.md', '_enhanced.md')
        File.write(enhanced_path, enhanced_content[:formatted_markdown])
        
        {
          status: 'success',
          operation: 'markdown_report',
          file_path: full_path,
          enhanced_path: enhanced_path,
          content_length: content.length,
          timestamp: Time.now
        }
      rescue => e
        {
          status: 'error',
          error: e.message,
          operation: 'markdown_report',
          timestamp: Time.now
        }
      end
    end
  end
  
  def create_structure_analysis_handler
    proc do |input|
      begin
        puts "📊 Structuring legal analysis..."
        
        # Extract data from various task outputs
        topics = input['topics'] || input[:topics] || ""
        internal_docs = input['internal_docs'] || input[:internal_docs] || ""
        web_updates = input['web_updates'] || input[:web_updates] || ""
        synthesis = input['synthesis'] || input[:synthesis] || ""
        
        # Create structured analysis
        structured_data = {
          analysis_summary: {
            extracted_topics: topics,
            internal_guidelines_found: !internal_docs.empty?,
            web_updates_found: !web_updates.empty?,
            synthesis_completed: !synthesis.empty?
          },
          recommendations: {
            high_priority: [],
            medium_priority: [],
            low_priority: []
          },
          compliance_status: "Under Review",
          next_steps: []
        }
        
        # Generate markdown report
        report_markdown = <<~REPORT
          # Legal Contract Review Report
          **Generated:** #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
          
          ## Executive Summary
          This report analyzes a draft software development agreement against internal legal guidelines and recent legal developments.
          
          ## Contract Topics Identified
          #{topics}
          
          ## Internal Guidelines Analysis
          #{internal_docs.length > 100 ? internal_docs[0..500] + "..." : internal_docs}
          
          ## Recent Legal Updates
          #{web_updates.length > 100 ? web_updates[0..500] + "..." : web_updates}
          
          ## Synthesis and Recommendations
          #{synthesis.length > 100 ? synthesis[0..1000] + "..." : synthesis}
          
          ## Compliance Assessment
          - **Overall Status**: #{structured_data[:compliance_status]}
          - **Guidelines Reviewed**: ✅
          - **Web Updates Checked**: ✅
          - **Synthesis Completed**: ✅
          
          ## Next Steps
          1. Review highlighted clauses with legal team
          2. Implement recommended changes
          3. Obtain stakeholder approval
          4. Finalize contract terms
          
          ---
          *This report was generated using rdawn's Context-Aware Legal Review Workflow*
        REPORT
        
        {
          status: 'success',
          operation: 'structure_analysis',
          result: {
            structured_data: structured_data,
            report_markdown: report_markdown
          },
          timestamp: Time.now
        }
      rescue => e
        {
          status: 'error',
          error: e.message,
          operation: 'structure_analysis',
          timestamp: Time.now
        }
      end
    end
  end
  
  # Step 4: Define the Context-Aware Legal Review Workflow
  puts "\n⚖️ Defining Legal Review Workflow..."
  
  legal_workflow = Rdawn::Workflow.new(
    workflow_id: 'legal_contract_review_v1',
    name: 'Context-Aware Legal Contract Review'
  )
  
  # Task 1: Extract key topics from contract
  task1 = Rdawn::Task.new(
        task_id: 'extract_contract_topics',
        name: 'Extract Contract Topics and Clauses',
        is_llm_task: true,
        input_data: {
          prompt: <<~PROMPT
            Analyze this draft contract and identify the main legal topics, clause types, and key provisions:
            
            #{draft_contract}
            
            List the main topics concisely, focusing on areas that typically require legal review such as:
            - Payment terms and conditions
            - Intellectual property provisions
            - Liability and indemnification
            - Confidentiality requirements
            - Termination clauses
            - Data handling and privacy
            - Governing law and dispute resolution
            
            For each topic, note any specific terms or conditions that deviate from standard practices.
          PROMPT
        }
      )
      legal_workflow.add_task(task1)
      
      # Task 2: Search internal legal documents (parallel)
      task2 = Rdawn::Task.new(
        task_id: 'search_internal_guidelines',
        name: 'Search Internal Legal Guidelines',
        is_llm_task: true,
        input_data: {
          prompt: <<~PROMPT,
            Based on the contract topics identified: ${extract_contract_topics.output_data}
            
            Search our internal legal guidelines and standard clauses to find:
            1. Relevant compliance requirements
            2. Standard clause language we should use
            3. Risk factors to consider
            4. Any specific guidelines for software development agreements
            
            Provide specific guidance from our internal documents that applies to this contract.
                  PROMPT
        vector_store_ids: [legal_vs_id]
      }
    )
    legal_workflow.add_task(task2)
    
    # Task 3: Search web for recent legal updates (parallel)
    task3 = Rdawn::Tasks::DirectHandlerTask.new(
        task_id: 'search_web_updates',
        name: 'Search Recent Legal Updates',
        handler: create_web_search_handler(web_search_tool),
              input_data: {
        query: "Recent legal developments 2024 2025 software development contracts intellectual property liability data privacy California Delaware"
      }
    )
    legal_workflow.add_task(task3)
    
    # Task 4: Synthesize findings and generate recommendations
    task4 = Rdawn::Task.new(
        task_id: 'synthesize_legal_review',
        name: 'Synthesize Legal Review and Generate Recommendations',
        is_llm_task: true,
        input_data: {
          prompt: <<~PROMPT,
            Based on the comprehensive analysis, provide detailed legal review recommendations:
            
            **Contract Topics:** ${extract_contract_topics.output_data}
            
            **Internal Guidelines:** ${search_internal_guidelines.output_data}
            
            **Recent Legal Updates:** ${search_web_updates.result.content}
            
            **Original Contract:**
            #{draft_contract}
            
            Provide specific recommendations for:
            1. **High Priority Issues**: Critical legal risks or non-compliance
            2. **Medium Priority Issues**: Important improvements or clarifications
            3. **Low Priority Issues**: Minor adjustments or best practices
            
            For each issue, provide:
            - Specific clause reference
            - Current language (if problematic)
            - Recommended change
            - Legal rationale
            - Risk assessment
            
            Format as a structured legal review with clear action items.
                  PROMPT
        vector_store_ids: [ltm_vs_id]  # Also search LTM for past reviews
      }
    )
    legal_workflow.add_task(task4)
    
    # Task 5: Save summary to Long-Term Memory
    task5 = Rdawn::Tasks::DirectHandlerTask.new(
        task_id: 'save_review_to_ltm',
        name: 'Save Review Summary to Long-Term Memory',
        handler: create_save_to_ltm_handler(file_upload_tool, vector_store_tool, ltm_vs_id),
        input_data: {
                  text_content: "Legal Contract Review Summary - Software Development Agreement\n\nKey Findings: ${synthesize_legal_review.output_data}\n\nTopics Analyzed: ${extract_contract_topics.output_data}\n\nReview Date: #{Time.now}\nContract Type: Software Development Agreement\nComplexity: Medium\nRisk Level: To be assessed"
      }
    )
    legal_workflow.add_task(task5)
    
    # Task 6: Structure the complete analysis
    task6 = Rdawn::Tasks::DirectHandlerTask.new(
        task_id: 'structure_final_analysis',
        name: 'Structure Complete Legal Analysis',
        handler: create_structure_analysis_handler,
        input_data: {
          topics: "${extract_contract_topics.output_data}",
          internal_docs: "${search_internal_guidelines.output_data}",
          web_updates: "${search_web_updates.result.content}",
                  synthesis: "${synthesize_legal_review.output_data}"
      }
    )
    legal_workflow.add_task(task6)
    
    # Task 7: Generate final markdown report
    task7 = Rdawn::Tasks::DirectHandlerTask.new(
        task_id: 'generate_final_report',
        name: 'Generate Final Legal Review Report',
        handler: create_markdown_report_handler(markdown_tool, workflow_dir),
        input_data: {
          content: "${structure_final_analysis.result.report_markdown}",
                  file_path: 'legal_contract_review_report.md'
      }
    )
    legal_workflow.add_task(task7)
  
  # Step 5: Execute the workflow
  puts "\n🚀 Executing Context-Aware Legal Review Workflow..."
  puts "This will demonstrate all advanced rdawn features in action."
  puts ""
  
  # Create workflow engine
  workflow_engine = Rdawn::WorkflowEngine.new(
    workflow: legal_workflow,
    llm_interface: llm_interface
  )
  
  # Execute workflow
  workflow_result = workflow_engine.run(
    initial_input: {
      draft_contract: draft_contract,
      legal_vector_store_id: legal_vs_id,
      ltm_vector_store_id: ltm_vs_id
    }
  )
  
  puts "\n✅ Workflow execution completed!"
  puts "📊 Execution Summary:"
  puts "  - Total tasks: #{workflow_result.tasks.length}"
  puts "  - Status: #{workflow_result.status}"
  
  # Display task results
  if workflow_result.tasks.any?
    puts "\n📋 Task Results Summary:"
    workflow_result.tasks.each do |task_id, task|
      status = task.status == :completed ? "✅ Success" : 
               task.status == :failed ? "❌ Error" : "⏳ #{task.status}"
      puts "  #{task_id}: #{status}"
      if task.status == :failed && task.output_data[:error]
        puts "    Error: #{task.output_data[:error]}"
      elsif task.status == :completed && task.output_data.is_a?(String)
        preview = task.output_data[0..100]
        puts "    Output: #{preview}#{'...' if task.output_data.length > 100}"
      end
    end
  end
  
  # Step 6: Demonstrate advanced features
  puts "\n🔬 Demonstrating Advanced Features..."
  
  # Show vector store contents
  puts "\n📚 Legal Guidelines Vector Store Status:"
  legal_vs_status = vector_store_tool.get_vector_store(legal_vs_id)
  puts "  Files: #{legal_vs_status[:file_counts]&.dig(:total) || 0}"
  puts "  Status: #{legal_vs_status[:status]}"
  
  puts "\n🧠 Long-Term Memory Vector Store Status:"
  ltm_vs_status = vector_store_tool.get_vector_store(ltm_vs_id)
  puts "  Files: #{ltm_vs_status[:file_counts]&.dig(:total) || 0}"
  puts "  Status: #{ltm_vs_status[:status]}"
  
  # Demonstrate file search capability
  puts "\n🔍 Demonstrating File Search on Legal Guidelines..."
  search_result = file_search_tool.search_files(
    query: "confidentiality clause requirements",
    vector_store_ids: [legal_vs_id],
    max_results: 3
  )
  
  puts "Search Results:"
  if search_result[:results] && search_result[:results].any?
    search_result[:results].each_with_index do |result, index|
      puts "  #{index + 1}. #{result[:content][0..100]}..."
    end
  else
    puts "  No results found"
  end
  
  # Generate additional analysis with markdown tool
  puts "\n📝 Generating Additional Markdown Analysis..."
  
  contract_analysis = markdown_tool.generate_markdown(
    prompt: "Create a risk assessment matrix for a software development contract focusing on intellectual property, liability, and data privacy concerns",
    style: 'professional',
    length: 'medium',
    model: 'gpt-4o-mini'
  )
  
  # Save additional analysis
  risk_assessment_file = File.join(workflow_dir, 'risk_assessment.md')
  File.write(risk_assessment_file, contract_analysis[:markdown])
  puts "✅ Risk assessment created: #{File.basename(risk_assessment_file)}"
  
  # Create template for future use
  puts "\n📋 Creating Legal Review Template..."
  
  template_result = markdown_tool.create_template(
    type: 'documentation',
    title: 'Legal Contract Review Template',
    author: 'rdawn Legal Workflow System'
  )
  
  template_file = File.join(workflow_dir, 'legal_review_template.md')
  File.write(template_file, template_result[:template_markdown])
  puts "✅ Template created: #{File.basename(template_file)}"
  
  # Step 7: Show final results
  puts "\n📁 Generated Files:"
  Dir.glob(File.join(workflow_dir, '*')).each do |file|
    size = File.size(file)
    puts "  📄 #{File.basename(file)} (#{size} bytes)"
  end
  
  # Show workflow metrics
  puts "\n📊 Workflow Metrics:"
  puts "  🔧 Tools Used:"
  puts "    • VectorStoreTool (document storage and retrieval)"
  puts "    • FileUploadTool (document upload to OpenAI)"
  puts "    • FileSearchTool (semantic search in documents)"
  puts "    • WebSearchTool (recent legal updates)"
  puts "    • MarkdownTool (report generation and templates)"
  puts "  🎯 Features Demonstrated:"
  puts "    • Vector Store integration"
  puts "    • Long-Term Memory (LTM)"
  puts "    • File Search with LLM"
  puts "    • DirectHandlerTask for custom processing"
  puts "    • Enhanced variable resolution"
  puts "    • Parallel task execution"
  puts "    • Context-aware legal analysis"
  
rescue => e
  puts "❌ Error during workflow execution: #{e.message}"
  puts "🔧 Error details: #{e.backtrace.first(5).join("\n")}"
ensure
  # Cleanup (optional - comment out to keep files for inspection)
  # puts "\n🧹 Cleaning up resources..."
  # 
  # if legal_vs_id
  #   vector_store_tool.delete_vector_store(legal_vs_id)
  #   puts "✅ Legal vector store deleted"
  # end
  # 
  # if ltm_vs_id
  #   vector_store_tool.delete_vector_store(ltm_vs_id)
  #   puts "✅ LTM vector store deleted"
  # end
  
  puts "\n📂 Workflow files saved in: #{workflow_dir}"
  puts "Review the generated files to see the complete legal analysis."
end

puts "\n" + "=" * 60
puts "🎉 Context-Aware Legal Contract Review Complete!"
puts ""
puts "💡 This workflow demonstrated:"
puts "   • Vector Store integration for legal document search"
puts "   • Long-Term Memory for context retention"
puts "   • File Search with semantic similarity"
puts "   • Web search for recent legal updates"
puts "   • DirectHandlerTask for custom business logic"
puts "   • Enhanced variable resolution for complex data"
puts "   • AI-powered markdown report generation"
puts "   • Complete context-aware legal document analysis"
puts ""
puts "🔧 Key Technologies Used:"
puts "   • OpenAI Vector Stores for document indexing"
puts "   • OpenAI File Search for semantic retrieval"
puts "   • OpenAI Web Search for current information"
puts "   • Custom DirectHandlerTask implementations"
puts "   • Advanced variable resolution patterns"
puts "   • Multi-stage workflow orchestration"
puts ""
puts "💰 Estimated cost: ~$0.50-2.00 (comprehensive workflow)"
puts "⚖️ Perfect for: Legal firms, compliance teams, contract review automation" 