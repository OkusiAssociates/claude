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