local data_util = require("__Krastorio2__/data-util")

-- Modify the transceiver tech to unlock our building instead of the original:
data_util.add_recipe_unlock("kr-intergalactic-transceiver", "kee-intergalactic-transceiver-loading")
data_util.remove_recipe_unlock("kr-intergalactic-transceiver", "kr-intergalactic-transceiver")
