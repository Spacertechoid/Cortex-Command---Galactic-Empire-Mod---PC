function Create(self)

     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
     end

	self.ReflectTimer = Timer();
	self.BlockAngle = self.RotAngle;
	self.randblock = 1;

	self.hitnum = 0;

	self.rechargeTimer = Timer();
	self.ammoCounter = 50;

	self.Magazine.RoundCount = self.ammoCounter;

	self.anglemodifier = 0;
	self.SpinTimer = Timer();

end

function Update(self)

  if MovableMan:IsActor(self.parent) and self.RootID == self.parent.ID then

	if self.Magazine ~= nil then

	if self.HFlipped then
		self.negatore = 1
	else
		self.negatore = -1
	end

	if not self.ReflectTimer:IsPastSimMS(310 - (20 * self.parent.Sharpness)) then


		local blockang = self.BlockAngle

		if not self.ReflectTimer:IsPastSimMS(35) then
				local rand = math.random(0,4)
				if rand == 1 then
					self.Magazine.Frame = 9;
				elseif rand == 2 then
					self.Magazine.Frame = 4;
				elseif rand == 3 then
					self.Magazine.Frame = 11;
				elseif rand == 4 then
					self.Magazine.Frame = 12;
				else
					self.Magazine.Frame = 4;	
				end
			self.BlockAngle = blockang * 1.01;
		elseif not self.ReflectTimer:IsPastSimMS(55) then
			self.Magazine.Frame = 5
			self.BlockAngle = blockang * 0.999;
		elseif not self.ReflectTimer:IsPastSimMS(95) then
			self.Magazine.Frame = 5
			self.BlockAngle = blockang * 0.995;
		elseif not self.ReflectTimer:IsPastSimMS(120) then
			self.Magazine.Frame = 6
			self.BlockAngle = blockang * 0.99;
		elseif not self.ReflectTimer:IsPastSimMS(155) then
			self.Magazine.Frame = 7
			self.BlockAngle = blockang * 0.98;
		elseif not self.ReflectTimer:IsPastSimMS(210) then
			self.Magazine.Frame = 8
			self.BlockAngle = blockang * 0.97;
		elseif not self.ReflectTimer:IsPastSimMS(260) then
			self.Magazine.Frame = 9
			self.BlockAngle = blockang * 0.95;
		end

		self.RotAngle = self.BlockAngle		
	else
		self.Magazine.Frame = math.random(0,3);

			local blockang = self.BlockAngle
			if blockang ~= 0 then
				if blockang > math.pi then
					blockang = blockang - math.pi
				elseif blockang < -math.pi then
					blockang = blockang + math.pi
				end


				if math.abs(self.BlockAngle) < (math.pi * 0.5) then
					self.BlockAngle = blockang * 0.8
				else
					self.BlockAngle = blockang * 1.1

					if math.abs(self.BlockAngle) >= math.pi then
						self.BlockAngle = 0;
					end
				end

				if self.BlockAngle < -0.08 and self.BlockAngle > 0.08 then
					local rand = math.random(0,4)
					if rand < 2 then
						self.Magazine.Frame = 14
					else
						self.Magazine.Frame = 15
					end
				else
					self.Magazine.Frame = 16
				end

					if self.BlockAngle > -0.03 and self.BlockAngle < 0.03 then
						self.BlockAngle = 0;
					end
				self.RotAngle = self.RotAngle + blockang;
			end

		local angle = self.RotAngle;
		if self.parent:GetController():IsState(13) then
			self.RotAngle = angle - 1.15 * self.negatore;
			self.Pos = self.Pos + Vector(-3,0):RadRotate(self.parent:GetAimAngle(true));
		else
			self.RotAngle = angle - 1.65 * self.negatore;
		end
	end



	if self:IsActivated() then

		self.rechargeTimer:Reset();

	local angmod = 0

	if self.SpinTimer:IsPastSimMS(535 - (20 * self.parent.Sharpness)) and self.ReflectTimer:IsPastSimMS(350) and self.BlockAngle == 0 then
		angmod = self.anglemodifier

		if angmod == 0 then
			local soundfx = CreateAEmitter("Lightsaber Swing");
			soundfx.Pos = self.Pos;
			MovableMan:AddParticle(soundfx);
		end

		if self.randblock > 0 then
			posneg = 1;
		else
			posneg = -1;
		end

		self.anglemodifier = angmod - 0.25 * posneg
					local rand = math.random(0,4)
					if rand < 2 then
						self.Magazine.Frame = 14
					else
						self.Magazine.Frame = 15
					end

		if posneg == 1 then
			if angmod <= -(math.pi * 2) then
				self.anglemodifier = 0;
				angmod = 0;
				self.SpinTimer:Reset();
			end
		else
			if angmod >= (math.pi * 2) then
				self.anglemodifier = 0;
				angmod = 0;
				self.SpinTimer:Reset();
			end
		end

	end

	local angle = self.RotAngle;
	self.RotAngle = angle - (angmod)* self.negatore;

	if self.ammoCounter > 1 then	

--SHIELD
   for particle in MovableMan.Particles do
	local pardist = SceneMan:ShortestDistance(self.Pos,particle.Pos,true);

	if pardist.Magnitude < 25 then
	if particle.Team ~= self.Team then

   if particle.HitsMOs == false then

	if pardist.Magnitude < 21 and particle.PresetName == "Lightsaber Killing B" then
		if self.ammoCounter > 1 then
--	particle.ToDelete = true;

	local angle = SceneMan:ShortestDistance(self.Pos,particle.Pos, true).AbsRadAngle
	self.ReflectTimer:Reset();
	self.randblock = math.random(-5,5);

	self.BlockAngle = angle - self.randblock * 0.4;


	local soundfx = CreateAEmitter("Lightsaber Clash");
	soundfx.Pos = particle.Pos;
	soundfx.RotAngle = self.RotAngle + math.pi;
	MovableMan:AddParticle(soundfx);

	local strikePoint = Vector(0,-1);
	self.parent:AddAbsForce((particle.Vel) * 0.45, strikePoint);
	self.parent.Vel = self.parent.Vel * 0.85;
	self.ReflectTimer:Reset();
	particle.Pos.Y = particle.Pos.Y - 50000;

			self.ammoCounter = self.ammoCounter - 1;
		end
	end

--GRAZE BLOCK
	if pardist.Magnitude < 21 and particle.PresetName == "Lightsaber Killing C" and particle.Team ~= self.Team then
		if self.ammoCounter > 1 then

			local angle = SceneMan:ShortestDistance(self.Pos,particle.Pos, true).AbsRadAngle
			self.ReflectTimer:Reset();
			self.BlockAngle = angle;

			local soundfx = CreateAEmitter("Lightsaber Clash");
			soundfx.Pos = particle.Pos;
			soundfx.RotAngle = self.RotAngle + math.pi;
			MovableMan:AddParticle(soundfx);

			local strikePoint = Vector(0,-1);
			self.parent:AddAbsForce((particle.Vel) * 0.2, strikePoint);
			self.parent.Vel = self.parent.Vel * 0.85;
			self.ReflectTimer:Reset();

			particle.Pos.Y = particle.Pos.Y - 50000;

			self.ammoCounter = self.ammoCounter - 0.25;
		end
	end
--END GRAZE BLOCK

		if pardist.Magnitude < 20 and particle.PresetName == "Lightning Particle Null" and particle.Team ~= self.Team then
			particle.ToDelete = true;

			if self.ammoCounter > 1 then
				self.ammoCounter = self.ammoCounter - 0.2;
			end
		end

	elseif particle.HitsMOs == true then

	if particle.ClassName == "MOPixel" and pardist.Magnitude < 25 and particle.Vel.Magnitude > 30 and particle.PresetName ~= "Lightsaber Killing B" and particle.Team ~= self.Team then
		if self.ammoCounter > 1 then
	local angle = SceneMan:ShortestDistance(self.Pos,particle.Pos, true).AbsRadAngle

	self.ReflectTimer:Reset();
	self.randblock = math.random(-5,5);


		self.BlockAngle = angle - (self.randblock * 0.4 * -1 * self.negatore);

				local rand = math.random(0,1)
				if rand == 1 then
					self.Magazine.Frame = 12;
				else
					self.Magazine.Frame = 11;
				end

	local rand = math.random(-27,27);

	local soundfx = CreateAEmitter("Lightsaber Swing");
	soundfx.Pos = particle.Pos;
	MovableMan:AddParticle(soundfx);
	
	particle.Vel = Vector(particle.Vel.Magnitude,rand):RadRotate(self.parent:GetAimAngle(true));
	particle:SetWhichMOToNotHit(self.parent,-1);
	particle.Team = self.Team;
	particle.IgnoresTeamHits = true;

	local strikePoint = Vector(0,-1);
	self.parent:AddAbsForce((particle.Vel) * 0.2, strikePoint);



			self.ammoCounter = self.ammoCounter - 1;
		end



	elseif particle.ClassName ~= "MOPixel" and pardist.Magnitude < 25 and particle.Vel.Magnitude > 30 and particle.PresetName ~= "Lightsaber Killing B" and particle.Mass < 50 and particle.Team ~= self.Team then

	particle.ToDelete = true;

	local angle = SceneMan:ShortestDistance(self.Pos,particle.Pos, true).AbsRadAngle
	self.ReflectTimer:Reset();
	self.randblock = math.random(-5,5);

	self.BlockAngle = angle - self.randblock * 0.4;


	local soundfx = CreateAEmitter("Lightsaber Deflect");
	soundfx.Pos = particle.Pos;
	MovableMan:AddParticle(soundfx);

	local strikePoint = Vector(0,-1);
	self.parent:AddAbsForce((particle.Vel) * 0.2, strikePoint);
	self.ReflectTimer:Reset();

		if self.ammoCounter > 1 then
			self.ammoCounter = self.ammoCounter - 1;
		end
	end
	 end
	end
       end
     end

--END SHIELD

--SWING

if self.ReflectTimer:IsPastSimMS(400 - (20 * self.parent.Sharpness)) then
	local rayL = 0;  
	local vect = Vector(18,0);

		vect = Vector(-17 * self.negatore,-17);

	vect = vect:RadRotate(self.RotAngle); 

	rayL = SceneMan:CastObstacleRay(Vector(self.Pos.X,self.Pos.Y),vect,Vector(0,0),Vector(0,0),self.parent.ID,self.Team,0,1);  

	if rayL>0 then  

	local moid = SceneMan:CastMORay(self.Pos,vect,self.parent.ID,self.Team,0,false,0); 
		if moid ~= 255 and moid ~= 0 then

			local hitMO = MovableMan:GetMOFromID(moid);
			local root = MovableMan:GetMOFromID(hitMO.RootID);


	if hitMO and not(MovableMan:IsActor(root) and ToActor(root).Health < 0) then
		if self.ammoCounter > 1 then
			self.ammoCounter = self.ammoCounter - 1;

		end

  		local i = 0;
		while i < 2 do
				local burn2 = CreateMOPixel("Lightsaber Killing B", "Empire.rte");  
				burn2.Vel = vect;
				burn2.Pos = SceneMan:GetLastRayHitPos();
				burn2.Team = self.Team;
				burn2.IgnoresTeamHits = true;
				MovableMan:AddParticle(burn2);
				i = i+1;
		end

		if MovableMan:IsActor(root) then
			self.parent:SetWhichMOToNotHit(root,349)
			root:SetWhichMOToNotHit(self.parent,349)
		end
	end


				local part = CreateAEmitter("Lightsaber Ground Impact");
				part.Pos = SceneMan:GetLastRayHitPos();  
				MovableMan:AddParticle(part);  

			if hitMO and MovableMan:IsActor(root) and ToActor(root).Health > 0 then

				local angle = SceneMan:ShortestDistance(self.Pos,root.Pos, true).AbsRadAngle

					self.randblock = math.random(-5,5);

						self.BlockAngle = angle + (self.randblock * 0.4 * self.negatore);

	local dist2 = SceneMan:ShortestDistance(part.Pos,hitMO.Pos, true)	
	local angle2 = SceneMan:ShortestDistance(part.Pos,hitMO.Pos, true).AbsRadAngle

	if dist2 ~= 0 then
		vect = Vector(18,0):RadRotate(angle2);
	end


			local soundfx = CreateAEmitter("Lightsaber Impact");
			soundfx.Pos = SceneMan:GetLastRayHitPos();
			MovableMan:AddParticle(soundfx);
	
	self.hitnum = self.hitnum + 1;

		if self.hitnum < 3 then
				local burn2 = CreateMOPixel("Lightsaber Killing B", "Empire.rte");  
				burn2.Vel = vect;
				burn2.Pos = SceneMan:GetLastRayHitPos();
				burn2.Team = self.Team;
				burn2.IgnoresTeamHits = true;
				--burn2:SetWhichMOToNotHit(self.parent,-1); 
				MovableMan:AddParticle(burn2);
		else
  		local i = 0;
		while i < 6 do
				local burn2 = CreateMOPixel("Lightsaber Killing B", "Empire.rte");  
				burn2.Vel = vect;
				burn2.Pos = SceneMan:GetLastRayHitPos();
				burn2.Team = self.Team;
				burn2.IgnoresTeamHits = true;
				--burn2:SetWhichMOToNotHit(self.parent,-1); 
				MovableMan:AddParticle(burn2);
				i = i+1;
		end
			self.randblock = self.randblock * -1;
			self.ammoCounter = self.ammoCounter + 3;
			self.hitnum = 0;
			self.ReflectTimer:Reset();


			local soundfx = CreateAEmitter("Lightsaber Swing");
			soundfx.Pos = self.Pos;
			MovableMan:AddParticle(soundfx);

				local rand = math.random(0,4)
				if rand == 1 then
					self.Magazine.Frame = 9;
				elseif rand == 2 then
					self.Magazine.Frame = 10;
				elseif rand == 3 then
					self.Magazine.Frame = 11;
				elseif rand == 4 then
					self.Magazine.Frame = 12;
				else
					self.Magazine.Frame = 4;	
				end

				local part1 = 100/(root.Mass)
				ToActor(root).Health = ToActor(root).Health - part1;

	self.parent:SetWhichMOToNotHit(root,219)
	root:SetWhichMOToNotHit(self.parent,219)

					local vect3 = Vector(-26,0);
						vect3 = Vector(-26 * self.negatore,0);
	
					root:AddAbsForce(vect3 * 6 * root.Mass, SceneMan:GetLastRayHitPos());
		end
			end
		
		else


		local part = CreateAEmitter("Lightsaber Ground Impact");

		part.Pos = SceneMan:GetLastRayHitPos();  
		MovableMan:AddParticle(part);  

		local burn = CreateMOPixel("Lightsaber Killing B", "Empire.rte");  
			burn.Vel = vect;
			burn.Pos = SceneMan:GetLastRayHitPos();
			burn.Team = self.Team;
			burn.IgnoresTeamHits = true; 
			--burn:SetWhichMOToNotHit(self.parent,-1);
			MovableMan:AddParticle(burn);
		end
	end
	else
		self.hitnum = 0;
	end
else
--BLOCKHIT
	if self.ammoCounter > 1 and not self.ReflectTimer:IsPastSimMS(20) then
	self.ammoCounter = self.ammoCounter - 0.35;
	local rayL = 0;  
	local vect = Vector(18,0);

		vect = Vector(-18 * self.negatore,-18);

	vect = vect:RadRotate(self.RotAngle); 

	rayL = SceneMan:CastObstacleRay(Vector(self.Pos.X,self.Pos.Y),vect,Vector(0,0),Vector(0,0),self.parent.ID,self.Team,0,1);  

	if rayL>0 then  
			local part = CreateAEmitter("Lightsaber Ground Impact");

		part.Pos = SceneMan:GetLastRayHitPos();  
		MovableMan:AddParticle(part);  

		local burn = CreateMOPixel("Lightsaber Killing C", "Empire.rte");  
			burn.Vel = vect;
			burn.Pos = SceneMan:GetLastRayHitPos();
			burn.Team = self.Team;
			burn.IgnoresTeamHits = true; 
			--burn:SetWhichMOToNotHit(self.parent,-1);
			MovableMan:AddParticle(burn);
	end
	end
--ENDBLOCKHIT
end

--END SWING

	else


		local sharpness = self.parent.Sharpness;
		if self.rechargeTimer:IsPastSimMS(65 - sharpness * 5) and self.ammoCounter < sharpness * 25 then
			self.rechargeTimer:Reset();
			self.ammoCounter = self.ammoCounter + 1;
			self.anglemodifier = 0;
			self.hitnum = 0;
		end
	end

		self.Magazine.RoundCount = self.ammoCounter; 

end

else
     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
     end


	self.Magazine.Frame = 13;


end
end