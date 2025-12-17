# MineContext Core Workflows Analysis

## Overview

MineContext implements several complex workflows that orchestrate context capture, processing, consumption, and user interaction. This document describes the **5 core workflows** with detailed PlantUML sequence diagrams.

## Workflow 1: System Initialization and Startup

### Purpose
Initialize all system components in the correct order, establish dependencies, and prepare the system for operation.

### Key Steps
1. Load configuration from multiple sources
2. Initialize global services (Config, Storage, LLM Clients)
3. Register and initialize capture components
4. Set up processor pipeline
5. Initialize consumption generators
6. Start scheduled tasks
7. Launch web server (optional)

### Sequence Diagram

```plantuml
@startuml
title Workflow 1: System Initialization and Startup

actor User
participant "CLI Command" as CLI
participant "OpenContext" as OC
participant "ComponentInitializer" as CI
participant "GlobalConfig" as GC
participant "GlobalStorage" as GS
participant "GlobalEmbeddingClient" as GEC
participant "GlobalVLMClient" as GVC
participant "ContextCaptureManager" as CCM
participant "ScreenshotCapture" as SC
participant "VaultDocumentMonitor" as VDM
participant "ContextProcessorManager" as CPM
participant "DocumentProcessor" as DP
participant "ScreenshotProcessor" as SP
participant "ConsumptionManager" as CONM
participant "OpenContextServer" as OCS

User -> CLI: opencontext start --port 1733
note right of CLI: Entry point via CLI

CLI -> OC: initialize()
note over OC: Create OpenContext instance

OC -> GC: get_instance()
GC --> OC: GlobalConfig instance
note over GC: Load config from file/env

OC -> GS: get_instance()
GS --> OC: GlobalStorage instance
note over GS: Initialize SQLite + ChromaDB

OC -> GEC: get_instance()
GEC --> OC: GlobalEmbeddingClient instance
note over GEC: Setup embedding model client

OC -> GVC: get_instance()
GVC --> OC: GlobalVLMClient instance
note over GVC: Setup vision-language model client

OC -> CI: initialize_capture_components(CCM)
CI -> GC: get_config()
GC --> CI: capture configuration
CI -> CCM: register_component("screenshot", SC)
CI -> SC: initialize(config)
SC --> CI: true
CI -> CCM: register_component("vault_document_monitor", VDM)
CI -> VDM: initialize(config)
VDM --> CI: true
CCM --> CI: success
CI --> OC: capture components initialized

OC -> CI: initialize_processors(CPM, callback)
CI -> GC: get_config()
GC --> CI: processing configuration
CI -> CPM: register_processor("document", DP)
CI -> CPM: register_processor("screenshot", SP)
CI -> DP: initialize(config)
DP --> CI: true
CI -> SP: initialize(config)
SP --> CI: true
CPM --> CI: success
CI --> OC: processors initialized

OC -> CI: initialize_consumption_components()
CI -> CONM: __init__()
CI -> CONM: start_scheduled_tasks()
CONM --> CI: tasks started
CI --> OC: consumption manager ready

OC -> OCS: start(host="127.0.0.1", port=1733)
OCS --> OC: server started

OC -> CCM: start_all_components()
CCM -> SC: start()
SC --> CCM: true
CCM -> VDM: start()
VDM --> CCM: true
CCM --> OC: all capture components running

note over OC: System fully initialized
OC --> CLI: Initialization complete
CLI --> User: System running on port 1733

@enduml
```

### Configuration Loading Priority
1. **Command-line arguments** (highest priority)
2. **Configuration file** (`config/config.yaml`)
3. **Environment variables**
4. **Default values** (lowest priority)

### Component Dependencies
```
GlobalConfig → GlobalStorage → LLM Clients → Capture Components → Processors → Consumption → Server
```

## Workflow 2: Screenshot Capture and Processing

### Purpose
Periodically capture screenshots, deduplicate them, extract semantic information, and store enriched context.

### Key Steps
1. Timer triggers screenshot capture
2. Capture screen image using MSS library
3. Calculate perceptual hash for deduplication
4. Save image to disk (optional)
5. Create RawContextProperties
6. Queue for processing
7. Background processing of screenshot
8. VLM analysis of image content
9. Entity and intent extraction
10. Generate embeddings
11. Store ProcessedContext

### Sequence Diagram

```plantuml
@startuml
title Workflow 2: Screenshot Capture and Processing

participant "ScheduledTimer" as Timer
participant "ScreenshotCapture" as SC
participant "MSS Library" as MSS
participant "ImageUtils" as IU
participant "RawContextProperties" as RCP
participant "ContextCaptureManager" as CCM
participant "CaptureCallback" as CB
participant "ScreenshotProcessor" as SP
participant "InputQueue" as Queue
participant "ProcessingThread" as Thread
participant "GlobalVLMClient" as GVC
participant "GlobalEmbeddingClient" as GEC
participant "EntityProcessor" as EP
participant "ProcessedContext" as PC
participant "GlobalStorage" as GS
participant "SQLiteBackend" as SQLite
participant "ChromaDBBackend" as ChromaDB

Timer -> SC: _capture_impl() every N seconds
note over SC: Capture interval configurable (default: 5s)

SC -> MSS: grab()
MSS --> SC: screenshot image bytes

SC -> IU: calculate_phash(image_bytes)
IU --> SC: perceptual hash value

alt Is Duplicate? (hash similarity > threshold)
    SC -> SC: _is_duplicate() returns true
    SC -> SC: skip processing, delete duplicate
else Not Duplicate
    SC -> SC: _is_duplicate() returns false
    SC -> RCP: __init__(source=SCREENSHOT,\nformat=IMAGE,\npath=filepath,\nmetadata)
    RCP --> SC: RawContextProperties instance

    SC -> CCM: _on_component_capture([RCP])
    CCM -> CB: callback([RCP])
    note over CB: OpenContext._handle_captured_context

    CB -> SP: process(RCP)
    SP -> Queue: put(RCP)
    note over SP: Background queue processing

    Queue -> Thread: _run_processing_loop()
    Thread -> SP: _process_batch([RCP])

    SP -> GVC: analyze_image(image_bytes, prompt)
    note over GVC: Vision-Language Model analysis
    GVC --> SP: JSON with title, summary, keywords, entities

    SP -> EP: validate_and_clean_entities(entities)
    EP --> SP: cleaned entities list

    SP -> GEC: generate_embedding(text_content)
    GEC --> SP: vector embedding

    SP -> PC: __init__(properties, extracted_data, vectorize, metadata)
    PC --> SP: ProcessedContext instance

    SP -> GS: save_context(PC)
    GS -> SQLite: save_context(PC)
    SQLite --> GS: success
    GS -> ChromaDB: save_context(PC)
    ChromaDB --> GS: success
    GS --> SP: context saved

    Thread --> Queue: processing complete
end

@enduml
```

### Real-time Deduplication Process
1. **Perceptual Hash Calculation**: Generate pHash of new screenshot
2. **Similarity Comparison**: Compare with recent screenshot cache
3. **Threshold Check**: If similarity > 95%, skip processing
4. **Cache Management**: Maintain LRU cache of recent screenshots
5. **File Cleanup**: Delete duplicate image files (if enabled)

### VLM Analysis Pipeline
```
Image → Base64 Encoding → Vision Prompt → Doubao VLM → JSON Parsing → ExtractedData
```

## Workflow 3: Context Consumption and Content Generation

### Purpose
Generate valuable insights from collected contexts through scheduled AI-driven analysis.

### Key Steps (Smart Todo Generation Example)
1. ConsumptionManager timer triggers task
2. Retrieve relevant contexts from storage
3. Analyze activity patterns and intents
4. Generate prioritized todo items
5. Validate and clean generated content
6. Store todos in database
7. Update frontend via websocket/push

### Sequence Diagram

```plantuml
@startuml
title Workflow 3: Smart Todo Generation Workflow

participant "ConsumptionManager" as CONM
participant "TodoTimer" as Timer
participant "SmartTodoManager" as STM
participant "GlobalStorage" as GS
participant "ContextQuery" as CQ
participant "LLM Client" as LLM
participant "PromptManager" as PM
participant "JSON Parser" as JP
participant "TodoTask" as TT
participant "DatabaseService" as DB
participant "WebSocket Server" as WS
participant "Frontend UI" as UI

Timer -> CONM: _start_todos_timer()
CONM -> Timer: threading.Timer(interval, generate_todos)
note over CONM: Default interval: 30 minutes

Timer -> CONM: generate_todos()
CONM -> STM: generate_todo_tasks(start_time, end_time)

STM -> GS: search_contexts(filters={"context_type": "INTENT_CONTEXT"})
GS --> STM: List[ProcessedContext]

STM -> GS: get_recent_activities(start_time, end_time)
GS --> STM: activity contexts

STM -> PM: get_prompt("todo_generation")
PM --> STM: prompt template

STM -> LLM: generate(prompt=formatted_prompt,\ncontexts=contexts,\nactivities=activities)
note over LLM: Generate structured todo list\nusing JSON schema

LLM --> STM: JSON response string

STM -> JP: parse_json_from_response(json_string)
JP --> STM: parsed todo list

loop for each todo item
    STM -> TT: TodoTask(**item_data)
    TT --> STM: TodoTask instance

    STM -> DB: insert_todo(\ncontent=description,\nurgency=priority,\ndeadline=due_date,\ncategory=category)
    DB --> STM: todo_id

    STM -> GS: link_contexts_to_todo(todo_id, context_ids)
    GS --> STM: success
end

STM --> CONM: todos generated

CONM -> WS: broadcast("todos_updated", todo_ids)
WS -> UI: send_notification("New todos generated")
UI -> UI: refresh_todo_list()

@enduml
```

### Content Generation Types
1. **Smart Todos**: Extract actionable items from intents (30 min interval)
2. **Smart Tips**: Generate contextual suggestions (1 hour interval)
3. **Activity Reports**: Daily summaries (configurable time)
4. **Real-time Activities**: Continuous activity monitoring (15 min interval)

### Prompt Engineering Flow
```
Context Data → Prompt Template → LLM Generation → JSON Parsing → Content Validation → Storage
```

## Workflow 4: AI Chat and Query Processing

### Purpose
Handle user queries intelligently by retrieving relevant contexts and generating contextual responses.

### Key Steps
1. User sends chat query via API/UI
2. Context Agent processes query
3. Intent analysis and classification
4. Context retrieval based on intent
5. LLM generation with retrieved contexts
6. Streaming response delivery
7. Workflow state management

### Sequence Diagram

```plantuml
@startuml
title Workflow 4: AI Chat and Query Processing

actor User
participant "Frontend UI" as UI
participant "Chat API" as API
participant "ContextAgent" as CA
participant "IntentAnalyzer" as IA
participant "ContextRetriever" as CR
participant "GlobalStorage" as GS
participant "LLM Client" as LLM
participant "StreamHandler" as SH
participant "WorkflowState" as WS

User -> UI: Type query "What meetings do I have today?"
UI -> API: POST /api/agent/chat\n{query, session_id, user_id}

API -> CA: process(query, session_id, user_id)

CA -> IA: analyze_intent(query)
IA --> CA: intent_type = "MEETING_QUERY", parameters={date: today}

CA -> CR: retrieve_contexts(intent_type, parameters)
CR -> GS: search_contexts(\nquery="meeting",\nfilters={"context_type": "ACTIVITY_CONTEXT"})
GS --> CR: List[ProcessedContext]
CR -> GS: vector_search(query_embedding, limit=10)
GS --> CR: similar contexts
CR --> CA: ranked contexts

CA -> LLM: generate_stream(\nprompt=chat_prompt,\ncontexts=contexts,\nquery=query)

LLM -> SH: stream_chunk("You have 3 meetings today:")
SH -> API: yield chunk
API -> UI: SSE data: "You have 3 meetings today:"

LLM -> SH: stream_chunk("1. Team sync at 10 AM...")
SH -> API: yield chunk
API -> UI: SSE data: "1. Team sync at 10 AM..."

LLM -> SH: stream_chunk("2. Product review at 2 PM...")
SH -> API: yield chunk
API -> UI: SSE data: "2. Product review at 2 PM..."

LLM -> SH: stream_chunk("3. Client call at 4 PM...")
SH -> API: yield chunk
API -> UI: SSE data: "3. Client call at 4 PM..."

LLM -> SH: stream_complete()
SH -> API: complete
API -> UI: [DONE]

CA -> WS: update_state(session_id, stage="COMPLETED", response_summary)
WS --> CA: state saved

UI -> User: Display complete response

@enduml
```

### Context Agent Workflow Stages
1. **Intent Analysis**: Classify query type and extract parameters
2. **Context Retrieval**: Fetch relevant contexts using vector + keyword search
3. **Execution Planning**: Determine tools/actions needed
4. **Response Generation**: LLM generation with retrieved contexts
5. **Reflection**: Evaluate response quality and update knowledge

### Hybrid Search Strategy
```
Query → Vector Embedding → Vector Search (ChromaDB)\n+ Keyword Filtering (SQLite) → Reranking → Top-K Contexts
```

## Workflow 5: Scheduled Tasks and Automation

### Purpose
Automatically generate content at configurable intervals without user intervention.

### Key Steps
1. ConsumptionManager initializes scheduled tasks
2. Separate timers for each task type
3. Check if generation conditions are met
4. Execute generation with appropriate time windows
5. Handle failures with retry logic
6. Update configuration dynamically

### Sequence Diagram

```plantuml
@startuml
title Workflow 5: Scheduled Tasks Automation

participant "ConsumptionManager" as CONM
participant "ConfigLoader" as CL
participant "ActivityTimer" as ATimer
participant "TipsTimer" as TTimer
participant "TodoTimer" as ToTimer
participant "ReportTimer" as RTimer
participant "RealtimeActivityMonitor" as RAM
participant "SmartTipGenerator" as STG
participant "SmartTodoManager" as STM
participant "ReportGenerator" as RG
participant "GlobalStorage" as GS
participant "LLM Client" as LLM
participant "ErrorHandler" as EH
participant "Configuration API" as CAPI

CL -> CONM: load_config_from_file("config/config.yaml")
CONM -> CL: parse_config()
CL --> CONM: task_config = {\n  activity: {enabled: true, interval: 900},\n  tips: {enabled: true, interval: 3600},\n  todos: {enabled: true, interval: 1800},\n  report: {enabled: true, time: "08:00"}\n}

CONM -> ATimer: threading.Timer(900, generate_activity)
ATimer --> CONM: timer started
CONM -> TTimer: threading.Timer(3600, generate_tips)
TTimer --> CONM: timer started
CONM -> ToTimer: threading.Timer(1800, generate_todos)
ToTimer --> CONM: timer started
CONM -> RTimer: _calculate_seconds_until_daily_time("08:00")
RTimer --> CONM: seconds_until_report
CONM -> RTimer: threading.Timer(seconds, generate_report)
RTimer --> CONM: timer started

' Activity Generation
ATimer -> CONM: generate_activity()
CONM -> RAM: generate_realtime_activity_summary(start_time, end_time)
RAM -> GS: get_activities(last_interval)
GS --> RAM: recent activities
RAM -> LLM: summarize_activities(activities)
LLM --> RAM: summary text
RAM -> GS: save_activity_summary(summary)
GS --> RAM: saved
RAM --> CONM: activity generated
CONM -> ATimer: schedule_next_check(activity)

' Tips Generation
TTimer -> CONM: generate_tips()
CONM -> STG: generate_smart_tip(start_time, end_time)
STG -> GS: get_contexts_for_tips(time_window)
GS --> STG: relevant contexts
STG -> LLM: generate_tips_from_contexts(contexts)
LLM --> STG: list of tips
STG -> GS: save_tips(tips)
GS --> STG: saved
STG --> CONM: tips generated
CONM -> TTimer: schedule_next_check(tips)

' Todo Generation
ToTimer -> CONM: generate_todos()
CONM -> STM: generate_todo_tasks(start_time, end_time)
STM -> GS: get_intent_contexts(time_window)
GS --> STM: intent contexts
STM -> LLM: extract_todos_from_intents(intents)
LLM --> STM: todo list
STM -> GS: save_todos(todos)
GS --> STM: saved
STM --> CONM: todos generated
CONM -> ToTimer: schedule_next_check(todos)

' Daily Report Generation
RTimer -> CONM: generate_report()
CONM -> RG: generate_report(start_time=midnight, end_time=now)
RG -> GS: get_daily_metrics(date)
GS --> RG: metrics data
RG -> LLM: generate_daily_report(metrics)
LLM --> RG: report markdown
RG -> GS: save_report(report)
GS --> RG: saved
RG --> CONM: report generated
CONM -> RTimer: schedule_next_check(report)

' Dynamic Configuration Update
CAPI -> CONM: update_task_config(new_config)
CONM -> ATimer: cancel()
CONM -> ATimer: threading.Timer(new_interval, generate_activity)
ATimer --> CONM: timer restarted with new interval

@enduml
```

### Task Scheduling Details

| Task Type | Default Interval | Purpose | Retry Policy |
|-----------|------------------|---------|--------------|
| Activity | 15 minutes | Real-time activity summaries | 3 retries, exponential backoff |
| Smart Tips | 1 hour | Contextual suggestions | 2 retries, linear backoff |
| Smart Todos | 30 minutes | Actionable task extraction | 3 retries, exponential backoff |
| Daily Report | 24 hours (08:00) | Comprehensive daily summary | Next day retry |

### Failure Handling Strategies
1. **Transient Failures**: Retry with exponential backoff
2. **LLM API Failures**: Fallback to simpler generation
3. **Storage Failures**: Cache and retry later
4. **Configuration Errors**: Use defaults and log warning

## Workflow Integration Points

### Cross-Workflow Dependencies

```
Initialization → Capture → Processing → Storage → Consumption → Chat
      ↓              ↓          ↓          ↓          ↓         ↓
   Config       Screenshot  Deduplication  Vector   Scheduled  Context
   Loading      Timer       & Analysis     Search   Tasks      Retrieval
```

### Data Flow Between Workflows

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CAPTURE       │    │   PROCESSING    │    │   CONSUMPTION   │
│   Workflow 2    │───▶│   Workflow 2    │───▶│   Workflow 3    │
│   (Raw Data)    │    │   (Enriched)    │    │   (Insights)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                                 ▼
                         ┌─────────────────┐
                         │      CHAT       │
                         │   Workflow 4    │
                         │   (Q/A)         │
                         └─────────────────┘
                                 │
                                 ▼
                         ┌─────────────────┐
                         │    SCHEDULED    │
                         │   Workflow 5    │
                         │   (Automation)  │
                         └─────────────────┘
```

### Critical Path Analysis

**Primary Path** (User activity to insight):
```
Screenshot → Deduplication → VLM Analysis → Embedding → Storage → Scheduled Task → Todo Generation → UI Notification
```

**Query Path** (User question to answer):
```
Chat Query → Intent Analysis → Context Retrieval → LLM Generation → Streaming Response → UI Display
```

### Performance Optimization Points

1. **Capture Workflow**:
   - Perceptual hash caching for faster deduplication
   - Batch processing of screenshots
   - Async file I/O operations

2. **Processing Workflow**:
   - Background thread pooling
   - Batch embedding generation
   - Parallel VLM analysis

3. **Consumption Workflow**:
   - Configurable intervals per task type
   - Incremental context retrieval
   - Cached prompt templates

4. **Chat Workflow**:
   - Vector search with caching
   - Streaming response optimization
   - Session state management

5. **Scheduled Tasks**:
   - Dynamic interval adjustment
   - Failure recovery mechanisms
   - Resource usage monitoring

### Monitoring and Observability

Each workflow includes:
- **Timing metrics** for performance analysis
- **Error tracking** with contextual information
- **Resource usage** monitoring
- **Success/failure rates** for quality assessment
- **Configuration drift** detection

### Configuration Management

Workflows respect configuration hierarchy:
1. **Runtime overrides** (API calls)
2. **Configuration file** (`config/config.yaml`)
3. **Environment variables**
4. **Default values**

Example configuration affecting workflows:
```yaml
# Capture workflow
capture:
  screenshot:
    enabled: true
    capture_interval: 5  # seconds
    dedup_enabled: true
    similarity_threshold: 95

# Processing workflow
processing:
  screenshot_processor:
    batch_size: 10
    batch_timeout: 20  # seconds
    max_raw_properties: 5

# Consumption workflow
content_generation:
  activity:
    enabled: true
    interval: 900  # 15 minutes
  tips:
    enabled: true
    interval: 3600 # 1 hour
  todos:
    enabled: true
    interval: 1800 # 30 minutes
  report:
    enabled: true
    time: "08:00"
```

## Conclusion

The MineContext workflow architecture demonstrates sophisticated orchestration of AI-powered context management:

1. **Initialization Workflow**: Establishes component dependencies and global services
2. **Capture Workflow**: Real-time screenshot monitoring with intelligent deduplication
3. **Processing Workflow**: Multimodal analysis and semantic enrichment
4. **Consumption Workflow**: Scheduled generation of valuable insights
5. **Chat Workflow**: Context-aware intelligent conversation
6. **Scheduled Tasks**: Configurable automation with robust error handling

These workflows interact through well-defined interfaces and data structures, ensuring system reliability while maintaining flexibility for future extensions. The local-first design prioritizes user privacy while leveraging AI capabilities for proactive context management.