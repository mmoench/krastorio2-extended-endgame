data:extend({
	{
		type = "int-setting",
		name = "kee-activations",
		setting_type = "startup",
		default_value = 10,
		order = "a",
        allowed_values = {5,10,25}
    },
	{
		type = "int-setting",
		name = "kee-initial-need-space-research",
		setting_type = "startup",
		default_value = 250,
		order = "a",
        allowed_values = {100,250,500,1000,2000}
	},
	{
		type = "int-setting",
		name = "kee-initial-need-matter-research",
		setting_type = "startup",
		default_value = 1000,
		order = "a",
        allowed_values = {100,250,500,1000,2000}
	},
	{
		type = "int-setting",
		name = "kee-initial-need-advanced-research",
		setting_type = "startup",
		default_value = 1000,
		order = "a",
        allowed_values = {100,250,500,1000,2000}
	},
	{
		type = "int-setting",
		name = "kee-initial-need-singularity-research",
		setting_type = "startup",
		default_value = 1000,
		order = "a",
        allowed_values = {100,250,500,1000,2000}
	},
})
