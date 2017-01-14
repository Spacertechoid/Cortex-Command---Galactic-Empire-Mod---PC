
dofile("Base.rte/Constants.lua")
require("Actors/AI/NativeHumanAI")	--dofile("Base.rte/Actors/AI/NativeHumanAI.lua")

function Create(self)

	self.mapwrapx = SceneMan.SceneWrapsX;

	self.garbTimer = Timer();

	self.DashTapTimer = Timer();
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

	self:ClearForces()
	self.Head:ClearForces()
	self.FGArm:ClearForces()
	self.BGArm:ClearForces()
	self.FGLeg:ClearForces()
	self.BGLeg:ClearForces()

	if not self:HasObject("Ventress Force Grip") then
		local hook = CreateHDFirearm("Ventress Force Grip");
		self:AddInventoryItem(hook);
	end

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

if self.FGLeg then
local terrcheck = Vector(0,0);
	local ray = SceneMan:CastStrengthRay(self.FGLeg.Pos,Vector(0,25),0,terrcheck,1,0,true);
	if ray == true then
	local ownCont = self:GetController();
	if ownCont:IsState(Controller.PRESS_RIGHT) then
			if self.DashTapTimer:IsPastSimMS(250) then
				self.DashTapTimer:Reset();
			else
   				if self.HFlipped == false then
					self.RotAngle = -0.01;
					self.Vel.Y = self.Vel.Y - 3
					self.Vel.X = lengthdir_x(14,0)

					self:ClearForces()
					self.Head:ClearForces()
					self.FGArm:ClearForces()
					self.BGArm:ClearForces()
					self.FGLeg:ClearForces()
					self.BGLeg:ClearForces()
				end
			
			end
	end

	local ownCont = self:GetController();
	if ownCont:IsState(Controller.PRESS_LEFT) then
			if self.DashTapTimer:IsPastSimMS(270) then
				self.DashTapTimer:Reset();
			else
   				if self.HFlipped == true then
					self.RotAngle = 0.01;
					self.Vel.Y = self.Vel.Y - 3
					self.Vel.X = lengthdir_x(-14,0)

					self:ClearForces()
					self.Head:ClearForces()
					self.FGArm:ClearForces()
					self.BGArm:ClearForces()
					self.FGLeg:ClearForces()
					self.BGLeg:ClearForces()
				end
			
			end
	end
end
end



if self.garbTimer:IsPastSimMS(1000 - (100 - health)*3) then
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
