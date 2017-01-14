
dofile("Base.rte/Constants.lua")
require("Actors/AI/NativeHumanAI")	--dofile("Base.rte/Actors/AI/NativeHumanAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.Exp = 0;
end

function Update(self)
--	if self:IsDead() then

local health = self.Health;

	if health < 0 then

		if self.Exp == 0 then
			for actor in MovableMan.Actors do
				if actor.Team ~= self.Team and actor.ClassName == "AHuman" then
					local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, true).Magnitude
					local sharpness = ToActor(actor).Sharpness;
					if dist < 55 and sharpness < 10 then
						ToActor(actor).Sharpness = sharpness + 0.01 * (10/sharpness);
						ToActor(actor):FlashWhite(55); 
					end
				end
			end
			self.Exp = 1;
		end
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
