-- Replace the standard tech to unlock our own transceiver instead of the default one:
data:extend(
{
	{
		type = "technology",
		name = "kr-intergalactic-transceiver",
		mod = "Krastorio2",
		icon = "__Krastorio2__/graphics/technologies/intergalactic-transceiver.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",			
				recipe = "kee-intergalactic-transceiver-loading"
			}
		},
		prerequisites = {"kr-imersium-processing", "kr-energy-control-unit", "kr-singularity-tech-card"},
		unit =
		{
			count = 3000,
			ingredients = 
			{
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"space-science-pack", 1},
				{"matter-tech-card", 1},
				{"advanced-tech-card", 1},
				{"singularity-tech-card", 1}
			},
			time = 60
		}
    }
})
