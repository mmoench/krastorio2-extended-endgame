local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds      = require("__base__/prototypes/entity/sounds")

data:extend(
{
  {
    type = "recipe",
    name = "kee-intergalactic-transceiver-loading",
    energy_required = 1800,
    enabled = false,
    ingredients =
    {
        {"imersium-beam", 500},
        {"imersium-plate", 500},
        {"rare-metals", 1000},
        {"energy-control-unit", 500},
        {"ai-core", 300},
        {"concrete", 750}
    },
    result = "kee-intergalactic-transceiver-loading"
  }
})

data:extend(
{
	{
		type = "item",
		name = "kee-intergalactic-transceiver-loading",
		icon = "__Krastorio2Assets__/icons/entities/intergalactic-transceiver.png",
		icon_size = 64,
		subgroup = "radars-and-rockets",
		order = "zzz[rocket-silo]-zzzz[intergalactic-transceiver]",
		place_result = "kee-intergalactic-transceiver-loading",
		stack_size = 1
	}
})

local intergalactic_transceiver_animation = 
{
	layers =
	{
		{
			filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/intergalactic-transceiver.png",
			width = 400,
			height = 400,
			frame_count = 1,
			repeat_count = 60,
			shift = {0, -0.8},
			animation_speed = 0.3447,
			hr_version =
			{
				filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/hr-intergalactic-transceiver.png",
				width = 800,
				height = 800,
				scale = 0.5,
				frame_count = 1,
				repeat_count = 60,
				animation_speed=0.3447,
				shift = {0, -0.8}
			}
		},
		{
			filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/intergalactic-transceiver-sh.png",
			width = 434,
			height = 313,
			frame_count = 1,
			repeat_count = 60,
			draw_as_shadow = true,
			animation_speed = 0.3447,
			shift = {0.52, 0.5},
			hr_version =
			{
				filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/hr-intergalactic-transceiver-sh.png",
				width = 867,
				height = 626,
				scale = 0.5,
				frame_count = 1,
				repeat_count = 60,
				draw_as_shadow = true,
				animation_speed=0.3447,
				shift = {0.52, 0.5}
			}
		},
		{
			filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/intergalactic-transceiver-charge.png",
			width = 400,
			height = 400,
			frame_count = 60,
			line_length = 10,
			animation_speed = 0.3447,
			shift = {0, -0.8},
			hr_version =
			{
				filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/hr-intergalactic-transceiver-charge.png",
				width = 800,
				height = 800,
				scale = 0.5,
				frame_count = 60,
				line_length = 10,
				animation_speed = 0.3447,
				shift = {0, -0.8}
			}
		}
	}
}

local intergalactic_transceiver_working_sound =
{
	sound =
	{
		variations =
		{
			{
				filename = "__Krastorio2Assets__/sounds/buildings/intergalactic-transceiver-charge.ogg",
				volume = 1.5
			},
			{
				filename = "__Krastorio2Assets__/sounds/buildings/intergalactic-transceiver-charge.ogg",
				volume = 1.5
			},
			{
				filename = "__Krastorio2Assets__/sounds/buildings/intergalactic-transceiver-charge-morse.ogg",
				volume = 1.5
			}
		}
	},
	idle_sound =
	{
		filename = "__Krastorio2Assets__/sounds/buildings/intergalactic-transceiver.ogg",
		volume = 1
	},
	max_sounds_per_type = 3,
	fade_in_ticks = 10,
	fade_out_ticks = 30
}

-- Use the default gate oepn sound, just louder:
local gate_open_sound = {}
for _, sound in pairs(sounds.gate_open) do
	table.insert(gate_open_sound, {filename=sound.filename, volume=1})
end
local gate_close_sound = {}
for _, sound in pairs(sounds.gate_close) do
	table.insert(gate_close_sound, {filename=sound.filename, volume=1})
end

local blank_image = {
  filename = "__krastorio2_extended_endgame__/graphics/blank.png",
  width = 1,
  height = 1,
  frame_count = 1,
  line_length = 1,
  shift = { 0, 0 },
}

data:extend(
{
  -- Invisible combinator used to create custom signals:
  {
    type = "constant-combinator",
    name = "kee-intergalactic-transceiver-combinator",
    icon = "__Krastorio2Assets__/icons/entities/intergalactic-transceiver.png",
    icon_size = 64,
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable"},
    order = "y",
    max_health = 10000,
    healing_per_tick = 10000,
    corpse = "small-remnants",
    collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
    collision_mask = {"not-colliding-with-itself"},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    scale_info_icons = false,
    selectable_in_game = selectable,
    item_slot_count = 10,
    sprites =
    {
        north = blank_image,
        east = blank_image,
        south = blank_image,
        west = blank_image
    },
    activity_led_sprites =
    {
        north = blank_image,
        east = blank_image,
        south = blank_image,
        west = blank_image
    },
    activity_led_light =
    {
        intensity = 0.8,
        size = 1,
    },
    activity_led_light_offsets =
    {
        {0, 0},
        {0, 0},
        {0, 0},
        {0, 0}
    },
    circuit_wire_connection_points = {
      {
        shadow = { red = {0, 0}, green = {0, 0}, },
        wire = { red = {0, 0}, green = {0, 0}, }
      },
      {
        shadow = { red = {0, 0}, green = {0, 0}, },
        wire = { red = {0, 0}, green = {0, 0}, }
      },
      {
        shadow = { red = {0, 0}, green = {0, 0}, },
        wire = { red = {0, 0}, green = {0, 0}, }
      },
      {
        shadow = { red = {0, 0}, green = {0, 0}, },
        wire = { red = {0, 0}, green = {0, 0}, }
      }
    },
    circuit_connector_sprites = nil,
    circuit_wire_max_distance = 10
  },  
  -- Loading stage before test-fire:
  {
    type = "container",
    name = "kee-intergalactic-transceiver-loading",
    order = "a",
    inventory_size = 80,
    open_sound = gate_open_sound,
    close_sound = gate_close_sound,

    icon = "__Krastorio2Assets__/icons/entities/intergalactic-transceiver.png",
    icon_size = 64,
    flags = {"placeable-neutral","placeable-player", "player-creation", "not-rotatable"},
    map_color = {r=0.37, g=0.18, b=0.47},
    max_health = 20000,
    minable = {mining_time = 10, result = "kee-intergalactic-transceiver-loading"},
    corpse = "kr-big-random-pipes-remnant",
    dying_explosion = "massive-explosion",
    damaged_trigger_effect = hit_effects.entity(),
    collision_box = {{-5.75, -5.25}, {5.75, 5.25}},
    selection_box = {{-6, -5.5}, {6, 5.5}},
    drawing_box = {{-5.75, -5.25}, {5.75, 5.25}},
    resistances = 
    {
      {type = "physical", percent = 75},
      {type = "fire", percent = 75},
      {type = "impact", percent = 75}
    },
    picture = 
    {
      layers=
      {
        {
          filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/intergalactic-transceiver.png",
          width = 400,
          height = 400,
          frame_count = 1,
          shift = {0, -0.8},
          hr_version =
          {
            filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/hr-intergalactic-transceiver.png",
            width = 800,
            height = 800,
            scale = 0.5,
            frame_count = 1,
            shift = {0, -0.8}
          }
        },
        {
          filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/intergalactic-transceiver-sh.png",
          width = 434,
          height = 313,
          frame_count = 1,
          draw_as_shadow = true,
          shift = {0.52, 0.5},
          hr_version =
          {
            filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/hr-intergalactic-transceiver-sh.png",
            width = 867,
            height = 626,
            scale = 0.5,
            frame_count = 1,
            draw_as_shadow = true,
            shift = {0.52, 0.5}
          }
        }
      
      }
    },
    vehicle_impact_sound = sounds.generic_impact,
    circuit_wire_connection_point = {
      shadow =
      {
          red = {4.3, 2.45},
          green = {4.3, 2.45},
      },
      wire =
      {
          red = {4.3, 2.45},
          green = {4.3, 2.45},
      }
    },
    circuit_connector_sprites = nil,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    default_output_signal = {type = "virtual", name = "signal-I"}
  },
	-- Test-fire stage:
	{
		type = "accumulator",
		name = "kee-intergalactic-transceiver-test-fire",
		order = "b",
		icon = "__Krastorio2Assets__/icons/entities/intergalactic-transceiver.png",
		icon_size = 64,
		flags = {"placeable-neutral","placeable-player", "player-creation", "not-rotatable"},
		map_color = {r=0.37, g=0.18, b=0.47},
		max_health = 20000,
		minable = {mining_time = 10, result = "kee-intergalactic-transceiver-loading"},
		corpse = "kr-big-random-pipes-remnant",
		dying_explosion = "nuclear-reactor-explosion",
		damaged_trigger_effect = hit_effects.entity(),
		collision_box = {{-5.75, -5.25}, {5.75, 5.25}},
		selection_box = {{-6, -5.5}, {6, 5.5}},
		drawing_box = {{-5.75, -5.25}, {5.75, 5.25}},
		resistances = 
		{
			{type = "physical", percent = 75},
			{type = "fire", percent = 75},
			{type = "impact", percent = 75}
		},
		energy_source =
		{
			type = "electric",
			buffer_capacity = "30TJ",
			usage_priority = "tertiary",
			input_flow_limit = "60GW",
			output_flow_limit = "0W"
		},
		picture = 
		{
			layers=
			{
				{
					filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/intergalactic-transceiver.png",
					width = 400,
					height = 400,
					frame_count = 1,
					shift = {0, -0.8},
					hr_version =
					{
						filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/hr-intergalactic-transceiver.png",
						width = 800,
						height = 800,
						scale = 0.5,
						frame_count = 1,
						shift = {0, -0.8}
					}
				},
				{
					filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/intergalactic-transceiver-sh.png",
					width = 434,
					height = 313,
					frame_count = 1,
					draw_as_shadow = true,
					shift = {0.52, 0.5},
					hr_version =
					{
						filename = "__Krastorio2Assets__/entities/intergalactic-transceiver/hr-intergalactic-transceiver-sh.png",
						width = 867,
						height = 626,
						scale = 0.5,
						frame_count = 1,
						draw_as_shadow = true,
						shift = {0.52, 0.5}
					}
				}
			
			}
		},
		charge_animation = intergalactic_transceiver_animation,
		discharge_animation = intergalactic_transceiver_animation,
		charge_cooldown = 240,
		discharge_cooldown = 240,
		charge_light =
		{
			intensity = 1.5,
			size = 50,
			shift = {0, 0},
			color = {r=1, g=0.5, b=0.75}
		},
		vehicle_impact_sound = sounds.generic_impact,
		working_sound = intergalactic_transceiver_working_sound,
    audible_distance_modifier = 30,
    
    circuit_wire_connection_point = {
      shadow =
      {
          red = {4.3, 2.45},
          green = {4.3, 2.45},
      },
      wire =
      {
          red = {4.3, 2.45},
          green = {4.3, 2.45},
      }
    },
    circuit_connector_sprites = nil,
    circuit_wire_max_distance = default_circuit_wire_max_distance,

		default_output_signal = {type = "virtual", name = "signal-I"}
	}  
})
