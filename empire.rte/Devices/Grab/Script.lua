function Create(self)

	self.rechargeTimer = Timer();
	self.lifttimer = Timer();
	self.ammoCounter = 100;

	self.Magazine.RoundCount = self.ammoCounter;

     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
     end


end

function Update(self)

if MovableMan:IsActor(self.parent) then

		local sharpness = self.parent.Sharpness;

if self.Magazine ~= nil then

if self:IsActivated() and self.ammoCounter > 1 then
	self.rechargeTimer:Reset();	
	self.parent:GetController():SetState(Controller.BODY_CROUCH, false);
	self.parent:GetController():SetState(Controller.BODY_JUMP, false);
	self.parent:GetController():SetState(Controller.BODY_JUMPSTART, false);
	self.parent:GetController():SetState(Controller.MOVE_LEFT, false);
	self.parent:GetController():SetState(Controller.MOVE_RIGHT, false);
if self.parent.Vel.Magnitude < 7 then
  if MovableMan:IsActor(self.target) then
			if self.target.ClassName == "ADoor" then
					for i = 0, MovableMan:GetMOIDCount() do
						if MovableMan:GetRootMOID(i) == self.target.ID then
							local object = MovableMan:GetMOFromID(i);

							self.target.Vel = Vector(7 * sharpness * (275/object.Mass),0):RadRotate(self.parent:GetAimAngle(true));
							object:AddAbsForce(Vector(3500 * sharpness,0):RadRotate(self.parent:GetAimAngle(true)), SceneMan:GetLastRayHitPos());
						end
					end
			end

	if not self.lifttimer:IsPastSimMS(150) then
		local terrcheck = Vector(0,0);

		local groundray = SceneMan:CastStrengthRay(self.Pos,Vector(0,45),0,terrcheck,1,0,true);
			if groundray == true then

				self.target.Vel = Vector(0,-11);
				
				if self.target.ClassName == "ACrab" or self.target.ClassName == "AHuman" then
					self.target.RotAngle = self.target.RotAngle + 0.1
				end
			end
	end


				local randa = math.random(-10,10);
				local randb = math.random(-10,10);
				local chain = CreateMOPixel("Grab Glow");
				chain.Pos = Vector (self.target.Pos.X + randa,self.target.Pos.Y + randb)
				MovableMan:AddParticle(chain);

	if self.HFlipped then
		if self.target.AngularVel > -5 then
			self.target.AngularVel = self.target.AngularVel - (0.2 + 0.4 * (215/self.target.Mass))
		end
	else
		if self.target.AngularVel < 5 then
			self.target.AngularVel = self.target.AngularVel + (0.2 + 0.4 * (215/self.target.Mass))
		end
	end

	self.parent:SetWhichMOToNotHit(self.target,549)
	self.target:SetWhichMOToNotHit(self.parent,549)

		if self.ammoCounter > 1 then
			self.ammoCounter = self.ammoCounter - 0.2;
		end

local dist = SceneMan:ShortestDistance(self.Pos, self.target.Pos, true).Magnitude
if self.ammoCounter > 1 and dist < (250 + sharpness * 10) then

		local terrcheck = Vector(0,0);


	if self.parent:GetController():IsState(Controller.HOLD_LEFT) then
		local groundray = SceneMan:CastStrengthRay(self.target.Pos,Vector(-10,0),0,terrcheck,1,0,true);
	   if groundray == false then
		self.target.Vel.X = -10 - sharpness
		self.ammoCounter = self.ammoCounter - 0.15;
	   end
	end
	if self.parent:GetController():IsState(Controller.HOLD_RIGHT) then
		local groundray = SceneMan:CastStrengthRay(self.target.Pos,Vector(10,0),0,terrcheck,1,0,true);
	   if groundray == false then
		self.target.Vel.X = 10 + sharpness
		self.ammoCounter = self.ammoCounter - 0.15;
	   end
	end
	if self.parent:GetController():IsState(Controller.HOLD_UP) then
		local groundray = SceneMan:CastStrengthRay(self.target.Pos,Vector(0,-10),0,terrcheck,1,0,true);
	   if groundray == false then
		self.target.Vel.Y = -10 - sharpness
		self.ammoCounter = self.ammoCounter - 0.15;
	   end
	end
	if self.parent:GetController():IsState(Controller.HOLD_DOWN) then
		local groundray = SceneMan:CastStrengthRay(self.target.Pos,Vector(0,10),0,terrcheck,1,0,true);
	   if groundray == false then
		self.target.Vel.Y = 10 + sharpness
		self.ammoCounter = self.ammoCounter - 0.15;
	   end
	end

		self.target.Vel = self.target.Vel * 0.9;
		local floatvel = math.sin(self.lifttimer.ElapsedSimTimeMS / 300) / 1.5;
		self.target.Vel.Y = self.target.Vel.Y + floatvel;
else
	self.target = nil;

end

  else
	--FIND TARGET
		targetID1 = SceneMan:CastMORay(self.Pos, Vector(170 + sharpness * 10,0):RadRotate(self.parent:GetAimAngle(true)), self.parent.ID, self.Team, 0, true,0)
		targetMO1 = nil
		if targetID1 ~= 255 then
			targetMO1 = MovableMan:GetMOFromID(MovableMan:GetMOFromID(targetID1).RootID)
		end
		if MovableMan:IsActor(targetMO1) then
			self.target = targetMO1
			self.lifttimer:Reset();
		end
  end
elseif self.parent.Vel.Magnitude > 5 then

	--FORCE STOP
	self.parent.Vel = Vector(0,0);

	if self.ammoCounter > 1 then
		self.ammoCounter = self.ammoCounter - 0.05;
	end

	if self.target then
		self.target = nil;
	end

    	i = 0;
		while i < 6 do
	    	local e = CreateMOSParticle("Small Smoke Ball 1");
    		local randx = math.random(-6,6);
    		local randy = math.random(-6,6);
		e.Vel = Vector(randx,randy)
    		e.Pos.X = self.parent.Pos.X + randx;
		e.Pos.Y = self.parent.Pos.Y + randy;
    		MovableMan:AddMO(e);
    		i = i+1;
    	end

end

else

      if MovableMan:IsActor(self.target) and self.ammoCounter > 20 and self.lifttimer:IsPastSimMS(520 - 50 * sharpness) then

	local throwvel = 15 + (sharpness * (395/self.target.Mass));


	if self.parent:GetController():IsState(Controller.HOLD_LEFT) then
		if self.HFlipped then
			self.target.Vel = Vector(throwvel,0):RadRotate(self.parent:GetAimAngle(true));
		else
			self.target.Vel = Vector(-throwvel,0):RadRotate(self.parent:GetAimAngle(true));
		end

		self.ammoCounter = self.ammoCounter - 15;
		self.rechargeTimer:Reset();
	elseif self.parent:GetController():IsState(Controller.HOLD_RIGHT) then
		if self.HFlipped then
			self.target.Vel = Vector(-throwvel,0):RadRotate(self.parent:GetAimAngle(true));
		else
			self.target.Vel = Vector(throwvel,0):RadRotate(self.parent:GetAimAngle(true));
		end
		self.ammoCounter = self.ammoCounter - 15;
		self.rechargeTimer:Reset();
	elseif self.parent:GetController():IsState(Controller.HOLD_UP) then
		self.target.Vel = Vector(0,-throwvel);

		self.ammoCounter = self.ammoCounter - 15;
		self.rechargeTimer:Reset();
	elseif self.parent:GetController():IsState(Controller.HOLD_DOWN) then
		self.target.Vel = Vector(0,throwvel);
		self.ammoCounter = self.ammoCounter - 15;
		self.rechargeTimer:Reset();
	end

--	if not self.rechargeTimer:IsPastSimMS(50) then
		for actor in MovableMan.Actors do
			if actor.ID ~= self.target.ID and actor.Team ~= self.Team then
			 if self.ammoCounter > 3 then
				local dist = SceneMan:ShortestDistance(self.target.Pos, actor.Pos, true).Magnitude
					if dist < (20 + sharpness * 6)then
						actor.Vel = self.target.Vel * 0.8
					end
				self.ammoCounter = self.ammoCounter - 0.5;
			 end
			end
		end
--	end

    	i = 0;
		while i < 7 do
    			local randx = math.random(-6,6);
    			local randy = math.random(-6,6);
		    	local e = CreateMOSParticle("Small Smoke Ball 1");
    			e.Vel.X = self.target.Vel.X * 3 + randx;
			e.Vel.Y = self.target.Vel.Y * 3 + randy;
    			e.Pos.X = self.target.Pos.X + randx * 1.5;
			e.Pos.Y = self.target.Pos.Y + randy * 1.5;
    			MovableMan:AddMO(e);
    			i = i+1;
    		end


	self.parent:SetWhichMOToNotHit(self.target,1549)
	self.target:SetWhichMOToNotHit(self.parent,1549)

		self.target = nil;
      end

end


		if self.rechargeTimer:IsPastSimMS(130 - sharpness * 10) and self.ammoCounter < (50 + sharpness * 25) then
			self.rechargeTimer:Reset();
			self.ammoCounter = self.ammoCounter + 1;
		end

		self.Magazine.RoundCount = math.ceil(self.ammoCounter); 

end


else
     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
     end
end
	
end