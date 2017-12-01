--- handles items in the levels
ItemHandler = class("ItemHandler", {})

-- constructor for item handler.
function ItemHandler:init()
	self.itemList = require "resources.ITEMS"
end
-- gets item
function ItemHandler:getItem(id)
	return self.itemList[id]
end
-- gets item name
function ItemHandler:getItemName(id)
	return self.itemList[id].name
end