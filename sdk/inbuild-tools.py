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

