
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


	self.Turret = {};

	self.Turret[16] = CreateAHuman("Grievous Arms");
	self.Turret[16].Team = self.Team;
	MovableMan:AddActor(self.Turret[16]);
	self.Turret[16].Offset = Vector(0,-5);
end

function Update(self)


local health = self.Health;

	if health > 0 then

	--update turret spatial properties
	for i = 16, 17 do
		if MovableMan:IsActor(self.Turret[i]) == true and self.Turret[i].PresetName == "Grievous Arms" then
			--basic turret position upkeep (so it doesn't fall at 999999m/s)
			self.Turret[i].Vel.X = 0;
			self.Turret[i].Vel.Y = 0;
			--update turret position
			self.Turret[i].RotAngle = self.RotAngle;
			self.Turret[i].AngularVel = 0;
			self.Turret[i]:ClearForces();
			self.Turret[i].Pos = self.Pos + self:RotateOffset(self.Turret[i].Offset)
			self.Turret[i].HFlipped = self.HFlipped;
		end
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
	end
	
self:MoveOutOfTerrain(-0.5)


local terrcheck = Vector(0,0);
	local ray = SceneMan:CastStrengthRay(self.Pos,Vector(0,20),0,terrcheck,1,0,true);
	
if ray == true then
	local ownCont = self:GetController();

	if ownCont:IsState(Controller.HOLD_DOWN) then
		if self.Vel.Magnitude > 5 then
		--FORCE STOP
			self.Vel = Vector(0,0);
		end
	end


	if ownCont:IsState(Controller.PRESS_RIGHT) then
			if self.DashTapTimer:IsPastSimMS(250) then
				self.DashTapTimer:Reset();
			else
   				if self.HFlipped == false then
					self.RotAngle = -0.01;
					self.Vel.Y = self.Vel.Y - 3
					self.Vel.X = lengthdir_x(15,0)

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
			if self.DashTapTimer:IsPastSimMS(250) then
				self.DashTapTimer:Reset();
			else
   				if self.HFlipped == true then
					self.RotAngle = 0.01;
					self.Vel.Y = self.Vel.Y - 3
					self.Vel.X = lengthdir_x(-15,0)

					self:ClearForces()
					self.Head:ClearForces()
					self.FGArm:ClearForces()
					self.BGArm:ClearForces()
					self.FGLeg:ClearForces()
					self.BGLeg:ClearForces()
				end
			
			end
	end
	else
end



if self.garbTimer:IsPastSimMS(2530) then
	collectgarbage("collect");
	self.garbTimer:Reset();
	if health < 100 then
		self.Health = health + 1;
	end
end 
 
else
	--update turret spatial properties
	for i = 16, 17 do
		if MovableMan:IsActor(self.Turret[i]) then
			self.Turret[i]:GibThis();
		end
	end
end

end



function UpdateAI(self)
	self.AI:Update(self)
end