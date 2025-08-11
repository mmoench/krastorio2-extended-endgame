local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds = require("__base__/prototypes/entity/sounds")

local picture = {
  layers = {
    {
      filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver-light.png",
      width = 800,
      height = 800,
      scale = 0.5,
      frame_count = 1,
      shift = { 0, -0.8 },
      draw_as_light = true,
    },
    {
      filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver.png",
      width = 800,
      height = 800,
      scale = 0.5,
      frame_count = 1,
      shift = { 0, -0.8 },
    },
    {
      filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver-sh.png",
      width = 867,
      height = 626,
      scale = 0.5,
      frame_count = 1,
      draw_as_shadow = true,
      shift = { 0.52, 0.5 },
    },
  },
}

local animation = {
  layers = {
    {
      filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver.png",
      width = 800,
      height = 800,
      scale = 0.5,
      frame_count = 1,
      repeat_count = 60,
      animation_speed = 0.3447,
      shift = { 0, -0.8 },
    },
    {
      filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver-sh.png",
      priority = "low",
      width = 867,
      height = 626,
      scale = 0.5,
      frame_count = 1,
      repeat_count = 60,
      draw_as_shadow = true,
      animation_speed = 0.3447,
      shift = { 0.52, 0.5 },
    },
    {
      filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver-charging.png",
      priority = "high",
      width = 800,
      height = 800,
      scale = 0.5,
      frame_count = 60,
      line_length = 10,
      animation_speed = 0.3447,
      shift = { 0, -0.8 },
      draw_as_glow = true,
    },
    {
      filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver-light.png",
      priority = "high",
      width = 800,
      height = 800,
      scale = 0.5,
      frame_count = 1,
      repeat_count = 60,
      animation_speed = 0.3447,
      shift = { 0, -0.8 },
      draw_as_light = true,
    },
    {
      filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver-charging-light.png",
      priority = "high",
      width = 800,
      height = 800,
      scale = 0.5,
      frame_count = 60,
      line_length = 10,
      animation_speed = 0.3447,
      shift = { 0, -0.8 },
      draw_as_light = true,
    },
  },
}

local working_sound = {
  sound = {
    variations = {
      {
        filename = "__Krastorio2Assets__/sounds/buildings/intergalactic-transceiver-charge.ogg",
        volume = 1,
      },
      {
        filename = "__Krastorio2Assets__/sounds/buildings/intergalactic-transceiver-charge.ogg",
        volume = 1,
      },
      {
        filename = "__Krastorio2Assets__/sounds/buildings/intergalactic-transceiver-charge-morse.ogg",
        volume = 1,
      },
    },
  },
  idle_sound = {
    filename = "__Krastorio2Assets__/sounds/buildings/intergalactic-transceiver.ogg",
    volume = 1,
  },
  max_sounds_per_prototype = 3,
  fade_in_ticks = 10,
  fade_out_ticks = 30,
}


data:extend(
  {
    {
      type = "recipe",
      name = "kee-intergalactic-transceiver-loading",
      energy_required = 1800,
      enabled = false,
      ingredients =
      {
        { type = "item", name = "kr-imersium-beam",       amount = 500 },
        { type = "item", name = "kr-imersium-plate",      amount = 500 },
        { type = "item", name = "kr-rare-metals",         amount = 1000 },
        { type = "item", name = "kr-energy-control-unit", amount = 500 },
        { type = "item", name = "kr-ai-core",             amount = 300 },
        { type = "item", name = "concrete",               amount = 750 }
      },
      results = { { type = "item", name = "kee-intergalactic-transceiver-loading", amount = 1 } }
    }
  })

data:extend(
  {
    {
      type = "item",
      name = "kee-intergalactic-transceiver-loading",
      icon = "__Krastorio2Assets__/icons/entities/intergalactic-transceiver.png",
      icon_size = 64,
      subgroup = "kr-radar",
      order = "zzzz[intergalactic-transceiver]",
      place_result = "kee-intergalactic-transceiver-loading",
      stack_size = 1
    }
  })


-- Use the default gate open sound, just louder:
local gate_open_sound = {}
for _, sound in pairs(sounds.gate_open.variations) do
  table.insert(gate_open_sound, { filename = sound.filename, volume = 1 })
end
local gate_close_sound = {}
for _, sound in pairs(sounds.gate_close.variations) do
  table.insert(gate_close_sound, { filename = sound.filename, volume = 1 })
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
      flags = { "placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable" },
      order = "y",
      max_health = 10000,
      healing_per_tick = 10000,
      corpse = "small-remnants",
      collision_box = { { -0.0, -0.0 }, { 0.0, 0.0 } },
      selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
      selectable_in_game = false,
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
        { 0, 0 },
        { 0, 0 },
        { 0, 0 },
        { 0, 0 }
      },
      circuit_wire_connection_points = {
        {
          shadow = { red = { 0, 0 }, green = { 0, 0 }, },
          wire = { red = { 0, 0 }, green = { 0, 0 }, }
        },
        {
          shadow = { red = { 0, 0 }, green = { 0, 0 }, },
          wire = { red = { 0, 0 }, green = { 0, 0 }, }
        },
        {
          shadow = { red = { 0, 0 }, green = { 0, 0 }, },
          wire = { red = { 0, 0 }, green = { 0, 0 }, }
        },
        {
          shadow = { red = { 0, 0 }, green = { 0, 0 }, },
          wire = { red = { 0, 0 }, green = { 0, 0 }, }
        }
      },
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
      flags = { "placeable-neutral", "placeable-player", "player-creation", "not-rotatable" },
      map_color = { r = 0.37, g = 0.18, b = 0.47 },
      max_health = 20000,
      minable = { mining_time = 10, result = "kee-intergalactic-transceiver-loading" },
      corpse = "kr-big-random-pipes-remnants",
      dying_explosion = "massive-explosion",
      damaged_trigger_effect = hit_effects.entity(),
      collision_box = { { -5.75, -5.25 }, { 5.75, 5.25 } },
      selection_box = { { -6, -5.5 }, { 6, 5.5 } },
      drawing_box = { { -5.75, -5.25 }, { 5.75, 5.25 } },
      resistances =
      {
        { type = "physical", percent = 75 },
        { type = "fire",     percent = 75 },
        { type = "impact",   percent = 75 }
      },
      picture =
      {
        layers =
        {
          {
            filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver.png",
            width = 800,
            height = 800,
            scale = 0.5,
            frame_count = 1,
            shift = { 0, -0.8 }
          },
          {
            filename = "__Krastorio2Assets__/buildings/intergalactic-transceiver/intergalactic-transceiver-sh.png",
            width = 867,
            height = 626,
            scale = 0.5,
            frame_count = 1,
            draw_as_shadow = true,
            shift = { 0.52, 0.5 }
          }

        }
      },
      vehicle_impact_sound = sounds.generic_impact,
      circuit_connector = {
        spirtes = nil,
        points = {
          shadow =
          {
            red = { 4.3, 2.45 },
            green = { 4.3, 2.45 },
          },
          wire =
          {
            red = { 4.3, 2.45 },
            green = { 4.3, 2.45 },
          }
        },
      },
      circuit_wire_max_distance = default_circuit_wire_max_distance,
      default_output_signal = { type = "virtual", name = "signal-I" }
    },
    -- Test-fire stage:
    {
      type = "accumulator",
      name = "kee-intergalactic-transceiver-test-fire",
      order = "b",
      icon = "__Krastorio2Assets__/icons/entities/intergalactic-transceiver.png",
      icon_size = 64,
      flags = { "placeable-neutral", "placeable-player", "player-creation", "not-rotatable" },
      map_color = { r = 0.37, g = 0.18, b = 0.47 },
      minable = { mining_time = 10, result = "kee-intergalactic-transceiver-loading" },
      collision_box = { { -5.75, -5.25 }, { 5.75, 5.25 } },
      selection_box = { { -6, -5.5 }, { 6, 5.5 } },
      drawing_box = { { -6, -6.5 }, { 6, 4.5 } },
      max_health = 20000,
      corpse = "kr-big-random-pipes-remnants",
      dying_explosion = "nuclear-reactor-explosion",
      damaged_trigger_effect = hit_effects.entity(),
      resistances = {
        { type = "physical", percent = 75 },
        { type = "fire",     percent = 75 },
        { type = "impact",   percent = 75 },
      },
      energy_source = {
        type = "electric",
        buffer_capacity = "30TJ",
        usage_priority = "tertiary",
        input_flow_limit = "60GW",
        output_flow_limit = "0W",
      },
      open_sound = sounds.machine_open,
      close_sound = sounds.machine_close,
      vehicle_impact_sound = sounds.generic_impact,
      working_sound = working_sound,
      default_output_signal = { type = "virtual", name = "signal-I" },
      chargable_graphics = {
        picture = picture,
        charge_animation = animation,
        charge_cooldown = 240,
        charge_light = {
          intensity = 0.75,
          size = 20,
          shift = { 0, -0.5 },
          color = { r = 1, g = 0.2, b = 1 },
        },
        discharge_animation = animation,
        discharge_cooldown = 240,
      },
      circuit_connector = {
        spirtes = nil,
        points = {
          shadow =
          {
            red = { 4.3, 2.45 },
            green = { 4.3, 2.45 },
          },
          wire =
          {
            red = { 4.3, 2.45 },
            green = { 4.3, 2.45 },
          }
        },
      },
      circuit_wire_max_distance = default_circuit_wire_max_distance,
    }
  })