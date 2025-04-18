-- Runs the first time this mod is initialized in a new game:
script.on_init(function()
  storage.kee_intergalactic_transceivers = {} -- list of all tracked transceiver-entities with the unit-number as key
  storage.kee_open_guis = {}                  -- List of all curryntly open guis
end)

-- This is called when a new Transceiver is created:
function on_entity_created(event)
  local entity
  if event.entity and event.entity.valid then
    entity = event.entity
  end
  if event.created_entity and event.created_entity.valid then
    entity = event.created_entity
  end
  if not entity then return end
  if entity.name == "kee-intergalactic-transceiver-loading" then -- Only the loading entity should get created by the player
    -- Initialize the new transceiver with the start-values:
    local struct = {
      entity                          = entity, -- the entity of the transceiver
      combinator                      = nil,    -- the entoty of the hidden combinator
      state                           = 'loading',
      completed_activations           = 0,

      -- Stores the current amount of ressources inserted into the "loading" entity:
      current_space_research_data     = 0,
      current_matter_tech_cards       = 0,
      current_advanced_tech_cards     = 0,
      current_singularity_tech_cards  = 0,

      -- Stores the amount of resources / charge needed for the next iteration:
      required_space_research_data    = 0,
      required_matter_tech_cards      = 0,
      required_advanced_tech_cards    = 0,
      required_singularity_tech_cards = 0,
      required_charge                 = 0,
    }
    storage.kee_intergalactic_transceivers = storage.kee_intergalactic_transceivers or {}
    storage.kee_intergalactic_transceivers[entity.unit_number] = struct

    calculate_current_needs(struct)
    create_combinator(struct) -- Attach hidden combinator
    update_combinator(struct)
  end
end

script.on_event(defines.events.on_built_entity, on_entity_created)
script.on_event(defines.events.on_robot_built_entity, on_entity_created)
script.on_event(defines.events.script_raised_built, on_entity_created)
script.on_event(defines.events.script_raised_revive, on_entity_created)

-- This is called when an existing Transceiver is removed (loading or fiering):
function on_entity_removed(event)
  local entity = event.entity
  if entity and entity.valid and entity.name == "kee-intergalactic-transceiver-loading" or entity.name == "kee-intergalactic-transceiver-test-fire" then
    if storage.kee_intergalactic_transceivers[entity.unit_number] ~= nil then
      if storage.kee_intergalactic_transceivers[entity.unit_number].combinator ~= nil then
        storage.kee_intergalactic_transceivers[entity.unit_number].combinator.destroy()
      end
      storage.kee_intergalactic_transceivers[entity.unit_number] = nil
    end
  end
end

script.on_event(defines.events.on_entity_died, on_entity_removed)
script.on_event(defines.events.on_robot_mined_entity, on_entity_removed)
script.on_event(defines.events.on_player_mined_entity, on_entity_removed)
script.on_event(defines.events.script_raised_destroy, on_entity_removed)

-- Creates a hidden combinator for the transceiver tracked by the given struct for our custom signals:
function create_combinator(struct)
  struct.combinator = struct.entity.surface.create_entity {
    name = "kee-intergalactic-transceiver-combinator",
    force = struct.entity.force,
    position = { struct.entity.position.x + 4.3, struct.entity.position.y + 2.45 } -- Place at the exact connection-point of the transceiver
  }
  local conn_red = struct.entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  conn_red.connect_to(
    struct.combinator.get_wire_connector(defines.wire_connector_id.circuit_red, true),
    false,
    defines.wire_origin.script
  )

  local conn_green = struct.entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)
  conn_green.connect_to(
    struct.combinator.get_wire_connector(defines.wire_connector_id.circuit_green, true),
    false,
    defines.wire_origin.script
  )

  struct.combinator.destructible = false
end

-- Copies all network connections (red & green wires) from one entity to another:
function copy_network_wires(source_entity, target_entity)
  for id, source_conn in pairs(source_entity.get_wire_connectors()) do
    local target_conn = target_entity.get_wire_connector(id, true)
    for _, wire_conn in pairs(source_conn.connections) do
      target_conn.connect_to(
        wire_conn.target,
        false,
        wire_conn.origin
      )
    end
  end
end

function calculate_resource_needs(initial_need, completed_activations)
  local total_need = initial_need
  local i = 0
  while i < completed_activations do
    total_need = total_need * 2
    i = i + 1
  end
  return total_need
end

function calculate_current_needs(struct)
  struct.required_space_research_data = calculate_resource_needs(
    settings.startup["kee-initial-need-space-research"].value, struct.completed_activations)
  struct.required_matter_tech_cards = calculate_resource_needs(
    settings.startup["kee-initial-need-matter-research"].value, struct.completed_activations)
  struct.required_advanced_tech_cards = calculate_resource_needs(
    settings.startup["kee-initial-need-advanced-research"].value, struct.completed_activations)
  struct.required_singularity_tech_cards = calculate_resource_needs(
    settings.startup["kee-initial-need-singularity-research"].value, struct.completed_activations)
  if struct.state == 'firing' then
    struct.required_charge = struct.entity.prototype.electric_energy_source_prototype.buffer_capacity *
        ((struct.completed_activations + 1.0) / settings.startup["kee-activations"].value)
  else
    struct.required_charge = 0
  end
end

function update_combinator(struct)
  if struct.combinator == nil then return end
  local comb = struct.combinator.get_or_create_control_behavior()
  local section = comb.get_section(1)
  section.filters = {
    {
      value = { type = "virtual", name = "signal-M", quality = "normal" },
      min = struct.required_matter_tech_cards - struct.current_matter_tech_cards
    },
    {
      value = { type = "virtual", name = "signal-A", quality = "normal" },
      min = struct.required_advanced_tech_cards - struct.current_advanced_tech_cards
    },
    {
      value = { type = "virtual", name = "signal-R", quality = "normal" },
      min = struct.required_space_research_data - struct.current_space_research_data
    },
    {
      value = { type = "virtual", name = "signal-S", quality = "normal" },
      min = struct.required_singularity_tech_cards - struct.current_singularity_tech_cards
    }
  }
  -- comb.set_signal(1, {signal={type = "virtual", name = "signal-M"}, count=struct.required_matter_tech_cards-struct.current_matter_tech_cards          })
  -- comb.set_signal(2, {signal={type = "virtual", name = "signal-A"}, count=struct.required_advanced_tech_cards-struct.current_advanced_tech_cards      })
  -- comb.set_signal(3, {signal={type = "virtual", name = "signal-R"}, count=struct.required_space_research_data-struct.current_space_research_data      })
  -- comb.set_signal(4, {signal={type = "virtual", name = "signal-S"}, count=struct.required_singularity_tech_cards-struct.current_singularity_tech_cards})
end

-- Periodic updates:
script.on_event(defines.events.on_tick, function(event)
  if game.tick % 20 ~= 0 then return end

  for index, struct in pairs(storage.kee_intergalactic_transceivers) do
    local transceiver_replaced = false

    if struct.entity and struct.entity.valid and struct.state == 'loading' then
      -- Take resources from the internal buffer and update the loading-process:
      local main_inv = struct.entity.get_inventory(defines.inventory.chest)
      local main_contents = main_inv.get_contents()
      local prod_statistic = struct.entity.force.get_item_production_statistics(struct.entity.surface)
      local contents_changed = false

      for _, inv_record in pairs(main_contents) do
        if inv_record.name == "kr-matter-tech-card" and inv_record.count > 0 then
          local take = math.min(inv_record.count,
            struct.required_matter_tech_cards - struct.current_matter_tech_cards)
          if take > 0 then
            main_inv.remove({ name = "kr-matter-tech-card", count = take })
            struct.current_matter_tech_cards = struct.current_matter_tech_cards + take
            prod_statistic.on_flow("kr-matter-tech-card", -1 * take)
            contents_changed = true
          end
        end
        if inv_record.name == "kr-advanced-tech-card" and inv_record.count > 0 then
          local take = math.min(inv_record.count,
            struct.required_advanced_tech_cards - struct.current_advanced_tech_cards)
          if take > 0 then
            main_inv.remove({ name = "kr-advanced-tech-card", count = take })
            struct.current_advanced_tech_cards = struct.current_advanced_tech_cards + take
            prod_statistic.on_flow("kr-advanced-tech-card", -1 * take)
            contents_changed = true
          end
        end
        if inv_record.name == "kr-singularity-tech-card" and inv_record.count > 0 then
          local take = math.min(inv_record.count,
            struct.required_singularity_tech_cards - struct.current_singularity_tech_cards)
          if take > 0 then
            main_inv.remove({ name = "kr-singularity-tech-card", count = take })
            struct.current_singularity_tech_cards = struct.current_singularity_tech_cards + take
            prod_statistic.on_flow("kr-singularity-tech-card", -1 * take)
            contents_changed = true
          end
        end
        if inv_record.name == "kr-space-research-data" and inv_record.count > 0 then
          local take = math.min(inv_record.count,
            struct.required_space_research_data - struct.current_space_research_data)
          if take > 0 then
            main_inv.remove({ name = "kr-space-research-data", count = take })
            struct.current_space_research_data = struct.current_space_research_data + take
            prod_statistic.on_flow("kr-space-research-data", -1 * take)
            contents_changed = true
          end
        end
      end

      if contents_changed then
        update_all_guis(true)
        update_combinator(struct)
      end

      -- Check if the loading process is complete and if so, replace the entity with a firing transceiver:
      if struct.current_matter_tech_cards >= struct.required_matter_tech_cards and struct.current_advanced_tech_cards >= struct.required_advanced_tech_cards and struct.current_space_research_data >= struct.required_space_research_data and struct.current_singularity_tech_cards >= struct.required_singularity_tech_cards then
        if struct.completed_activations + 1 < settings.startup["kee-activations"].value then
          -- Perform test-firing:
          local firing_entity = struct.entity.surface.create_entity
              {
                type                      = "accumulator",
                name                      = "kee-intergalactic-transceiver-test-fire",
                force                     = struct.entity.force,
                player                    = struct.entity.last_user,
                position                  = struct.entity.position,
                create_build_effect_smoke = false
              }

          -- Duplicate all network connections for the replacement entity:
          copy_network_wires(struct.entity, firing_entity)

          -- Remove old entity:
          storage.kee_intergalactic_transceivers[struct.entity.unit_number] = nil
          struct.entity.destroy()
          transceiver_replaced                  = true
          -- Store new entity in our struct:
          struct.entity                         = firing_entity
          struct.state                          = 'firing'

          -- Reset internal counters:
          struct.current_space_research_data    = 0
          struct.current_matter_tech_cards      = 0
          struct.current_advanced_tech_cards    = 0
          struct.current_singularity_tech_cards = 0


          storage.kee_intergalactic_transceivers[struct.entity.unit_number] = struct
          update_all_guis(false) -- Close all GUIs, the displayed entity might not exist anymore
          calculate_current_needs(struct)
          update_combinator(struct)

          local percentage = (struct.required_charge * 100.0 / firing_entity.prototype.electric_energy_source_prototype.buffer_capacity)
          struct.entity.last_user.print(string.format(
            "Performing test-firing %d/%d of the intergalactic transceiver with %.1f%% power.",
            struct.completed_activations + 1, settings.startup["kee-activations"].value, percentage))
        else
          -- This is the final activation, replace with the original, charging transceiver:
          struct.entity.last_user.print(string.format(
            "Performing final activation of the intergalactic transceiver with 100%% power!"))
          local final_entity = struct.entity.surface.create_entity
              {
                type                      = "accumulator",
                name                      = "kr-intergalactic-transceiver",
                force                     = struct.entity.force,
                player                    = struct.entity.last_user,
                position                  = struct.entity.position,
                create_build_effect_smoke = false,
                raise_built               = true -- This should trigger the krastorio2 internal initialization of the building
              }

          storage.kee_intergalactic_transceivers[struct.entity.unit_number] = nil
          if final_entity == nil then
            -- We were unable to create a new transceiver, this can happen if for example the player has already a working kr-transceiver:
            struct.entity.last_user.print(
              "[color=red]Final activation of the intergalactic transceiver failed![/color] (maybe we already have one?)")
          else
            -- Remove all our entities and stored data, it's now out of our hands:
            struct.combinator.destroy()
            struct.entity.destroy()
          end
          transceiver_replaced = true
          update_all_guis(false) -- Close all GUIs
        end
      end
    elseif struct.entity and struct.entity.valid and struct.state == 'firing' then
      -- Check if the transceiver has been charged to the required target-level:
      if struct.entity.energy >= struct.required_charge or struct.entity.energy >= struct.entity.prototype.electric_energy_source_prototype.buffer_capacity then
        struct.entity.last_user.print(string.format(
          "[color=green]Test-firing %d/%d of the intergalactic transceiver successful![/color]",
          struct.completed_activations + 1, settings.startup["kee-activations"].value))
        local loading_entity = struct.entity.surface.create_entity
            {
              type                      = "container",
              name                      = "kee-intergalactic-transceiver-loading",
              force                     = struct.entity.force,
              player                    = struct.entity.last_user,
              position                  = struct.entity.position,
              create_build_effect_smoke = false
            }

        -- Duplicate all network connections for the replacement entity:
        copy_network_wires(struct.entity, loading_entity)

        -- Remove old entity:
        storage.kee_intergalactic_transceivers[struct.entity.unit_number] = nil
        struct.entity.destroy()
        transceiver_replaced = true
        -- Store new entity in our struct:
        struct.entity = loading_entity
        struct.state = 'loading'
        storage.kee_intergalactic_transceivers[struct.entity.unit_number] = struct

        -- Update internal settings for next iteration:
        struct.completed_activations = struct.completed_activations + 1
        update_all_guis(false) -- Close all GUIs, the displayed entity might not exist anymore
        calculate_current_needs(struct)
        update_combinator(struct)
      else
        update_all_guis(true) -- Update current charge-progress
      end
    else
      -- Some invalid state of entity (should not happen, remove it:
      game.print(string.format("removing invalid transceiver from tracking: %d", index))
      storage.kee_intergalactic_transceivers[index] = nil
      transceiver_replaced = true
    end

    -- In case we modiefied one of the transceivers, it is safer to quite the for-loop:
    if transceiver_replaced then break end
  end
end)

function update_all_guis(reopen)
  for _, player in pairs(game.players) do
    if player.gui.left["kee-gui"] and storage.kee_open_guis[player.index] ~= nil then
      local current_open_entity = storage.kee_open_guis[player.index]
      close_gui(player)
      if reopen then
        open_gui(player, current_open_entity)
      else
        storage.kee_open_guis[player.index] = nil
      end
    end
  end
end

function close_gui(player)
  if player.gui.left["kee-gui"] then
    player.gui.left["kee-gui"].destroy()
    storage.kee_open_guis[player.index] = nil
  end
end

function open_gui(player, entity)
  local gui = player.gui.left
  local struct = storage.kee_intergalactic_transceivers[entity.unit_number]
  if struct == nil or gui == nil then return end

  -- Headline:
  local container = gui.add { type = "frame", name = "kee-gui", style = "kee_container", direction = "vertical" }
  local title_flow = container.add { type = "flow", name = "kee-title.flow", direction = "horizontal" }
  local current_title = "Intergalactic Transceiver"
  if struct.state == 'loading' then
    current_title = current_title .. " (loading)"
  elseif struct.state == 'firing' then
    current_title = current_title .. " (test-firing)"
  end
  local title = title_flow.add { type = "label", name = "kee-title.main", caption = current_title, style = "kee_title" }

  -- Overall progress:
  container.add { type = "label", name = "kee-activations", caption = string.format("Successful activations: %d / %d", struct.completed_activations, settings.startup["kee-activations"].value) }
  local bar                          = container.add { type = "progressbar", name = "kee-activations-progress", size = 300, value = struct.completed_activations / settings.startup["kee-activations"].value, style = "kee_global_progressbar" }
  bar.style.horizontally_stretchable = true

  -- Progress of the current step:
  if struct.state == 'loading' then
    container.add { type = "label", name = "kee-space-label", caption = string.format("Space research data: %d / %d (signal R)", struct.current_space_research_data, struct.required_space_research_data) }
    bar                                = container.add { type = "progressbar", name = "kee-space-progress", size = 300, value = struct.current_space_research_data / struct.required_space_research_data, style = "kee_resource_progressbar" }
    bar.style.horizontally_stretchable = true

    container.add { type = "label", name = "kee-matter-label", caption = string.format("Matter tech cards: %d / %d (signal M)", struct.current_matter_tech_cards, struct.required_matter_tech_cards) }
    bar                                = container.add { type = "progressbar", name = "kee-matter-progress", size = 300, value = struct.current_matter_tech_cards / struct.required_matter_tech_cards, style = "kee_resource_progressbar" }
    bar.style.horizontally_stretchable = true

    container.add { type = "label", name = "kee-advanced-label", caption = string.format("Advanced tech cards: %d / %d (signal A)", struct.current_advanced_tech_cards, struct.required_advanced_tech_cards) }
    bar                                = container.add { type = "progressbar", name = "kee-advanced-progress", size = 300, value = struct.current_advanced_tech_cards / struct.required_advanced_tech_cards, style = "kee_resource_progressbar" }
    bar.style.horizontally_stretchable = true

    container.add { type = "label", name = "kee-singularity-label", caption = string.format("Singularity tech cards: %d / %d (signal S)", struct.current_singularity_tech_cards, struct.required_singularity_tech_cards) }
    bar                                = container.add { type = "progressbar", name = "kee-singularity-progress", size = 300, value = struct.current_singularity_tech_cards / struct.required_singularity_tech_cards, style = "kee_resource_progressbar" }
    bar.style.horizontally_stretchable = true
  elseif struct.state == 'firing' then
    local percentage = struct.entity.energy / struct.required_charge
    if percentage > 1 then percentage = 1 end
    container.add { type = "label", name = "kee-charge-label", caption = string.format("Energy level: %.1f%% / %.1f%%", struct.entity.energy / struct.entity.prototype.electric_energy_source_prototype.buffer_capacity * 100, struct.required_charge / struct.entity.prototype.electric_energy_source_prototype.buffer_capacity * 100) }
    bar                                = container.add { type = "progressbar", name = "kee-charge-progress", size = 300, value = percentage, style = "kee_energy_progressbar" }
    bar.style.horizontally_stretchable = true
  end

  storage.kee_open_guis[player.index] = entity
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  local player = game.players[event.player_index]
  if player and entity and entity.valid and (entity.name == "kee-intergalactic-transceiver-loading" or entity.name == "kee-intergalactic-transceiver-test-fire") and storage.kee_intergalactic_transceivers[entity.unit_number] ~= nil then
    close_gui(player)
    open_gui(player, entity)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local entity = event.entity
  local player = game.players[event.player_index]
  if player and entity and entity.valid and (entity.name == "kee-intergalactic-transceiver-loading" or entity.name == "kee-intergalactic-transceiver-test-fire") and storage.kee_intergalactic_transceivers[entity.unit_number] ~= nil then
    close_gui(player)
  end
end)
