function Create(self)

self.mapwrapx = SceneMan.SceneWrapsX;

self.garbTimer = Timer();

 
self.Alternate = true;
--self.Counter = 0;
 function lengthdir_x(dist,ang)
        return dist * math.cos(-ang);
    end

end

function Update(self)
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
	
self:MoveOutOfTerrain(20)


for particle in MovableMan.Particles do
		self.parvector = SceneMan:ShortestDistance(self.Pos,particle.Pos,self.mapwrapx);
	self.pardist = self.parvector.Magnitude;

local shieldradius = 65
local mindetectspeed = 35

    if particle.HitsMOs == true then
      if self.pardist < shieldradius and particle.Vel.Magnitude > mindetectspeed then
	self.anglecheck = (self.parvector*-1).AbsDegAngle-particle.Vel.AbsDegAngle;

        if self.anglecheck > -160 and self.anglecheck < 160 then
		local avgx = self.Pos.X - particle.Pos.X;  
		local avgy = self.Pos.Y - particle.Pos.Y;  
		local dist = math.sqrt(avgx ^ 2 + avgy ^ 2); 

    		if particle.ClassName == "MOPixel" or particle.ClassName == "MOSParticle" or particle.ClassName == "MOSRotating" or particle.ClassName == "Aemitter" then
			particle.Vel = particle.Vel * 0.15
		end

        end

      end
    end
   end

if self.garbTimer:IsPastSimMS(10000) then
	collectgarbage("collect");
	self.garbTimer:Reset();
end  

end
