function Create(self)       
	self.LTimer = Timer(); 
	self.FireTimer = Timer(); 
	local curdist = 75;     
	local wep = nil;  
	self.Vel = Vector(0,0);
	     
for actor in MovableMan.Actors do    
	if math.abs((self.Pos - actor.Pos).Magnitude) < curdist and actor.PresetName == "Imperial Star Destroyer" then    
		self.parent = actor;   
		self.Team = self.parent.Team;   
	end;    
end;    

for actor in MovableMan.Actors do    
	if math.abs((self.Pos - actor.Pos).Magnitude) < curdist and actor.PresetName == "ISD Turbo Laser Control" then    
		self.parent2 = actor;      
	end;    
end;    
	   
local vect = Vector(1700,0);
local rayLockOn = 0;

  if MovableMan:IsActor(self.parent2) and MovableMan:IsActor(self.parent) then
	vect = vect:RadRotate(self.parent2:GetAimAngle(true));
	vect = vect:SetMagnitude(1700);
	rayLockOn = SceneMan:CastObstacleRay(Vector(self.Pos.X,self.Pos.Y),vect,vect,vect,self.parent.ID,self.Team,0,3);
	
	if rayLockOn>0 then
		self.LockOn = CreateMOPixel("ISD Target Achieved");
		self.LockOn.Pos = SceneMan:GetLastRayHitPos();
		MovableMan:AddParticle(self.LockOn);
	else
		self.ToDelete = true;
	end
  else
	self.ToDelete = true;
  end  
  
end     

function Update(self)     

if self.LTimer:IsPastSimMS(200) then

	if MovableMan:IsActor(self.parent) and MovableMan:IsActor(self.parent2) and MovableMan:IsParticle(self.LockOn) then     

		if self.FireTimer:IsPastSimMS(75) then
			self.LockOn2 = CreateMOPixel("ISD Target Confirmation");
			self.LockOn2.Pos = self.LockOn.Pos
			MovableMan:AddParticle(self.LockOn2);


	local gunPosx = -75; 
	local gunPosy = -46; 

	local randgun = math.random(0,10);

	if randgun == 0 then 
		gunPosx = -231; 
		gunPosy = 68; 
	elseif randgun == 1 then 
		gunPosx = 85; 
		gunPosy = 50; 
	elseif randgun == 2 then 
		gunPosx = 300; 
		gunPosy = 41; 
	elseif randgun == 3 then
		gunPosx = 112; 
		gunPosy = -23; 
	elseif randgun == 4 then
		gunPosx = -84; 
		gunPosy = -46; 
	elseif randgun == 5 then
		gunPosx = -72; 
		gunPosy = -47; 
	elseif randgun == 6 then
		gunPosx = -60; 
		gunPosy = -48; 
	elseif randgun == 7 then
		gunPosx = -301; 
		gunPosy = -34; 
	elseif randgun == 8 then
		gunPosx = -306; 
		gunPosy = -34; 
	elseif randgun == 9 then
		gunPosx = -312; 
		gunPosy = -34; 
	else
		gunPosx = -75; 
		gunPosy = -46; 
	end

local shot = CreateMOPixel("Particle TurboLaser");
shot.Pos = self.parent.Pos + self.parent:RotateOffset(Vector(gunPosx,gunPosy));

local shot2 = CreateMOPixel("Particle TurboLaser");
shot2.Pos = shot.Pos;

local shot3 = CreateMOPixel("Particle TurboLaser");
shot3.Pos = shot.Pos;

local sfx = CreateAEmitter("ISD STS Laser Fire Sound");
sfx.Pos = shot.Pos;

local Range = SceneMan:ShortestDistance(shot.Pos, self.LockOn.Pos, false)
local angle = Range.AbsRadAngle
local distance = Range.Magnitude

local spread = math.random(-7,7)

shot.Vel = Vector(80,spread):RadRotate(angle);

shot2.Vel = Vector(78,spread):RadRotate(angle);
shot3.Vel = Vector(77,spread):RadRotate(angle);
sfx:SetWhichMOToNotHit(self.parent,-1); 
MovableMan:AddParticle(sfx); 

shot:SetWhichMOToNotHit(self.parent,-1); 
MovableMan:AddParticle(shot); 

shot2:SetWhichMOToNotHit(self.parent,-1); 
MovableMan:AddParticle(shot2); 

shot3:SetWhichMOToNotHit(self.parent,-1); 
MovableMan:AddParticle(shot3); 

local exploderandom = math.random(0,3)

if exploderandom == 0 then
	local shotexplode = CreateAEmitter("TurboLaser Bolt Shot");
	shotexplode.Pos = shot.Pos;
	shotexplode.Vel = shot3.Vel;
	shotexplode:SetWhichMOToNotHit(self.parent,-1); 
	MovableMan:AddParticle(shotexplode);
end

self.FireTimer:Reset();
		end

	else
		self.ToDelete = true;
	end

end

if self.LTimer:IsPastSimMS(475) then
	self.ToDelete = true;
	self:GibThis();
end

end