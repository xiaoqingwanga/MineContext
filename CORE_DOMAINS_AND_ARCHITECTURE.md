# MineContext Core Domains and Architecture

## Overview

MineContext is a proactive context-aware AI partner that captures, processes, and consumes digital context from multiple sources to generate intelligent insights, summaries, and action items. The system follows a modular, layered architecture with clear separation of concerns.

## Core Domains

Based on the codebase analysis, MineContext is organized into **8 core domains**:

1. **Context Capture Domain** - Data acquisition from multiple sources
2. **Context Processing Domain** - Transformation and enrichment of raw data
3. **Context Consumption Domain** - Generation of value from processed data
4. **Storage Domain** - Multi-backend data persistence
5. **LLM Integration Domain** - AI model orchestration and abstraction
6. **Management Domain** - System coordination and lifecycle management
7. **Server/API Domain** - Web interface and external communication
8. **Frontend Domain** - Desktop application interface

## Domain 1: Context Capture Domain

**Purpose**: Acquire raw context data from various sources (screenshots, documents, files, etc.)

### Key Responsibilities
- Monitor multiple context sources (screenshots, vaults, local files, web links)
- Provide uniform interface for all capture components
- Handle source-specific configurations and lifecycle
- Manage capture scheduling and frequency

### Core Classes

```plantuml
@startuml
package "Context Capture Domain" {
  interface ICaptureComponent {
    +initialize(config: Dict): bool
    +start(): bool
    +stop(graceful: bool): bool
    +capture(): List[RawContextProperties]
    +get_name(): str
    +get_description(): str
    +set_callback(callback): bool
  }

  class ContextCaptureManager {
    -_components: Dict[str, ICaptureComponent]
    -_running_components: Set[str]
    -_callback: Optional[callable]
    -_statistics: Dict[str, Any]

    +register_component(name, component): bool
    +unregister_component(name): bool
    +start_component(name): bool
    +stop_component(name, graceful): bool
    +start_all_components(): Dict[str, bool]
    +set_callback(callback): None
    +_on_component_capture(contexts): None
  }

  class ScreenshotCaptureComponent implements ICaptureComponent {
    -_interval: int
    -_enabled: bool
    -_monitor_thread: threading.Thread
    +capture(): List[RawContextProperties]
    +start(): bool
    +stop(graceful: bool): bool
  }

  class VaultDocumentMonitor implements ICaptureComponent {
    -_monitored_paths: List[str]
    -_file_types: List[FileType]
    +capture(): List[RawContextProperties]
  }

  class RawContextProperties {
    +content_format: ContentFormat
    +source: ContextSource
    +create_time: datetime
    +object_id: str
    +content_path: Optional[str]
    +content_text: Optional[str]
    +additional_info: Optional[Dict]
    +enable_merge: bool
  }

  enum ContentFormat {
    TEXT
    IMAGE
    FILE
  }

  enum ContextSource {
    SCREENSHOT
    VAULT
    LOCAL_FILE
    WEB_LINK
    INPUT
  }

  ContextCaptureManager "1" *-- "1..*" ICaptureComponent : manages
  ScreenshotCaptureComponent ..|> ICaptureComponent
  VaultDocumentMonitor ..|> ICaptureComponent
  ContentFormat <-- RawContextProperties
  ContextSource <-- RawContextProperties
}
@enduml
```

### Relationships
- `ContextCaptureManager` orchestrates multiple `ICaptureComponent` implementations
- Each capture component produces `RawContextProperties` instances
- Components are registered dynamically and managed via lifecycle methods
- Callback system allows decoupled data flow to processing layer

## Domain 2: Context Processing Domain

**Purpose**: Transform raw context data into structured, enriched, and vectorized form

### Key Responsibilities
- Extract semantic information from raw content
- Generate embeddings for similarity search
- Chunk large documents into manageable pieces
- Merge related contexts across sources
- Classify contexts into semantic types

### Core Classes

```plantuml
@startuml
@startuml
package "Context Processing Domain" {
  class ContextProcessorManager {
    -_processors: Dict[str, IProcessorComponent]
    -_running_processors: Set[str]
    -_storage: BaseStorage
    +register_processor(name, processor): bool
    +process(contexts: List[RawContextProperties]): List[ProcessedContext]
    +get_processor(name): Optional[IProcessorComponent]
    +_handle_processing_result(processed_contexts): None
  }

  interface IProcessorComponent {
    +process(input_data: Any) -> Any
    +get_name() -> str
    +initialize(config: Dict) -> bool
    +validate_config(config: Dict) -> bool
  }

  class ProcessorFactory {
    +create_processor(source_type: ContextSource): IProcessorComponent
    +get_available_processors(): List[str]
  }

  class DocumentProcessor implements IProcessorComponent {
    -_chunker: DocumentChunker
    -_entity_extractor: EntityExtractor
    +process(raw_properties: RawContextProperties): ProcessedContext
    +extract_entities(text: str): List[str]
    +generate_summary(text: str): str
  }

  class ScreenshotProcessor implements IProcessorComponent {
    -_vlm_client: VLMClient
    -_image_parser: ImageParser
    +process(raw_properties: RawContextProperties): ProcessedContext
    +extract_text_from_image(image_bytes): str
    +analyze_image_content(image_bytes): ExtractedData
  }

  class EntityProcessor implements IProcessorComponent {
    -_ner_model: NERModel
    -_entity_linking: EntityLinking
    +process(text: str): List[Entity]
    +link_entities(entities): Dict[str, List]
  }

  class DocumentChunker {
    +chunk_document(text: str, strategy: str): List[Chunk]
    +merge_chunks(chunks: List[Chunk], threshold: float): List[Chunk]
  }

  class ProcessedContext {
    +id: str
    +properties: ContextProperties
    +extracted_data: ExtractedData
    +vectorize: Vectorize
    +metadata: Optional[Dict[str, Any]]
    +get_llm_context_string(): str
    +get_vectorize_content(): str
  }

  class ExtractedData {
    +title: Optional[str]
    +summary: Optional[str]
    +keywords: List[str]
    +entities: List[str]
    +context_type: ContextType
    +confidence: int
    +importance: int
  }

  class ContextProperties {
    +raw_properties: list[RawContextProperties]
    +create_time: datetime
    +event_time: datetime
    +is_processed: bool
    +call_count: int
    +merge_count: int
    +duration_count: int
  }

  enum ContextType {
    ENTITY_CONTEXT
    ACTIVITY_CONTEXT
    INTENT_CONTEXT
    SEMANTIC_CONTEXT
    PROCEDURAL_CONTEXT
    STATE_CONTEXT
    KNOWLEDGE_CONTEXT
  }

  ContextProcessorManager "1" *-- "1..*" IProcessorComponent : manages
  DocumentProcessor ..|> IProcessorComponent
  ScreenshotProcessor ..|> IProcessorComponent
  EntityProcessor ..|> IProcessorComponent
  DocumentProcessor "1" *-- "1" DocumentChunker : uses
  ScreenshotProcessor "1" *-- "1" VLMClient : uses
  ProcessedContext "1" *-- "1" ContextProperties : contains
  ProcessedContext "1" *-- "1" ExtractedData : contains
  ExtractedData "1" *-- "1" ContextType : has
}
@enduml
```

### Context Classification Types
- **ENTITY_CONTEXT**: Profile information of entities (people, projects, organizations)
- **ACTIVITY_CONTEXT**: Behavioral activities and historical records
- **INTENT_CONTEXT**: Planning and goal information
- **SEMANTIC_CONTEXT**: Knowledge concepts and technical principles
- **PROCEDURAL_CONTEXT**: Operational workflows and task procedures
- **STATE_CONTEXT**: Status monitoring and progress information
- **KNOWLEDGE_CONTEXT**: File-based knowledge content

## Domain 3: Context Consumption Domain

**Purpose**: Generate value-added content from processed contexts through scheduled tasks and AI-driven analysis

### Key Responsibilities
- Generate smart tips based on user activity patterns
- Create to-do items from extracted intents and goals
- Produce daily/weekly activity reports
- Monitor real-time activities and generate summaries
- Schedule and manage automated content generation tasks

### Core Classes

```plantuml
@startuml
package "Context Consumption Domain" {
  class ConsumptionManager {
    -_scheduled_tasks_enabled: bool
    -_task_timers: Dict[str, threading.Timer]
    -_task_intervals: Dict[str, int]
    -_statistics: Dict[str, Any]

    +start_scheduled_tasks(config: Dict): None
    +stop_scheduled_tasks(): None
    +get_scheduled_tasks_status(): Dict[str, Any]
    +update_task_config(config: Dict): bool
    +_should_generate(task_type: str): bool
  }

  class SmartTipGenerator {
    -_llm_client: LLMClient
    -_context_retriever: ContextRetriever
    +generate_smart_tip(start_time: int, end_time: int): Optional[SmartTip]
    +_analyze_activity_patterns(contexts: List[ProcessedContext]): List[str]
    +_generate_tip_from_patterns(patterns: List[str]): str
  }

  class SmartTodoManager {
    -_context_storage: BaseStorage
    -_todo_storage: TodoStorage
    +generate_todo_tasks(start_time: int, end_time: int): List[TodoItem]
    +_extract_action_items(contexts: List[ProcessedContext]): List[str]
    +_prioritize_todos(todos: List[str]): List[TodoItem]
  }

  class ReportGenerator {
    -_template_engine: TemplateEngine
    -_data_aggregator: DataAggregator
    +generate_report(start_time: int, end_time: int): Report
    +_collect_daily_metrics(contexts: List[ProcessedContext]): Dict[str, Any]
    +_format_report_data(metrics: Dict[str, Any]): str
  }

  class RealtimeActivityMonitor {
    -_activity_buffer: List[ActivityEvent]
    -_window_size: int
    +generate_realtime_activity_summary(start_time: int, end_time: int): ActivitySummary
    +add_activity_event(event: ActivityEvent): None
    +_cluster_activities(events: List[ActivityEvent]): List[ActivityCluster]
  }

  class SmartTip {
    +id: str
    +content: str
    +context_ids: List[str]
    +generation_time: datetime
    +relevance_score: float
  }

  class TodoItem {
    +id: str
    +title: str
    +description: str
    +priority: int
    +due_date: Optional[datetime]
    +context_ids: List[str]
    +completed: bool
  }

  class Report {
    +id: str
    +report_type: str
    +period_start: datetime
    +period_end: datetime
    +content: str
    +metrics: Dict[str, Any]
  }

  ConsumptionManager "1" *-- "1" SmartTipGenerator : contains
  ConsumptionManager "1" *-- "1" SmartTodoManager : contains
  ConsumptionManager "1" *-- "1" ReportGenerator : contains
  ConsumptionManager "1" *-- "1" RealtimeActivityMonitor : contains
  SmartTipGenerator "1" *-- "1" LLMClient : uses
  ReportGenerator "1" *-- "1" TemplateEngine : uses
}
@enduml
```

### Scheduled Task Types
1. **Activity Generation**: Real-time activity summaries (default: every 15 minutes)
2. **Smart Tips**: Context-aware suggestions (default: every 1 hour)
3. **Todo Generation**: Actionable task extraction (default: every 30 minutes)
4. **Daily Reports**: Comprehensive daily summaries (configurable time)

## Domain 4: Storage Domain

**Purpose**: Provide unified, multi-backend storage with vector search capabilities

### Key Responsibilities
- Abstract storage backend differences (SQLite, ChromaDB, etc.)
- Manage vector embeddings for semantic search
- Handle CRUD operations for contexts, vaults, and generated content
- Support hybrid storage strategies
- Ensure data consistency and integrity

### Core Classes

```plantuml
@startuml
package "Storage Domain" {
  interface BaseStorage {
    +save_context(context: ProcessedContext): bool
    +get_context(context_id: str): Optional[ProcessedContext]
    +search_contexts(query: str, limit: int, filters: Dict): List[ProcessedContext]
    +update_context(context_id: str, updates: Dict): bool
    +delete_context(context_id: str, soft_delete: bool): bool
    +get_similar_contexts(embedding: List[float], limit: int): List[ProcessedContext]
  }

  class GlobalStorage {
    -_instance: Optional[GlobalStorage]
    -_storage_backend: BaseStorage
    +get_instance(): GlobalStorage
    +initialize(config: Dict): bool
    +get_storage(): BaseStorage
  }

  class UnifiedStorage implements BaseStorage {
    -_primary_backend: BaseStorage
    -_vector_backend: BaseStorage
    -_metadata_backend: BaseStorage
    +save_context(context: ProcessedContext): bool
    +search_contexts(query: str, limit: int, filters: Dict): List[ProcessedContext]
    +_route_by_context_type(context: ProcessedContext): BaseStorage
  }

  class SQLiteBackend implements BaseStorage {
    -_connection: sqlite3.Connection
    -_db_path: str
    +save_context(context: ProcessedContext): bool
    +get_context(context_id: str): Optional[ProcessedContext]
    +_create_tables(): bool
    +_migrate_schema(): bool
  }

  class ChromaDBBackend implements BaseStorage {
    -_client: chromadb.Client
    -_collection: chromadb.Collection
    +save_context(context: ProcessedContext): bool
    +search_contexts(query: str, limit: int, filters: Dict): List[ProcessedContext]
    +get_similar_contexts(embedding: List[float], limit: int): List[ProcessedContext]
  }

  class Vectorize {
    +content_format: ContentFormat
    +image_path: Optional[str]
    +text: Optional[str]
    +vector: Optional[List[float]]
    +get_vectorize_content(): str
  }

  GlobalStorage "1" *-- "1" BaseStorage : delegates to
  UnifiedStorage ..|> BaseStorage
  SQLiteBackend ..|> BaseStorage
  ChromaDBBackend ..|> BaseStorage
  UnifiedStorage "1" *-- "1..*" BaseStorage : composes
  ProcessedContext "1" *-- "1" Vectorize : contains
}
@enduml
```

### Storage Strategy
- **UnifiedStorage**: Routes data to appropriate backends based on context type
- **SQLiteBackend**: Structured data and metadata storage
- **ChromaDBBackend**: Vector embeddings and similarity search
- **Hybrid approach**: Combines multiple backends for optimal performance

## Domain 5: LLM Integration Domain

**Purpose**: Abstract AI model interactions and provide consistent interfaces for different providers

### Key Responsibilities
- Manage API keys and authentication for multiple providers
- Handle request/response with retry and error handling
- Support both text and vision-language models (VLM)
- Generate high-quality embeddings for vector search
- Provide model-agnostic interfaces

### Core Classes

```plantuml
@startuml
package "LLM Integration Domain" {
  class LLMClient {
    -_provider: str
    -_api_key: str
    -_model: str
    -_max_retries: int
    +generate(prompt: str, **kwargs): str
    +generate_stream(prompt: str, **kwargs): Generator[str, None, None]
    +_make_request(payload: Dict): Dict
    +_handle_error(response: Dict): None
  }

  class GlobalVLMClient {
    -_instance: Optional[GlobalVLMClient]
    -_vlm_client: VLMClient
    +get_instance(): GlobalVLMClient
    +analyze_image(image_bytes: bytes, prompt: str): str
    +describe_image(image_bytes: bytes): str
    +extract_text_from_image(image_bytes: bytes): str
  }

  class GlobalEmbeddingClient {
    -_instance: Optional[GlobalEmbeddingClient]
    -_embedding_client: EmbeddingClient
    +get_instance(): GlobalEmbeddingClient
    +generate_embedding(text: str): List[float]
    +generate_embeddings(texts: List[str]): List[List[float]]
    +get_embedding_dimension(): int
  }

  class VLMClient extends LLMClient {
    -_vision_model: str
    +analyze_image(image_bytes: bytes, prompt: str): str
    +_prepare_image_payload(image_bytes: bytes, prompt: str): Dict
  }

  class EmbeddingClient extends LLMClient {
    -_embedding_model: str
    +generate_embedding(text: str): List[float]
    +_prepare_embedding_payload(text: str): Dict
  }

  enum LLMProvider {
    DOUBAO
    OPENAI
    CUSTOM
  }

  GlobalVLMClient "1" *-- "1" VLMClient : contains
  GlobalEmbeddingClient "1" *-- "1" EmbeddingClient : contains
  VLMClient --|> LLMClient
  EmbeddingClient --|> LLMClient
  LLMClient "1" *-- "1" LLMProvider : uses
}
@enduml
```

### Supported Providers
1. **Doubao**: ByteDance's AI models (default recommendation)
2. **OpenAI**: GPT and embedding models
3. **Custom**: Any OpenAI-compatible API endpoint (including local models)

## Domain 6: Management Domain

**Purpose**: Coordinate system components, manage lifecycle, and provide centralized control

### Key Responsibilities
- Initialize and orchestrate all system components
- Manage component dependencies and initialization order
- Handle system-wide configuration
- Provide monitoring and statistics collection
- Coordinate graceful shutdown

### Core Classes

```plantuml
@startuml
package "Management Domain" {
  class OpenContext {
    -capture_manager: ContextCaptureManager
    -processor_manager: ContextProcessorManager
    -consumption_manager: ConsumptionManager
    -workflow_engine: Optional[WorkflowEngine]
    -completion_service: Optional[CompletionService]
    -web_server: Optional[threading.Thread]

    +initialize(): None
    +start(): bool
    +stop(graceful: bool): bool
    +get_status(): Dict[str, Any]
    +_handle_captured_context(contexts: List[RawContextProperties]): None
    +_handle_processed_context(contexts: List[ProcessedContext]): None
  }

  class ComponentInitializer {
    +initialize_capture_components(capture_manager: ContextCaptureManager): bool
    +initialize_processors(processor_manager: ContextProcessorManager, callback): bool
    +initialize_consumption_components(): ConsumptionManager
    +initialize_completion_service(): CompletionService
    +initialize_monitoring(): bool
  }

  class GlobalConfig {
    -_instance: Optional[GlobalConfig]
    -_config: Dict[str, Any]
    +get_instance(): GlobalConfig
    +load_config(config_path: str): bool
    +get_config() -> Dict[str, Any]
    +update_config(updates: Dict[str, Any]): bool
    +get_section(section: str) -> Dict[str, Any]
  }

  class EventManager {
    -_listeners: Dict[EventType, List[callable]]
    +register_listener(event_type: EventType, callback: callable): None
    +unregister_listener(event_type: EventType, callback: callable): None
    +trigger_event(event_type: EventType, data: Any): None
    +_notify_listeners(event_type: EventType, data: Any): None
  }

  enum EventType {
    CONTEXT_CAPTURED
    CONTEXT_PROCESSED
    CONSUMPTION_GENERATED
    ERROR_OCCURRED
    SYSTEM_SHUTDOWN
  }

  OpenContext "1" *-- "1" ContextCaptureManager : contains
  OpenContext "1" *-- "1" ContextProcessorManager : contains
  OpenContext "1" *-- "1" ConsumptionManager : contains
  OpenContext "1" *-- "1" ComponentInitializer : contains
  ComponentInitializer "1" *-- "1" GlobalConfig : uses
  EventManager "1" *-- "1..*" EventType : handles
  OpenContext "1" --> "1" EventManager : notifies
}
@enduml
```

### Initialization Sequence
1. Load configuration via `GlobalConfig`
2. Initialize storage backends
3. Set up LLM clients (embedding and VLM)
4. Register and initialize capture components
5. Set up processor pipeline
6. Initialize consumption generators
7. Start scheduled tasks
8. Launch web server (if enabled)

## Domain 7: Server/API Domain

**Purpose**: Provide HTTP/WebSocket interfaces for external communication and web-based administration

### Key Responsibilities
- Expose RESTful API for context operations
- Serve web interface for debugging and monitoring
- Handle WebSocket connections for real-time updates
- Implement authentication and rate limiting
- Provide admin controls for system configuration

### Core Components

```plantuml
@startuml
package "Server/API Domain" {
  class OpenContextServer {
    -_app: FastAPI
    -_server_thread: threading.Thread
    -_host: str
    -_port: int
    +start(host: str, port: int): bool
    +stop(): bool
    +is_running(): bool
    +_setup_routes(): None
    +_setup_middleware(): None
  }

  class ContextOperations {
    -_storage: BaseStorage
    -_llm_client: LLMClient
    +create_context(raw_data: Dict): ProcessedContext
    +search_contexts(query: str, filters: Dict): List[ProcessedContext]
    +update_context(context_id: str, updates: Dict): bool
    +delete_context(context_id: str): bool
    +get_context_stats(): Dict[str, Any]
  }

  package "API Routes" {
    class ContextRouter {
      +create_context()
      +get_context()
      +search_contexts()
      +update_context()
      +delete_context()
    }

    class DocumentRouter {
      +upload_document()
      +list_documents()
      +get_document()
      +delete_document()
    }

    class ScreenshotRouter {
      +capture_screenshot()
      +list_screenshots()
      +get_screenshot()
      +delete_screenshot()
    }

    class AgentChatRouter {
      +chat()
      +chat_stream()
      +get_history()
      +clear_history()
    }

    class MonitoringRouter {
      +get_metrics()
      +get_statistics()
      +get_system_status()
    }

    class SettingsRouter {
      +get_settings()
      +update_settings()
      +reset_settings()
    }
  }

  OpenContextServer "1" *-- "1" ContextOperations : uses
  OpenContextServer "1" *-- "1..*" "API Routes" : routes to
  ContextOperations "1" *-- "1" BaseStorage : uses
  ContextOperations "1" *-- "1" LLMClient : uses
}
@enduml
```

### Key API Endpoints
- `/api/v1/contexts`: CRUD operations for contexts
- `/api/v1/documents`: Document upload and management
- `/api/v1/screenshots`: Screenshot capture and retrieval
- `/api/v1/agent/chat`: AI assistant conversations
- `/api/v1/monitoring`: System metrics and statistics
- `/api/v1/settings`: Configuration management

## Domain 8: Frontend Domain

**Purpose**: Provide cross-platform desktop application interface with native system integration

### Key Responsibilities
- Manage Electron application lifecycle
- Handle system tray and notifications
- Provide React-based user interface
- Integrate with backend APIs via IPC
- Support screen capture and system permissions
- Manage local database and file storage

### Core Components

```plantuml
@startuml
package "Frontend Domain" {
  package "Main Process" {
    class ElectronMain {
      -_app: Electron.App
      -_mainWindow: BrowserWindow
      -_tray: Tray
      -_ipcMain: IpcMain
      +createWindow(): void
      +setupIPC(): void
      +setupTray(): void
      +handleAppEvents(): void
    }

    class BackendService {
      -_pythonProcess: ChildProcess
      -_apiClient: ApiClient
      +startBackend(): Promise<void>
      +stopBackend(): Promise<void>
      +isBackendRunning(): boolean
      +callAPI(endpoint: string, data: any): Promise<any>
    }

    class DatabaseService {
      -_db: Database
      +init(): Promise<void>
      +query(sql: string, params: any[]): Promise<any[]>
      +insert(table: string, data: any): Promise<number>
      +update(table: string, id: number, data: any): Promise<void>
    }

    class ScreenshotService {
      -_captureInterval: number
      -_captureTimer: Timer
      +startCapture(interval: number): void
      +stopCapture(): void
      +captureSingle(): Promise<Buffer>
      +setCaptureArea(bounds: Rectangle): void
    }
  }

  package "Renderer Process" {
    class ReactApp {
      -_router: ReactRouter
      -_store: JotaiStore
      -_theme: ThemeProvider
      +render(): JSX.Element
      +setupRoutes(): void
      +setupState(): void
    }

    class MainWindow {
      -_sidebar: SidebarComponent
      -_contentArea: ContentArea
      -_statusBar: StatusBar
      +render(): JSX.Element
      +handleNavigation(route: string): void
      +updateStatus(status: string): void
    }

    class AIChatInterface {
      -_messageList: Message[]
      -_inputField: InputField
      -_streaming: boolean
      +sendMessage(message: string): Promise<void>
      +handleStreamResponse(chunk: string): void
      +clearChat(): void
    }

    class ContextBrowser {
      -_contextList: ContextItem[]
      -_filters: FilterState
      -_searchQuery: string
      +loadContexts(): Promise<void>
      +filterContexts(filters: FilterState): void
      +searchContexts(query: string): void
    }
  }

  package "Shared" {
    class IpcChannels {
      +CAPTURE_SCREENSHOT: string
      +GET_CONTEXTS: string
      +SEND_CHAT: string
      +UPDATE_SETTINGS: string
      +GET_STATISTICS: string
    }

    class Types {
      +ContextItem: interface
      +ChatMessage: interface
      +Settings: interface
      +Activity: interface
    }

    class Constants {
      +API_BASE_URL: string
      +DEFAULT_SETTINGS: object
      +ERROR_MESSAGES: object
    }
  }

  ElectronMain "1" *-- "1" BackendService : manages
  ElectronMain "1" *-- "1" DatabaseService : uses
  ElectronMain "1" *-- "1" ScreenshotService : uses
  ReactApp "1" *-- "1" MainWindow : contains
  MainWindow "1" *-- "1" AIChatInterface : contains
  MainWindow "1" *-- "1" ContextBrowser : contains
  "Main Process" ..> "Shared" : uses
  "Renderer Process" ..> "Shared" : uses
}
@enduml
```

### Architecture Layers
1. **Main Process**: Node.js/Electron layer for system integration
2. **Renderer Process**: React-based UI layer
3. **Preload Script**: Secure bridge between main and renderer processes
4. **Shared Modules**: Common types, constants, and IPC channels

## System Flow

### 1. Context Capture Flow
```
User Activity → Screenshot Capture → RawContextProperties → CaptureManager Callback
```

### 2. Context Processing Flow
```
RawContextProperties → ProcessorManager → Document/Screenshot Processor → ProcessedContext → Storage
```

### 3. Context Consumption Flow
```
Scheduled Timer → ConsumptionManager → Context Retrieval → AI Generation → Content Storage → UI Update
```

### 4. Query/Response Flow
```
User Query → API/UI → ContextOperations → Storage Search → LLM Processing → Response Generation
```

## Key Design Patterns

### 1. Manager Pattern
Each domain has a manager class that coordinates multiple components:
- `ContextCaptureManager`: Manages capture components
- `ContextProcessorManager`: Coordinates processing pipeline
- `ConsumptionManager`: Orchestrates content generation tasks

### 2. Singleton Pattern
Global services accessible throughout the system:
- `GlobalConfig`: Centralized configuration
- `GlobalStorage`: Unified storage interface
- `GlobalEmbeddingClient`: Shared embedding service

### 3. Factory Pattern
Creates appropriate processors based on context type:
- `ProcessorFactory`: Instantiates document/screenshot processors
- Component factories for different capture sources

### 4. Strategy Pattern
Interchangeable algorithms for different tasks:
- Multiple chunking strategies for documents
- Different merge strategies for context consolidation
- Various search strategies based on query type

### 5. Observer Pattern
Event-driven communication between components:
- `EventManager` for system-wide event notifications
- Callback-based data flow between capture and processing

## Configuration Management

### Configuration Sources (in priority order):
1. Command line arguments (highest priority)
2. Configuration file (`config/config.yaml`)
3. Environment variables
4. Default values

### Key Configuration Sections:
```yaml
server:
  host: 127.0.0.1
  port: 1733

embedding_model:
  provider: doubao
  api_key: your-api-key
  model: doubao-embedding-large-text-240915

vlm_model:
  provider: doubao
  api_key: your-api-key
  model: doubao-seed-1-6-flash-250828

capture:
  enabled: true
  screenshot:
    enabled: true
    capture_interval: 5

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

## Data Models

### Core Data Types:

1. **RawContextProperties**: Raw captured data with source metadata
2. **ProcessedContext**: Enriched context with embeddings and metadata
3. **ExtractedData**: Semantic information extracted from content
4. **Vectorize**: Vector representation for similarity search
5. **ContextProperties**: Temporal and usage metadata

### Context Classification Hierarchy:
```
ContextType (Enum)
├── ENTITY_CONTEXT (9) - People, projects, organizations
├── ACTIVITY_CONTEXT (8) - Actions, events, behaviors
├── INTENT_CONTEXT (7) - Goals, plans, intentions
├── SEMANTIC_CONTEXT (6) - Concepts, knowledge, principles
├── PROCEDURAL_CONTEXT (5) - Processes, workflows, steps
├── STATE_CONTEXT (4) - Status, progress, metrics
└── KNOWLEDGE_CONTEXT (-) - File-based content
```

Numbers in parentheses indicate classification priority.

## Error Handling and Monitoring

### Monitoring Components:
1. **MetricsCollector**: Gathers system performance metrics
2. **Monitor**: Central monitoring coordination
3. **API endpoints**: `/api/v1/monitoring/*`

### Error Recovery Strategies:
1. **Retry with exponential backoff**: For transient API failures
2. **Fallback processors**: Alternative processing strategies
3. **Graceful degradation**: Continue with reduced functionality
4. **Data validation**: Prevent invalid data propagation

## Extension Points

### 1. New Capture Sources
Implement `ICaptureComponent` interface and register with `CaptureManager`

### 2. Custom Processors
Implement `IProcessorComponent` interface and register with `ProcessorManager`

### 3. Additional Storage Backends
Implement `BaseStorage` interface and configure in `UnifiedStorage`

### 4. New LLM Providers
Extend `LLMClient` base class and update provider configuration

### 5. Custom Content Generators
Add new generator classes to `ConsumptionManager` scheduling

## Security Considerations

### 1. Data Privacy
- Local-first data storage by default
- Optional local AI model support
- No data leaves local machine without explicit configuration

### 2. Access Control
- API key management for external services
- Local-only API access by default
- Configurable CORS and authentication

### 3. Input Validation
- Pydantic models for data validation
- Content type verification
- Size and rate limiting

## Performance Considerations

### 1. Caching Strategies
- Embedding cache to avoid redundant API calls
- Context retrieval cache for frequent queries
- Processor result caching

### 2. Batch Processing
- Batch embedding generation
- Bulk context storage operations
- Scheduled task batching

### 3. Resource Management
- Thread pool management for concurrent processing
- Memory usage monitoring and limits
- Database connection pooling

## Deployment Considerations

### 1. Platform Support
- **macOS**: Native application with DMG packaging
- **Windows**: EXE installer with system integration
- **Linux**: AppImage and DEB packages (planned)

### 2. Dependency Management
- **Backend**: uv for Python dependency management
- **Frontend**: pnpm for Node.js dependencies
- **Cross-platform**: Electron for desktop runtime

### 3. Update Mechanism
- Electron auto-updater for application updates
- Backend package updates via package manager
- Configuration migration utilities

## Conclusion

MineContext implements a sophisticated, modular architecture designed for extensibility and maintainability. The eight core domains work together to provide:

1. **Effortless Context Collection**: Multi-source capture with unified interface
2. **Intelligent Processing**: AI-powered enrichment and classification
3. **Proactive Consumption**: Scheduled generation of valuable insights
4. **Flexible Storage**: Multi-backend support with vector search
5. **Extensible Design**: Clean interfaces for custom extensions

The system's local-first approach prioritizes user privacy while providing powerful AI-assisted context management capabilities.