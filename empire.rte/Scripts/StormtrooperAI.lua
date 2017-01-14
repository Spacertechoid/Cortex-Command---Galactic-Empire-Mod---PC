
dofile("Base.rte/Constants.lua")
require("Actors/AI/NativeHumanAI")	--dofile("Base.rte/Actors/AI/NativeHumanAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
end

function Update(self)
--	if self:IsDead() then

local health = self.Health;

	if health < 0 then
		self.AngularVel = self.AngularVel * 0.97;

		if self.AngularVel == 0 then
			self.PinStrength = 5;
		end

		if self.PinStrength > 0 then
			self.PinStrength = 0;
			self.AngularVel = math.random(-4,4);
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
