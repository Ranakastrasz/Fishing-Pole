data:extend(
{
  {
    type = "technology",
    name = "fishing-pole",
    icon = "__Fishing Pole__/graphics/technology/fishing-pole.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "fishing-pole"
      },
    },
    --prerequisites = {"~~~"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"science-pack-1", 1}
      },
      time = 10
    },
    order = "e-a-f"
  }
})