# GlobalConfig Workflows Documentation

## Overview

The `GlobalConfig` class is a singleton-based global configuration manager that provides a unified interface for accessing configurations and prompts across the entire application. This document describes the main workflows using PlantUML sequence diagrams.

## Architecture

### 1. Singleton Creation and Instance Retrieval Workflow

This diagram shows how the singleton pattern ensures only one instance exists and how auto-initialization works when `get_instance()` is called.

```plantuml
@startuml
actor "Client Code" as Client
participant "GlobalConfig" as GC
participant "ConfigManager" as CM
participant "PromptManager" as PM
participant "Logger" as Log

== get_instance() Call ==

Client -> GC: get_instance()
activate GC

alt Instance Not Created
    GC -> GC: __new__()
    activate GC
    note right: Double-checked locking
    GC -> GC: Create instance
    GC --> GC: Return instance
    deactivate GC
end

alt Not Auto-Initialized
    GC -> GC: _auto_initialize()
    activate GC

    alt Config file exists
        GC -> GC: initialize("config/config.yaml")
        activate GC
        GC -> CM: load_config()
        GC -> PM: Load prompts
        GC --> GC: Return success
        deactivate GC
        GC -> Log: info("Config loaded")
    else Config file not found
        GC -> Log: error("No config file found")
        GC -> Log: warning("Using defaults")
    end

    GC --> GC: Set _auto_initialized = True
    deactivate GC
end

GC --> Client: Return instance
@enduml
```

**Key Points:**
- Uses double-checked locking pattern in `__new__()` for thread-safe singleton creation
- Auto-initializes on first `get_instance()` call if not already initialized
- Attempts to load `config/config.yaml` by default
- Falls back to default configuration if file not found

### 2. Manual Initialization Workflow

This diagram shows the detailed initialization process when `initialize()` is called explicitly.

```plantuml
@startuml
actor "Client Code" as Client
participant "GlobalConfig" as GC
participant "ConfigManager" as CM
participant "PromptManager" as PM
participant "Logger" as Log

== initialize() Call ==

Client -> GC: initialize(config_path)
activate GC

GC -> GC: _init_prompt_manager()
activate GC

alt ConfigManager exists
    GC -> CM: get_config()
    CM --> GC: config dict
    GC -> GC: Extract prompts config
    GC -> GC: Determine language (default: zh)
    GC -> GC: Build prompt file path

    alt Prompt file exists
        GC -> PM: PromptManager(path)
        GC -> PM: load_user_prompts()
        GC -> Log: info("Prompts loaded")
        GC --> GC: Return True
    else Prompt file not found
        GC -> Log: warning("Prompt file not found")
        GC --> GC: Return False
    end
else No ConfigManager
    GC -> Log: warning("Config manager not initialized")
    GC --> GC: Return False
end

deactivate GC

alt ConfigManager Not Initialized
    GC -> CM: ConfigManager()
    GC -> CM: load_config(config_path)

    alt Config loaded
        CM --> GC: success
        GC -> GC: Store _config_path
        GC -> Log: info("Config loaded")
    else Failed
        GC -> Log: warning("Using default")
        GC -> GC: success = False
    end
end

alt PromptManager Not Initialized
    GC -> GC: _init_prompt_manager()
    alt Success
        GC -> GC: success = True
    else Failed
        GC -> GC: success = False
    end
end

GC --> Client: Return success
@enduml
```

**Key Points:**
- Initializes both `ConfigManager` and `PromptManager`
- ConfigManager loads configuration from YAML file
- PromptManager loads language-specific prompts (e.g., `prompts_zh.yaml`)
- Also loads user-customized prompts if available

### 3. Language Change Workflow

This diagram shows the process of changing the language setting and reloading prompts.

```plantuml
@startuml
actor "Client Code" as Client
participant "GlobalConfig" as GC
participant "ConfigManager" as CM
participant "PromptManager" as PM
participant "Logger" as Log
participant "File System" as FS

== set_language() Call ==

Client -> GC: set_language(language)
activate GC

alt Invalid Language
    GC -> Log: error("Invalid language")
    GC --> Client: Return False
end

GC -> GC: Store _language
GC -> CM: save_user_settings({prompts: {language: language}})

alt Save Failed
    GC -> Log: error("Failed to save")
    GC --> Client: Return False
end

GC -> CM: load_config(_config_path)
GC -> GC: Build new prompt path (prompts_{language}.yaml)
GC -> FS: Check file existence

alt File Not Found
    FS --> GC: Not exists
    GC -> Log: error("Prompt file not found")
    GC --> Client: Return False
end

GC -> PM: PromptManager(new_path)
GC -> PM: load_user_prompts()
GC -> GC: Update _prompt_manager & _prompt_path
GC -> Log: info("Prompts reloaded")
GC --> Client: Return True
@enduml
```

**Key Points:**
- Validates language code (only "zh" or "en" supported)
- Persists language setting to user settings
- Reloads configuration to pick up new language
- Reloads prompts from language-specific file
- Loads user-customized prompts

### 4. Configuration Access Workflow

This diagram shows how configuration values are retrieved using path-based access.

```plantuml
@startuml
actor "Client Code" as Client
participant "GlobalConfig" as GC
participant "ConfigManager" as CM
participant "Logger" as Log

== get_config() Call ==

Client -> GC: get_config(path)
activate GC

alt No ConfigManager
    GC -> Log: warning("Config manager not initialized")
    GC --> Client: Return None
end

GC -> CM: get_config()
CM --> GC: config dict

alt No Config
    GC --> Client: Return None
end

alt No Path Specified
    GC --> Client: Return full config dict
else Path Specified
    GC -> GC: Split path by "."
    GC -> GC: Traverse config dict

    alt Key Not Found
        GC -> Log: debug("Config path not found")
        GC --> Client: Return None
    else Key Found
        GC --> Client: Return value
    end
end
@enduml
```

**Key Points:**
- Supports nested configuration access using dot notation (e.g., "database.host")
- Returns full config dict if no path specified
- Returns None for missing paths

### 5. Prompt Access Workflow

This diagram shows how prompts and prompt groups are retrieved.

```plantuml
@startuml
actor "Client Code" as Client
participant "GlobalConfig" as GC
participant "PromptManager" as PM
participant "Logger" as Log

== get_prompt() Call ==

Client -> GC: get_prompt(name, default)
activate GC

alt No PromptManager
    GC -> Log: warning("Prompt manager not initialized")
    GC --> Client: Return default
end

GC -> PM: get_prompt(name, default)
PM --> GC: prompt string
GC --> Client: Return prompt

== get_prompt_group() Call ==

Client -> GC: get_prompt_group(name)
activate GC

alt No PromptManager
    GC -> Log: warning("Prompt manager not initialized")
    GC --> Client: Return empty dict
end

GC -> PM: get_prompt_group(name)
PM --> GC: prompt group dict
GC --> Client: Return prompt group
@enduml
```

**Key Points:**
- Returns default value if prompt manager not initialized
- Prompt groups return dictionaries of related prompts
- Empty dict returned for missing prompt groups

### 6. Module Check Workflow

This diagram shows how to check if a module is enabled.

```plantuml
@startuml
actor "Client Code" as Client
participant "GlobalConfig" as GC
participant "Logger" as Log

== is_enabled() Call ==

Client -> GC: is_enabled(module)
activate GC

GC -> GC: get_config(module)

alt Config is dict
    GC -> GC: Get "enabled" key
    GC --> Client: Return enabled value (default: False)
else Config not dict or None
    GC --> Client: Return False
end
@enduml
```

**Key Points:**
- Checks if a module configuration exists and has "enabled" set to true
- Returns false for missing or invalid module configs

## Key Features

### Thread Safety
- Uses double-checked locking pattern for singleton creation
- Lock-based initialization to prevent race conditions

### Auto-Initialization
- Automatically attempts to initialize on first use
- Falls back to defaults if config file not found

### Error Handling
- Graceful degradation when configuration files are missing
- Comprehensive logging for debugging
- Default values returned when managers not initialized

### Backward Compatibility
- Setter methods for manual manager injection
- Convenience functions for common operations

## Usage Examples

### Basic Usage

```python
from opencontext.config.global_config import GlobalConfig

# Get the singleton instance (auto-initializes)
config = GlobalConfig.get_instance()

# Access configuration
api_key = config.get_config("openai.api_key")
database_host = config.get_config("database.host")

# Check if module is enabled
if config.is_enabled("openai"):
    # Use OpenAI features
    pass

# Get a prompt
default_prompt = config.get_prompt("default", "Default prompt text")

# Get a prompt group
openai_prompts = config.get_prompt_group("openai")
```

### Language Switching

```python
# Change language (reloads prompts)
if config.set_language("en"):
    print("Language changed to English")
else:
    print("Failed to change language")
```

### Using Convenience Functions

```python
from opencontext.config.global_config import (
    get_config, get_prompt, get_language, is_initialized
)

# Direct access without getting instance
api_key = get_config("openai.api_key")
prompt = get_prompt("default")
language = get_language()
```

## Class Structure

```plantuml
@startuml
class GlobalConfig {
    -_instance: GlobalConfig
    -_lock: threading.Lock
    -_initialized: bool
    -_config_manager: ConfigManager
    -_prompt_manager: PromptManager
    -_config_path: str
    -_prompt_path: str
    -_auto_initialized: bool
    -_language: str
    +__new__(): GlobalConfig
    +__init__()
    +{static} get_instance(): GlobalConfig
    +{static} reset()
    -_auto_initialize()
    +initialize(config_path): bool
    -_init_prompt_manager(): bool
    +set_config_manager(config_manager)
    +set_prompt_manager(prompt_manager)
    +get_config_manager(): ConfigManager
    +get_prompt_manager(): PromptManager
    +get_language(): str
    +set_language(language): bool
    +get_config(path): dict
    +get_prompt(name, default): str
    +get_prompt_group(name): dict
    +is_enabled(module): bool
    +is_initialized(): bool
}

class ConfigManager {
    +load_config(path): bool
    +get_config(): dict
    +get_config_path(): str
    +save_user_settings(settings): bool
}

class PromptManager {
    +__init__(path)
    +get_prompt(name, default): str
    +get_prompt_group(name): dict
    +load_user_prompts()
}

GlobalConfig --> ConfigManager: uses
GlobalConfig --> PromptManager: uses
@enduml
```

## Error Scenarios

### Missing Configuration File

```plantuml
@startuml
actor "Client" as C
participant "GlobalConfig" as GC
participant "Logger" as L

C -> GC: get_instance()
GC -> GC: _auto_initialize()
GC -> GC: initialize("config/config.yaml")
GC -> GC: Load config (fails)
GC -> L: error("No config file")
GC -> L: warning("Using defaults")
GC -> GC: Set _auto_initialized = True
GC --> C: Return instance
@enduml
```

### Missing Prompt File

```plantuml
@startuml
actor "Client" as C
participant "GlobalConfig" as GC
participant "Logger" as L

C -> GC: initialize()
GC -> GC: _init_prompt_manager()
GC -> GC: Build prompt path
GC -> GC: Check file existence (fails)
GC -> L: warning("Prompt file not found")
GC --> C: Return False
@enduml
```

## Thread Safety Mechanism

```plantuml
@startuml
actor "Thread 1" as T1
actor "Thread 2" as T2
participant "GlobalConfig" as GC
participant "Lock" as Lock

== Concurrent Instance Creation ==

T1 -> GC: get_instance()
GC -> Lock: acquire()
Lock --> GC: Lock acquired
GC -> GC: Create _instance
GC -> Lock: release()

T2 -> GC: get_instance()
GC -> Lock: acquire()
Lock --> GC: Lock acquired
GC -> GC: _instance already exists
GC -> Lock: release()

== Concurrent Initialization ==

T1 -> GC: __init__()
GC -> GC: Check _initialized
GC -> Lock: acquire()
GC -> GC: Initialize fields
GC -> Lock: release()

T2 -> GC: __init__()
GC -> GC: Check _initialized (True)
GC -> GC: Skip initialization
@enduml
```

**Key Points:**
- Double-checked locking prevents multiple instance creation
- Initialization lock prevents race conditions during setup
- Check flags prevent re-initialization

## Related Files

- `opencontext/config/config_manager.py` - Configuration file management
- `opencontext/config/prompt_manager.py` - Prompt file management
- `config/config.yaml` - Main configuration file
- `config/prompts_zh.yaml` - Chinese prompts
- `config/prompts_en.yaml` - English prompts
