---Handler DialogueHandler.
DialogueHandler = class("DialogueHandler", {})

cutscenes = {
	{"Starting", {"Hello! I'm the disco martian.", "This is a dialogue message", "This is the third message"}}
}
---Function DialogueHandler.
function DialogueHandler:init()
	self.playing = false
	self.interval = 3
	self.timer = 0
	self.index = 1

	self.dialogueWidth = 700
	self.dialogueHeight = 300

	self.currentCutscene = nil
end
---DialogueHandler Start.
function DialogueHandler:start(cutscene)
	self.playing = true

	for i = 1, #cutscenes do
		if cutscenes[i][1] == cutscene then
			self.currentCutscene = cutscenes[i][2]
		else
			self.currentCutscene = {"Error loading cutscene '" .. cutscene .. "'", nil}
		end
	end
end
---DialogueHandler continue.
function DialogueHandler:continue()
	self.timer = 0
	if self.index == #self.currentCutscene then
		self.index = 1
		self.playing = false
	else
		self.index = self.index + 1
	end
end
---DialogueHandler update.
function DialogueHandler:update(dt)
	if self.playing then
		self.timer = self.timer + dt
		if self.timer > self.interval then
			self:continue()
		end
	end
end
---DialougeHandler draw.
function DialogueHandler:draw()
	if self.playing then
		local w,h = love.graphics.getDimensions()
		local bottomMargin = 50

		local drawX = (w - self.dialogueWidth) / 2 -- Centers it
		local drawY = h - self.dialogueHeight - bottomMargin
		love.graphics.setColor(50,50,50,220)
		love.graphics.rectangle("fill", drawX, drawY, self.dialogueWidth, self.dialogueHeight)
		love.graphics.setColor(0,240,255)
		love.graphics.print(self.currentCutscene[self.index], drawX + 40, drawY + 40)
	end
end
