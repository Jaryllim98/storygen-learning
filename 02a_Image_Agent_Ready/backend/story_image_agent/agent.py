
import json
from google.adk.agents import Agent, BaseAgent, InvocationContext
from google.adk.agents.events import Event
from story_image_agent.imagen_tool import ImagenTool

class CustomImageAgent(BaseAgent):
  """A custom agent for generating images directly using ImagenTool."""
  _agent_name = "custom_image_agent"

  def __init__(self, llm, imagen_tool: ImagenTool):
    super().__init__(llm=llm)
    self.imagen_tool = imagen_tool

  async def _run_async_impl(
      self, ctx: InvocationContext
  ) -> AsyncGenerator[Event, None]:
    """Directly calls ImagenTool to generate images based on scene and character descriptions."""
    if not ctx.user_content or not ctx.user_content.parts:
        ctx.session.state["image_result"] = {
            "status": "error",
            "message": "No input provided.",
        }
        yield Event(
            type="result",
            data={"output": json.dumps(ctx.session.state["image_result"])},
        )
        return

    user_message = ctx.user_content.parts[0].text
    try:
        # Try to parse the input as JSON
        input_data = json.loads(user_message)
        scene_description = input_data.get("scene_description", "")
        character_descriptions = input_data.get("character_descriptions", {})
    except json.JSONDecodeError:
        # Fallback to plain text if JSON parsing fails
        scene_description = user_message
        character_descriptions = {}

    # Construct the prompt
    style_prefix = "Children's book cartoon illustration with bright vibrant colors, simple shapes, friendly characters."
    character_details = ", ".join(
        f"{name}: {desc}" for name, desc in character_descriptions.items()
    )
    
    prompt = f"{style_prefix} {scene_description}"
    if character_details:
        prompt += f" Featuring characters: {character_details}"

    try:
        # Directly call the ImagenTool
        image_result = await self.imagen_tool.run(prompt=prompt)
        
        # Assuming image_result is a dictionary with image URLs
        ctx.session.state["image_result"] = {
            "status": "success",
            "images": image_result,
        }
    except Exception as e:
        ctx.session.state["image_result"] = {
            "status": "error",
            "message": str(e),
        }

    yield Event(
        type="result",
        data={"output": json.dumps(ctx.session.state["image_result"])},
    )
