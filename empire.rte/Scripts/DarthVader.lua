
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



	if not self:HasObject("Force Grip") then
		local hook = CreateHDFirearm("Force Grip");
		self:AddInventoryItem(hook);
	end

	self.ToDelete = false

	self.Age = 0



	if self.RotAngle < 1.05 then

		 self.AngularVel = self.AngularVel * 0.96;
	
end 

	if self.RotAngle > -1.05 then
		self.AngularVel = self.AngularVel * 0.96;
	
end 

	if self.RotAngle > 1.05 then
		self.AngularVel = self.AngularVel * 1.02;
	end

	if self.RotAngle < -1.05 then
 
		self.AngularVel = self.AngularVel * 1.02;

	end 

	self:ClearForces()


	if self.garbTimer:IsPastSimMS(1300 - (100 - health)*2) then
		collectgarbage("collect");
		self.garbTimer:Reset();
		if self.Health < 100 then
			self.Health = self.Health + 1;
		end
	end  

self:MoveOutOfTerrain(-7)
end

end


function UpdateAI(self)
	self.AI:Update(self)
end
