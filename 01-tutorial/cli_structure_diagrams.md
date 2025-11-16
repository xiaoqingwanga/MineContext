# OpenContext CLI Structure Diagrams

This document contains Mermaid diagrams that illustrate the structure and architecture of the `opencontext/cli.py` file.

## 1. Main Function Flow Diagram

Shows the execution path from command line to server startup:

```mermaid
flowchart TD
    A[main function] --> B[parse_args]
    B --> C{Command?}
    C -->|start| D[handle_start]
    C -->|None| E[Error: No command]

    D --> F[_initialize_context_lab]
    F --> G{Web enabled?}
    G -->|Yes| H[start_web_server]
    G -->|No| I[_run_headless_mode]

    H --> J[uvicorn.run]
    I --> K[Infinite loop + shutdown]
```

## 2. Function Hierarchy Diagram

Displays the relationships between different functions:

```mermaid
graph TD
    A[main] --> B[parse_args]
    A --> C[_setup_logging]
    A --> D[handle_start]

    B --> E[argparse.ArgumentParser]
    B --> F[subparsers.add_parser]

    D --> G[_initialize_context_lab]
    D --> H[start_web_server]
    D --> I[_run_headless_mode]

    H --> J[get_or_create_context_lab]
    H --> K[uvicorn.run]

    J --> L[_initialize_context_lab]

    M[lifespan] --> N[get_or_create_context_lab]

    O[_setup_static_files] --> P[StaticFiles mounts]
```

## 3. FastAPI Application Structure

Illustrates the web application components:

```mermaid
graph LR
    A[FastAPI app] --> B[CORSMiddleware]
    A --> C[StaticFiles]
    A --> D[api_router]
    A --> E[lifespan manager]

    C --> F[/static/]
    C --> G[/screenshots/]

    E --> H[get_or_create_context_lab]
    H --> I[_initialize_context_lab]
    I --> J[OpenContext instance]
```

## 4. Configuration and Dependencies

Shows internal and external dependencies:

```mermaid
graph LR
    A[cli.py] --> B[opencontext.config.config_manager]
    A --> C[opencontext.server.api]
    A --> D[opencontext.server.opencontext]
    A --> E[opencontext.utils.logging_utils]

    F[Global variables] --> G[_config_path]
    F --> H[_context_lab_instance]

    I[External dependencies] --> J[argparse]
    I --> K[uvicorn]
    I --> L[fastapi]
    I --> M[pathlib]
```

## 5. Command Line Interface Structure

Details the command line interface options:

```mermaid
graph TD
    A[opencontext] --> B[start]

    B --> C[--config]
    B --> D[--host]
    B --> E[--port]
    B --> F[--workers]

    G[Main execution flow] --> H[Single process mode]
    G --> I[Multi-process mode]

    H --> J[Direct app instance]
    I --> K[Import string: opencontext.cli:app]
```

## 6. Error Handling and Lifecycle

Shows the error handling and lifecycle management:

```mermaid
flowchart TD
    A[Start] --> B[Initialize logging]
    B --> C[Parse args]
    C --> D{Valid command?}
    D -->|No| E[Error exit]
    D -->|Yes| F[Execute command]

    F --> G{Initialization success?}
    G -->|No| H[Error exit]
    G -->|Yes| I[Start modules]

    I --> J{Web enabled?}
    J -->|Yes| K[Start web server]
    J -->|No| L[Headless mode]

    K --> M[Server running]
    L --> N[Background capture]

    M --> O[KeyboardInterrupt]
    N --> O

    O --> P[Shutdown cleanup]
    P --> Q[Exit]
```

## Key Components Explained

### Main Entry Point
- `main()`: Primary entry function that orchestrates the entire startup process
- `parse_args()`: Handles command line argument parsing with subcommands

### Application Initialization
- `_initialize_context_lab()`: Creates and initializes the OpenContext instance
- `_setup_logging()`: Configures logging based on configuration files
- `_setup_static_files()`: Mounts static file directories for the web server

### Web Server Management
- `start_web_server()`: Starts the uvicorn web server in single or multi-process mode
- `lifespan()`: FastAPI lifespan manager for startup/shutdown hooks
- `get_or_create_context_lab()`: Singleton pattern for OpenContext instance

### Operation Modes
- **Web Server Mode**: Full web interface with API endpoints
- **Headless Mode**: Background operation without web interface

### Configuration
- Supports configuration file override via `--config` parameter
- Command line arguments take precedence over configuration file settings
- Multi-process support for production deployments

This CLI serves as the main entry point for the OpenContext system, providing both web server and headless operation modes with proper configuration management and error handling.