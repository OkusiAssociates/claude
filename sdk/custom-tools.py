import asyncio
from typing import Any
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, tool, create_sdk_mcp_server
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

