import asyncio
from claude_agent_sdk import query

async def main():
    async for message in query(prompt="Hello, how are you?"):
        print(message)
        
asyncio.run(main())
