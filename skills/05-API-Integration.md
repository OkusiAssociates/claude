# Claude Skills - API Integration

**Last Updated:** October 19, 2025

---

## ◉ Overview

Claude Skills integrate with the Messages API through the **code execution tool**. Skills execute in isolated containers and can be specified programmatically in API requests.

---

## ◉ Basic API Usage

### Enabling Code Execution

Skills require the code execution tool:

```python
import anthropic

client = anthropic.Anthropic(api_key="your-api-key")

response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    max_tokens=4096,
    tools=[
        {"type": "code_execution"}
    ],
    messages=[
        {"role": "user", "content": "Your request"}
    ]
)
```

### Using Skills

Specify skills in the `container` parameter:

```python
response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    tools=[{"type": "code_execution"}],
    container={
        "skills": [
            {
                "type": "skill",
                "skill_id": "powerpoint",
                "version": "1.0"
            }
        ]
    },
    messages=[
        {"role": "user", "content": "Create a presentation about Q3 results"}
    ]
)
```

---

## ◉ Multiple Skills

Include up to **8 skills per request**:

```python
container={
    "skills": [
        {"type": "skill", "skill_id": "brand-guidelines", "version": "1.0"},
        {"type": "skill", "skill_id": "powerpoint", "version": "1.5"},
        {"type": "skill", "skill_id": "financial-reporting", "version": "2.0"}
    ]
}
```

Skills automatically compose - Claude coordinates their use.

---

## ◉ Skill Management API

### Upload Skill

```python
# Upload custom skill
response = client.skills.create(
    name="custom-skill",
    description="Skill description",
    content=skill_content  # SKILL.md contents
)

skill_id = response.id
print(f"Skill ID: {skill_id}")
```

### List Skills

```python
# List available skills
skills = client.skills.list()

for skill in skills.data:
    print(f"{skill.id}: {skill.name}")
```

### Update Skill

```python
# Update existing skill
client.skills.update(
    skill_id="skill-abc123",
    content=new_content
)
```

### Delete Skill

```python
# Delete skill
client.skills.delete(skill_id="skill-abc123")
```

---

## ◉ Version Control

Specify skill versions:

```python
container={
    "skills": [
        {
            "type": "skill",
            "skill_id": "my-skill",
            "version": "2.1.0"  # Specific version
        },
        {
            "type": "skill",
            "skill_id": "other-skill"
            # Omit version = latest
        }
    ]
}
```

---

## ◉ Error Handling

```python
try:
    response = client.messages.create(
        model="claude-3-5-sonnet-20241022",
        tools=[{"type": "code_execution"}],
        container={
            "skills": [
                {"type": "skill", "skill_id": "my-skill"}
            ]
        },
        messages=[{"role": "user", "content": "Request"}]
    )
except anthropic.SkillNotFoundError:
    print("Skill not found")
except anthropic.SkillLoadError:
    print("Skill failed to load")
except Exception as e:
    print(f"Error: {e}")
```

---

## ◉ Complete Example

```python
#!/usr/bin/env python3
"""Complete skill API usage example."""

import anthropic
import os

def create_branded_presentation(topic: str) -> str:
    """Create branded presentation using skills."""

    client = anthropic.Anthropic(
        api_key=os.environ.get("ANTHROPIC_API_KEY")
    )

    try:
        response = client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=4096,
            tools=[{"type": "code_execution"}],
            tool_choice={"type": "any", "name": "code_execution"},
            container={
                "skills": [
                    {
                        "type": "skill",
                        "skill_id": "brand-guidelines",
                        "version": "1.0"
                    },
                    {
                        "type": "skill",
                        "skill_id": "powerpoint",
                        "version": "1.5"
                    }
                ]
            },
            messages=[
                {
                    "role": "user",
                    "content": f"Create a branded PowerPoint presentation about {topic}"
                }
            ]
        )

        # Extract result
        return response.content[0].text

    except Exception as e:
        return f"Error: {e}"


if __name__ == "__main__":
    result = create_branded_presentation("Q3 Financial Results")
    print(result)

#fin
```

---

## ◉ Best Practices

### DO:

- ✓ Use specific skill versions for production
- ✓ Handle skill loading errors gracefully
- ✓ Test skills before deploying to production
- ✓ Monitor skill usage and performance
- ✓ Limit to 8 skills per request

### DON'T:

- ✗ Exceed 8 skills per request
- ✗ Omit code execution tool
- ✗ Use untested skill versions in production
- ✗ Hard-code skill IDs (use config)

---

**Navigation:**
- [← Back to Installation](04-Installation-Setup.md)
- [Next: Best Practices →](06-Best-Practices.md)

#fin
