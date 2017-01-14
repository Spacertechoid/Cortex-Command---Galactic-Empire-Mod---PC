
dofile("Base.rte/Constants.lua")
require("Actors/AI/NativeHumanAI")	--dofile("Base.rte/Actors/AI/NativeHumanAI.lua")

function Create(self)

	self.mapwrapx = SceneMan.SceneWrapsX;

	self.garbTimer = Timer();

	self.Alternate = true;
--self.Counter = 0;
 	function lengthdir_x(dist,ang)
 	       return dist * math.cos(-ang);
  	  end

	self.AI = NativeHumanAI:Create(self)
end

function Update(self)




local health = self.Health;

if health > 0 then

	if not self:HasObject("Force Grip") then
		local hook = CreateHDFirearm("Force Grip");
		self:AddInventoryItem(hook);
	end

	if not self:HasObject("Force Lightning") then
		local hook = CreateHDFirearm("Force Lightning");
		self:AddInventoryItem(hook);
	end

self:ClearForces()

if self.RotAngle < 1.05 then
	 self.AngularVel = self.AngularVel * 0.95;
end 
if self.RotAngle > -1.05 then
	self.AngularVel = self.AngularVel * 0.95;
end 

if self.RotAngle > 1.05 then
	self.AngularVel = self.AngularVel * 1.02;
end
if self.RotAngle < -1.05 then
 self.AngularVel = self.AngularVel * 1.02;
end 

local terrcheck = Vector(0,0);
local ray = SceneMan:CastStrengthRay(self.Pos,Vector(0,5),0,terrcheck,1,0,true);
 if ray == true then
	self.Vel.X = self.Vel.X * 0.97
	else
end

local terrcheck = Vector(0,0);
local ray = SceneMan:CastStrengthRay(self.Pos,Vector(0,5),0,terrcheck,1,0,true);
 if ray == true then
	local landonfeet = 6
	self.Vel.Y = self.Vel.Y - landonfeet
	else
end
	
self:MoveOutOfTerrain(-20)


if self.garbTimer:IsPastSimMS(1100 - (100 - health)*2) then
	collectgarbage("collect");
	self.garbTimer:Reset();
	if health < 100 then
		self.Health = health + 1;
	end
end  
end
end


function UpdateAI(self)
	self.AI:Update(self)
end
