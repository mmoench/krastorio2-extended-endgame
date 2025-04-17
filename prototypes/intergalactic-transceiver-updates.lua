local data_util = require("__Krastorio2__/data-util")

-- Modify the transceiver tech to unlock our building instead of the original:
-- krastorio.technologies.addUnlockRecipe("kr-intergalactic-transceiver", "kee-intergalactic-transceiver-loading")
-- krastorio.technologies.removeUnlockRecipe("kr-intergalactic-transceiver", "kr-intergalactic-transceiver")

data_util.add_recipe_unlock("kr-intergalactic-transceiver", "kee-intergalactic-transceiver-loading")
data_util.remove_recipe_unlock("kr-intergalactic-transceiver", "kr-intergalactic-transceiver")