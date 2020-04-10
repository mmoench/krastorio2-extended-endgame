local ui_width = 300
local margin_right = 20

data.raw["gui-style"]["default"]["kee_container"] = {
    minimal_width = ui_width,
    type = "frame_style",
    parent = "frame",
}
data.raw["gui-style"]["default"]["kee_title"] = {
    width = ui_width - margin_right,
    parent= "label",
    type = "label_style",
    font = "default-large-semibold",
    single_line = false,
}
data.raw["gui-style"]["default"]["kee_global_progressbar"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 0/255,
      g = 255/255,
      b = 0/255
    }
}
data.raw["gui-style"]["default"]["kee_energy_progressbar"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 0/255,
      g = 0/255,
      b = 255/255
    }
}
data.raw["gui-style"]["default"]["kee_resource_progressbar"] = {
    type = "progressbar_style",
    parent = "progressbar",
    color = {
      r = 255/255,
      g = 255/255,
      b = 0/255
    }
}
