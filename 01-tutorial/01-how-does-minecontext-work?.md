# MineContext 原理分析

## MineContext 是什么？

MineContext 是由火山引擎开源的个人记录助理。其通过后台智能记录用户操作，帮助用户梳理数字活动，提供个性化的回顾和总结。

## MineContext 整体的执行流程

### 数据产生流程

截图 -> 转换 -> 存储
![](processing-pipeline.png)

### 数据消费流程

截图 -> Agent -> 查找 -> 总结

## Agent 流程分析

### Intent 流程

### Context 流程

```plantuml
@startuml
skinparam maxMessageSize 250
participant "ContextNode" as Node
participant "StreamingManager" as Stream
participant "StateManager" as StateMap
participant "WorkflowState" as State
participant "Global Storage" as Storage
participant "LLMContextStrategy" as Strategy
[-> Node: process(state)
activate Node
Node -> State: update_stage(CONTEXT_GATHERING)
Node -> Stream: emit(RUNNING, "Starting to intelligently analyze...")
' Document Context Handling
alt state.query.document_id is set
    Node -> Storage: get_vault(document_id)
    activate Storage
    Storage --> Node: doc
    deactivate Storage
    
    alt doc not found
        Node -> Stream: emit(FAIL, "Document not found")
        Node -> State: update_stage(FAILED)
        [<-- Node: state
    else doc found
        Node -> State: contexts.current_document = DocumentInfo(...)
        Node -> Stream: emit(DONE, "Added document context...")
    end
end
' Iterative Collection Loop
loop iteration < max_iterations (default 2)
    Node -> Stream: emit(RUNNING, "Round {i} collection...")
    
    ' 1. Evaluate Sufficiency
    Node -> Strategy: evaluate_sufficiency(contexts, intent)
    activate Strategy
    Strategy --> Node: sufficiency
    deactivate Strategy
    Node -> State: contexts.sufficiency = sufficiency
    
    alt is SUFFICIENT
        Node -> Stream: emit(DONE, "Context is sufficient...")
        Node -> Node: break
    end
    
    ' 2. Analyze & Plan
    Node -> Strategy: analyze_and_plan_tools(intent, contexts, iteration)
    activate Strategy
    Strategy --> Node: tool_calls
    deactivate Strategy
    
    alt no tool_calls
        Node -> Stream: emit(DONE, "No more tools to call...")
        Node -> Node: break
    end
    
    ' 3. Execute Tools
    Node -> Stream: emit(RUNNING, "Concurrently calling tools...")
    Node -> Strategy: execute_tool_calls_parallel(tool_calls)
    activate Strategy
    Strategy --> Node: new_context_items
    deactivate Strategy
    
    ' 4. Validate & Filter
    Node -> Stream: emit(RUNNING, "Validating tool results...")
    Node -> Strategy: validate_and_filter_tool_results(...)
    activate Strategy
    Strategy --> Node: validated_items
    deactivate Strategy
    
    ' 5. Add to Context
    loop for item in validated_items
        Node -> State: contexts.add_item(item)
    end
    
    Node -> Stream: emit(DONE, "Round {i}: Added items...")
    
    ' Max Iterations Check
    alt iteration >= max_iterations
        Node -> State: contexts.sufficiency = PARTIAL
        Node -> Stream: emit(DONE, "Maximum collection rounds reached...")
        Node -> Node: break
    end
end
[<-- Node: state
deactivate Node
@enduml
```

### Execute 流程

### Reflect 流程

## ReAct 模式总结

## Tools Pattern


## 参考资料

## 特殊优化点
- 智能 few shots
