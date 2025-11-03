# MineContext Repository Structure

## Project Overview
MineContext is an open-source, proactive context-aware AI partner that brings clarity and efficiency to work, study, and creation. It's developed by Volcengine and supports both English and Chinese languages.

## Repository Structure

```
MineContext/
├── .git/                          # Git version control
├── .github/                       # GitHub configuration
│   └── ISSUE_TEMPLATE/            # Issue templates
├── 01-tutorial/                   # Tutorial directory (currently empty)
│   └── DIRECTORY_STRUCTURE.md     # This file
│
├── Root Files:
│   ├── README.md                  # Main documentation (English)
│   ├── README_zh.md               # Main documentation (Chinese)
│   ├── CONTRIBUTING.md            # Contribution guidelines
│   ├── LICENSE                    # License file
│   ├── .gitignore                 # Git ignore rules
│   ├── .pre-commit-config.yaml    # Pre-commit hooks configuration
│   ├── pyproject.toml             # Python project configuration
│   ├── hook-opencontext.py        # Context hook script
│   ├── opencontext.spec           # Application specification
│   ├── build.sh                   # Build script (Unix)
│   └── build.bat                  # Build script (Windows)
│
├── src/                           # Source code assets
│   ├── MineContext-Banner.svg     # Project banner
│   ├── Download-App.gif           # Download instructions animation
│   ├── Enable-Permissions.gif     # Permission setup animation
│   ├── Enter-API-Key.gif          # API key setup animation
│   ├── Quarantine.gif             # Quarantine handling animation
│   ├── Screen-Settings.gif        # Screen settings animation
│   ├── feature.gif                # Feature demonstration
│   ├── backend-web-*.png          # Backend web interface screenshots
│   ├── doubao-*.png               # Doubao model screenshots
│   ├── architecture-overview.md   # Architecture overview (English)
│   └── architecture-overview-zh.md # Architecture overview (Chinese)
│
├── config/                        # Configuration files
│   ├── config.yaml                # Main configuration
│   ├── prompts_en.yaml            # English prompts (112KB)
│   ├── prompts_zh.yaml            # Chinese prompts (95KB)
│   └── quick_start_default.md     # Quick start guide
│
├── examples/                      # Example implementations
│   ├── example_document_processor.py      # Document processing example
│   ├── example_screenshot_processor.py    # Screenshot processing example
│   ├── example_screenshot_to_insights.py  # Screenshot to insights example
│   ├── example_todo_deduplication.py      # TODO deduplication example
│   └── regenerate_debug_file.py           # Debug file regeneration
│
├── frontend/                      # Frontend application
│   ├── build/                     # Build outputs
│   ├── externals/                 # External dependencies
│   ├── packages/                  # NPM packages
│   ├── resources/                 # Frontend resources
│   ├── scripts/                   # Build scripts
│   └── src/                       # Frontend source code
│
├── opencontext/                   # Core backend application
│   ├── config/                    # Backend configuration
│   ├── context_capture/           # Context capture modules
│   ├── context_consumption/       # Context consumption modules
│   ├── context_processing/        # Context processing modules
│   ├── interfaces/                # Interface definitions
│   ├── llm/                       # LLM integration
│   ├── managers/                  # Manager classes
│   ├── models/                    # Data models
│   ├── monitoring/                # Monitoring and logging
│   ├── server/                    # Server components
│   ├── storage/                   # Storage modules
│   ├── tools/                     # Utility tools
│   ├── utils/                     # Utility functions
│   └── web/                       # Web interface
│
└── [Additional git directories]   # Git internal directories
```

## Key Components

### 1. **Frontend** (`/frontend/`)
- Modern frontend application built with standard web technologies
- Contains build system, external dependencies, and source code
- Packages for dependency management
- Resources and scripts for development

### 2. **Backend Core** (`/opencontext/`)
- **Context Capture**: Modules for capturing user context
- **Context Consumption**: Modules for processing and consuming context
- **Context Processing**: Core processing logic for context data
- **LLM Integration**: Large Language Model integration components
- **Managers**: Various manager classes for coordination
- **Models**: Data models and structures
- **Monitoring**: System monitoring and logging capabilities
- **Server**: Backend server components
- **Storage**: Data storage and retrieval modules
- **Web**: Web interface components

### 3. **Configuration** (`/config/`)
- Main application configuration (`config.yaml`)
- Extensive prompt libraries for English and Chinese
- Quick start documentation

### 4. **Examples** (`/examples/`)
- Practical examples showing how to use MineContext features
- Document processing, screenshot analysis, and TODO management examples
- Debug utilities for development

### 5. **Documentation Assets** (`/src/`)
- Visual assets including banners, GIFs, and screenshots
- Architecture documentation in both English and Chinese
- Feature demonstrations and setup instructions

## Project Characteristics

- **Multi-language Support**: Full English and Chinese language support
- **Cross-platform**: Supports Windows and macOS
- **Local-First**: Privacy-focused with local processing capabilities
- **AI-Powered**: Integrated with LLM and computer vision models (Doubao)
- **Modular Architecture**: Well-organized modular structure for maintainability
- **Development Ready**: Includes build scripts, pre-commit hooks, and debugging tools

## 01-Tutorial Directory
The `01-tutorial/` directory is currently empty and appears to be reserved for tutorial materials or documentation. This file serves as the initial content to document the repository structure.
