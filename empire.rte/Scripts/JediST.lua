
dofile("Base.rte/Constants.lua")
require("Actors/AI/NativeHumanAI")	--dofile("Base.rte/Actors/AI/NativeHumanAI.lua")

function Create(self)


	self.mapwrapx = SceneMan.SceneWrapsX;
	self.garbTimer = Timer(); 



	self.AI = NativeHumanAI:Create(self)

end

function Update(self)




local health = self.Health;

if health > 0 then

	self.ToDelete = false

	self.Age = 0


	self:ClearForces()


	if self.garbTimer:IsPastSimMS(1750 - (100 - health)*10) then
		collectgarbage("collect");
		self.garbTimer:Reset();
		if health < 100 then
			self.Health = health + 1;
		end
	end  
end

self:MoveOutOfTerrain(-20)
end


function UpdateAI(self)
	self.AI:Update(self)
end
