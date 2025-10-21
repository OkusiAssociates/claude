# Claude Agent SDK - Python Examples

## Overview

This directory contains Python examples demonstrating how to use the Claude Agent SDK for programmatic interaction with Claude Code. The SDK provides a powerful interface for building custom AI-powered applications, automation tools, and integrations.

**Location:** `/ai/scripts/claude/sdk/`

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Custom Tools](#custom-tools)
- [Built-in Tools](#built-in-tools)
- [Agent Options](#agent-options)
- [Advanced Patterns](#advanced-patterns)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

## Installation

### Prerequisites

- Python 3.12+
- pip package manager

### Install SDK

```bash
# Install Claude Agent SDK
pip install claude-agent-sdk

# Install optional dependencies for examples
pip install rich
```

### Verify Installation

```python
import claude_agent_sdk
print(claude_agent_sdk.__version__)
```

## Basic Usage

### basic.py - Simple Query Example

**File:** `sdk/basic.py` (9 lines)

The simplest way to query Claude programmatically.

**Source Code:**
```python
import asyncio
from claude_agent_sdk import query

async def main():
    async for message in query(prompt="Hello, how are you?"):
        print(message)

asyncio.run(main())
```

**Running:**
```bash
cd sdk
python basic.py
```

**Output:**
```
Hello! I'm doing well, thank you for asking. How can I help you today?
```

### Understanding the Response

The `query()` function returns an async iterator that yields response chunks:

```python
async for message in query(prompt="Your prompt here"):
    # message is a dict containing response data
    print(message)
```

**Message Structure:**
```python
{
  "type": "text",
  "text": "Response content here..."
}
```

### Synchronous Alternative

For simpler scripts without async:
```python
import asyncio
from claude_agent_sdk import query

def simple_query(prompt):
    async def _query():
        result = []
        async for msg in query(prompt=prompt):
            result.append(msg)
        return result

    return asyncio.run(_query())

# Use it
messages = simple_query("What is 2+2?")
for msg in messages:
    print(msg)
```

## Custom Tools

### custom-tools.py - Creating Custom MCP Tools

**File:** `sdk/custom-tools.py` (34 lines)

Demonstrates creating custom tools that Claude can invoke.

**Source Code:**
```python
import asyncio
from typing import Any
from claude_agent_sdk import (
    ClaudeSDKClient,
    ClaudeAgentOptions,
    tool,
    create_sdk_mcp_server
)
from rich import print

@tool("greet", "Greet a user", {"name": str})
async def greet(args: dict[str, Any]) -> dict[str, Any]:
    return {
        "content": [{
            "type": "text",
            "text": f"Hello, {args['name']}!"
        }]
    }

server = create_sdk_mcp_server(
    name="my-tools",
    version="1.0.0",
    tools=[greet]
)

async def main():
    options = ClaudeAgentOptions(
        mcp_servers={"tools": server},
        allowed_tools=["mcp__tools__greet"]
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Greet Mervin Praison")
        async for msg in client.receive_response():
            print(msg)

asyncio.run(main())
```

**Running:**
```bash
cd sdk
python custom-tools.py
```

### Custom Tool Components

#### 1. Tool Decorator

```python
@tool(
    name="tool_name",           # Tool identifier
    description="What it does", # Description for Claude
    parameters={"arg": type}    # Expected parameters
)
async def tool_function(args: dict[str, Any]) -> dict[str, Any]:
    # Implementation
    return {
        "content": [{
            "type": "text",
            "text": "Result"
        }]
    }
```

**Parameter Types:**
- `str` - String input
- `int` - Integer input
- `float` - Float input
- `bool` - Boolean input
- `list` - Array input
- `dict` - Object input

#### 2. MCP Server Creation

```python
server = create_sdk_mcp_server(
    name="server-name",    # Unique server identifier
    version="1.0.0",       # Server version
    tools=[tool1, tool2]   # List of tool functions
)
```

#### 3. Tool Registration

```python
options = ClaudeAgentOptions(
    mcp_servers={"tools": server},          # Register server
    allowed_tools=["mcp__tools__greet"]     # Allow specific tools
)
```

**Tool Name Format:** `mcp__{server_name}__{tool_name}`

### Example: Calculator Tool

```python
@tool("calculate", "Perform arithmetic", {
    "operation": str,
    "a": float,
    "b": float
})
async def calculate(args: dict[str, Any]) -> dict[str, Any]:
    ops = {
        "add": lambda a, b: a + b,
        "subtract": lambda a, b: a - b,
        "multiply": lambda a, b: a * b,
        "divide": lambda a, b: a / b if b != 0 else float('inf')
    }

    result = ops[args["operation"]](args["a"], args["b"])

    return {
        "content": [{
            "type": "text",
            "text": f"Result: {result}"
        }]
    }

server = create_sdk_mcp_server(
    name="math-tools",
    version="1.0.0",
    tools=[calculate]
)

async def main():
    options = ClaudeAgentOptions(
        mcp_servers={"math": server},
        allowed_tools=["mcp__math__calculate"]
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Calculate 15 * 23")
        async for msg in client.receive_response():
            print(msg)

asyncio.run(main())
```

### Example: File Search Tool

```python
import os

@tool("find_files", "Find files by pattern", {
    "pattern": str,
    "directory": str
})
async def find_files(args: dict[str, Any]) -> dict[str, Any]:
    import glob

    pattern = args["pattern"]
    directory = args.get("directory", ".")

    files = glob.glob(f"{directory}/**/{pattern}", recursive=True)

    return {
        "content": [{
            "type": "text",
            "text": f"Found {len(files)} files:\n" + "\n".join(files[:10])
        }]
    }
```

## Built-in Tools

### inbuild-tools.py - Using Claude's Native Tools

**File:** `sdk/inbuild-tools.py` (19 lines)

Demonstrates using Claude's built-in tools (Read, Write, Edit, Bash).

**Source Code:**
```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions
from rich import print

async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Write"],
        permission_mode="acceptEdits"
    )

    async for msg in query(
        prompt="Create a file called greeting.txt with 'Hello Mervin Praison!'",
        options=options
    ):
        print(msg)

asyncio.run(main())
```

**Running:**
```bash
cd sdk
python inbuild-tools.py
```

**Result:**
Creates `greeting.txt` with the specified content.

### Available Built-in Tools

| Tool | Description | Use Case |
|------|-------------|----------|
| **Read** | Read file contents | File analysis, code review |
| **Write** | Create/overwrite files | File generation, templating |
| **Edit** | Modify existing files | Code updates, refactoring |
| **Bash** | Execute shell commands | System operations, testing |
| **Glob** | File pattern matching | File discovery |
| **Grep** | Content search | Code search, analysis |

### Tool Restrictions

Control which tools Claude can use:

**Read-Only Mode:**
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Grep", "Glob"],
    permission_mode="ask"
)
```

**Write Mode:**
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Edit"],
    permission_mode="acceptEdits"
)
```

**Full Access:**
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Edit", "Bash"],
    permission_mode="acceptEdits"
)
```

### Permission Modes

| Mode | Behavior |
|------|----------|
| `"ask"` | Prompt for each operation |
| `"acceptEdits"` | Auto-accept file edits |
| `"acceptAll"` | Auto-accept all operations |

**▲ Warning:** `acceptAll` with `Bash` tool allows arbitrary command execution

### Example: Code Analysis

```python
async def analyze_code(file_path):
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Grep"],
        permission_mode="acceptEdits"
    )

    async for msg in query(
        prompt=f"Analyze {file_path} for potential bugs and security issues",
        options=options
    ):
        print(msg)

asyncio.run(analyze_code("app.py"))
```

### Example: Automated Refactoring

```python
async def refactor_code(directory):
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Write", "Edit", "Glob"],
        permission_mode="acceptEdits",
        cwd=directory
    )

    async for msg in query(
        prompt="Refactor all Python files to use type hints",
        options=options
    ):
        print(msg)

asyncio.run(refactor_code("./src"))
```

## Agent Options

### agent-options.py - Advanced Configuration

**File:** `sdk/agent-options.py` (17 lines)

Demonstrates advanced agent configuration with custom options.

**Source Code:**
```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions
from rich import print

async def main():
    options = ClaudeAgentOptions(
        system_prompt="You are an expert Python developer",
        permission_mode='acceptEdits',
        cwd="test"
    )

    async for message in query(
        prompt="Create a Python web server in my current directory",
        options=options
    ):
        print(message)

asyncio.run(main())
```

**Running:**
```bash
cd sdk
python agent-options.py
```

### ClaudeAgentOptions Parameters

#### system_prompt

Custom system instructions for Claude.

```python
options = ClaudeAgentOptions(
    system_prompt="""
    You are a senior software engineer specializing in Python.
    Focus on writing clean, maintainable, well-documented code.
    Always include type hints and docstrings.
    """
)
```

**Use Cases:**
- Domain expertise (e.g., "expert in machine learning")
- Coding style enforcement
- Output format specification
- Behavior constraints

#### permission_mode

Controls operation approval behavior.

```python
options = ClaudeAgentOptions(
    permission_mode="acceptEdits"  # or "ask" or "acceptAll"
)
```

#### cwd (Current Working Directory)

Set working directory for file operations.

```python
options = ClaudeAgentOptions(
    cwd="/path/to/project"
)
```

**◉ Info:** All file operations are relative to this directory

#### allowed_tools

Restrict available tools.

```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Grep"]
)
```

#### mcp_servers

Register custom MCP tool servers.

```python
options = ClaudeAgentOptions(
    mcp_servers={
        "custom": my_server,
        "tools": tools_server
    }
)
```

#### model

Specify Claude model version.

```python
options = ClaudeAgentOptions(
    model="claude-sonnet-4-5-20250929"
)
```

#### temperature

Control response randomness (0.0 to 1.0).

```python
options = ClaudeAgentOptions(
    temperature=0.7  # Default: balanced creativity/consistency
)
```

**Values:**
- `0.0` - Deterministic, focused
- `0.5` - Balanced
- `1.0` - Creative, varied

#### max_tokens

Limit response length.

```python
options = ClaudeAgentOptions(
    max_tokens=4096
)
```

### Complete Example

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def advanced_query():
    options = ClaudeAgentOptions(
        system_prompt="Expert Python developer focusing on clean code",
        allowed_tools=["Read", "Write", "Edit"],
        permission_mode="acceptEdits",
        cwd="/home/user/project",
        model="claude-sonnet-4-5-20250929",
        temperature=0.3,
        max_tokens=8192
    )

    async for msg in query(
        prompt="Refactor main.py to improve readability",
        options=options
    ):
        print(msg)

asyncio.run(advanced_query())
```

## Advanced Patterns

### 1. Streaming with Progress

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions
from rich.progress import Progress, SpinnerColumn, TextColumn

async def query_with_progress(prompt: str):
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
    ) as progress:
        task = progress.add_task("Querying Claude...", total=None)

        result = []
        async for msg in query(prompt=prompt):
            result.append(msg)
            if msg.get("type") == "text":
                progress.update(task, description=msg["text"][:50])

        progress.update(task, description="Complete!", completed=True)
        return result

messages = asyncio.run(query_with_progress("Explain async/await"))
```

### 2. Multi-Turn Conversations

```python
import asyncio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def conversation():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Write"],
        permission_mode="acceptEdits"
    )

    async with ClaudeSDKClient(options=options) as client:
        # Turn 1
        await client.query("Create a Python script called test.py")
        async for msg in client.receive_response():
            print("Turn 1:", msg)

        # Turn 2 (context preserved)
        await client.query("Now add a main() function to test.py")
        async for msg in client.receive_response():
            print("Turn 2:", msg)

        # Turn 3
        await client.query("Add error handling")
        async for msg in client.receive_response():
            print("Turn 3:", msg)

asyncio.run(conversation())
```

### 3. Error Recovery

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def query_with_retry(prompt: str, max_retries: int = 3):
    for attempt in range(max_retries):
        try:
            result = []
            async for msg in query(prompt=prompt):
                result.append(msg)
            return result
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            print(f"Attempt {attempt + 1} failed: {e}")
            await asyncio.sleep(2 ** attempt)  # Exponential backoff

messages = asyncio.run(query_with_retry("Complex query here"))
```

### 4. Batch Processing

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def process_files(files: list[str]):
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Edit"],
        permission_mode="acceptEdits"
    )

    tasks = []
    for file in files:
        async def process_file(f=file):
            result = []
            async for msg in query(
                prompt=f"Add type hints to {f}",
                options=options
            ):
                result.append(msg)
            return f, result

        tasks.append(process_file())

    results = await asyncio.gather(*tasks)
    return dict(results)

files = ["app.py", "utils.py", "models.py"]
results = asyncio.run(process_files(files))
```

### 5. Custom Output Processing

```python
import asyncio
from claude_agent_sdk import query
import json

async def extract_json_response(prompt: str):
    """Query Claude and extract JSON from response"""
    full_text = []

    async for msg in query(prompt=prompt):
        if msg.get("type") == "text":
            full_text.append(msg["text"])

    response = "".join(full_text)

    # Extract JSON (simple approach)
    start = response.find("{")
    end = response.rfind("}") + 1

    if start != -1 and end > start:
        json_str = response[start:end]
        return json.loads(json_str)

    return None

# Use it
result = asyncio.run(extract_json_response(
    "Analyze test.py and return a JSON with: lines, functions, classes"
))
print(result)
```

### 6. Context Management

```python
import asyncio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

class ClaudeSession:
    def __init__(self, system_prompt: str = None):
        self.options = ClaudeAgentOptions(
            system_prompt=system_prompt,
            allowed_tools=["Read", "Write", "Edit"],
            permission_mode="acceptEdits"
        )
        self.client = None

    async def __aenter__(self):
        self.client = ClaudeSDKClient(options=self.options)
        await self.client.__aenter__()
        return self

    async def __aexit__(self, *args):
        await self.client.__aexit__(*args)

    async def query(self, prompt: str):
        await self.client.query(prompt)
        result = []
        async for msg in self.client.receive_response():
            result.append(msg)
        return result

# Use it
async def main():
    async with ClaudeSession("Expert Python developer") as session:
        response1 = await session.query("Create utils.py with helper functions")
        response2 = await session.query("Add unit tests for utils.py")
        return response1, response2

asyncio.run(main())
```

## Error Handling

### Common Exceptions

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions
from claude_agent_sdk.exceptions import (
    ClaudeAPIError,
    AuthenticationError,
    RateLimitError,
    InvalidRequestError
)

async def safe_query(prompt: str):
    try:
        async for msg in query(prompt=prompt):
            print(msg)

    except AuthenticationError:
        print("Authentication failed - check API key")

    except RateLimitError:
        print("Rate limit exceeded - wait before retry")

    except InvalidRequestError as e:
        print(f"Invalid request: {e}")

    except ClaudeAPIError as e:
        print(f"API error: {e}")

    except Exception as e:
        print(f"Unexpected error: {e}")

asyncio.run(safe_query("Your prompt"))
```

### Timeout Handling

```python
import asyncio
from claude_agent_sdk import query

async def query_with_timeout(prompt: str, timeout: int = 60):
    try:
        result = []

        async def collect_responses():
            async for msg in query(prompt=prompt):
                result.append(msg)

        await asyncio.wait_for(collect_responses(), timeout=timeout)
        return result

    except asyncio.TimeoutError:
        print(f"Query timed out after {timeout} seconds")
        return result  # Return partial results

asyncio.run(query_with_timeout("Complex analysis task", timeout=120))
```

## Best Practices

### 1. Always Use Async Context Managers

**✓ Good:**
```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("...")
```

**✗ Bad:**
```python
client = ClaudeSDKClient(options=options)
await client.query("...")
# Client not properly closed
```

### 2. Handle Streaming Responses Properly

**✓ Good:**
```python
result = []
async for msg in query(prompt="..."):
    result.append(msg)
    # Process incrementally
```

**✗ Bad:**
```python
# Blocking wait for all responses
result = list(query(prompt="..."))  # Won't work with async
```

### 3. Limit Tool Permissions

**✓ Good:**
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read"],  # Only what's needed
    permission_mode="ask"
)
```

**✗ Bad:**
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Edit", "Bash"],
    permission_mode="acceptAll"  # Too permissive
)
```

### 4. Use System Prompts for Consistency

**✓ Good:**
```python
options = ClaudeAgentOptions(
    system_prompt="Expert Python developer. Always include docstrings."
)
```

**✗ Bad:**
```python
# Relying on prompt alone - inconsistent results
async for msg in query("Write code and include docstrings"):
    ...
```

### 5. Validate Custom Tool Inputs

**✓ Good:**
```python
@tool("process", "Process data", {"value": int})
async def process(args: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(args.get("value"), int):
        return {"error": "Invalid input type"}

    if args["value"] < 0:
        return {"error": "Value must be positive"}

    # Process...
```

**✗ Bad:**
```python
@tool("process", "Process data", {"value": int})
async def process(args: dict[str, Any]) -> dict[str, Any]:
    # No validation - assumes correct input
    result = expensive_operation(args["value"])
```

### 6. Set Appropriate Working Directories

**✓ Good:**
```python
options = ClaudeAgentOptions(
    cwd="/specific/project/path"
)
```

**✗ Bad:**
```python
# Using default cwd - may affect wrong files
options = ClaudeAgentOptions()
```

### 7. Use Rich for Better Output

```python
from rich import print as rprint
from rich.syntax import Syntax

async for msg in query(prompt="Generate Python code"):
    if msg.get("type") == "text":
        syntax = Syntax(msg["text"], "python", theme="monokai")
        rprint(syntax)
```

## Testing SDK Applications

### Unit Testing

```python
import pytest
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

@pytest.mark.asyncio
async def test_basic_query():
    result = []
    async for msg in query(prompt="What is 2+2?"):
        result.append(msg)

    assert len(result) > 0
    assert any("4" in str(msg) for msg in result)

@pytest.mark.asyncio
async def test_with_options():
    options = ClaudeAgentOptions(
        allowed_tools=["Read"],
        permission_mode="acceptEdits"
    )

    result = []
    async for msg in query(prompt="List files", options=options):
        result.append(msg)

    assert len(result) > 0
```

### Integration Testing

```python
import pytest
import asyncio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions
import tempfile
import os

@pytest.mark.asyncio
async def test_file_creation():
    with tempfile.TemporaryDirectory() as tmpdir:
        options = ClaudeAgentOptions(
            allowed_tools=["Write"],
            permission_mode="acceptEdits",
            cwd=tmpdir
        )

        async with ClaudeSDKClient(options=options) as client:
            await client.query("Create test.txt with 'hello'")
            async for msg in client.receive_response():
                pass

        assert os.path.exists(os.path.join(tmpdir, "test.txt"))
        with open(os.path.join(tmpdir, "test.txt")) as f:
            assert "hello" in f.read()
```

## Performance Considerations

### Response Streaming

Stream responses for better UX:
```python
async for msg in query(prompt="Long analysis task"):
    print(msg, end='', flush=True)  # Show progress
```

### Concurrent Queries

Process multiple queries in parallel:
```python
async def process_many(prompts: list[str]):
    async def single_query(prompt):
        result = []
        async for msg in query(prompt=prompt):
            result.append(msg)
        return result

    tasks = [single_query(p) for p in prompts]
    return await asyncio.gather(*tasks)
```

### Memory Management

For large responses:
```python
async def stream_to_file(prompt: str, output_file: str):
    with open(output_file, 'w') as f:
        async for msg in query(prompt=prompt):
            if msg.get("type") == "text":
                f.write(msg["text"])
                f.flush()  # Don't buffer in memory
```

## See Also

- [Claude Agent SDK Documentation](https://github.com/anthropics/claude-agent-sdk)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
- [claude.x wrapper](./claude.x.md) - CLI usage
- [Main README](../README.md) - Project overview

---

**Last Updated:** 2025-10-19

#fin
