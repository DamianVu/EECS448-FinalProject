
ItemHandler = class("ItemHandler", {})

function ItemHandler:init()
	self.itemList = require "resources.ITEMS"
end

function ItemHandler:getItemName(id)
	return self.itemList[id].name
end