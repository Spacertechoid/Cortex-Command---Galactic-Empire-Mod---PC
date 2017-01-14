function Create(self)
	self.recoil = 0;
 
	self.ff = false;
 
	self.f0 = ToMagazine(self.Magazine).RoundCount;
 
	self.f1 = ToMagazine(self.Magazine).RoundCount;
	self.FireTimer = Timer();

     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
     end




end



function Update(self)

	self.Scale = 0.9;

if self.RootID ~= self.ID then

if not self.parent then
     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
     end

end

	if self.parent.PresetName == "Jango Fett" or self.parent.PresetName == "Jango Fett ST" then
		if self.parent.HFlipped == false then
			self.RotAngle = self.parent:GetAimAngle(true); 
		else
			self.RotAngle = (self.parent:GetAimAngle(true) + math.pi); 
		end
	end

if self:IsReloading() then
	self.recoil = 0.0;

	if self.HFlipped then
		self.negatore = -1;
	else
		self.negatore = 1;
	end

	local angle = self.RotAngle;
	self.RotAngle = angle + 1.25 * self.negatore;
	self.Pos = self.Pos + Vector(-1 * self.negatore,-1):RadRotate(angle);
end




if self.Magazine ~= nil then
 

	if not self.FireTimer:IsPastSimMS(120) then
		if self.HFlipped then
			self.RotAngle = self.RotAngle - 0.25;
		else
			self.RotAngle = self.RotAngle + 0.25;
		end
	end

	if self.ff then
	 
		self.f0 = ToMagazine(self.Magazine).RoundCount;
	 
		self.ff = false;
 
	else
	 
		self.f1 = ToMagazine(self.Magazine).RoundCount;
	 
		self.ff = true;
 
	end

 

	if self:IsActivated() then
	  if self.f1 ~= self.f0 then
		local recoil2 = self.recoil;
		if recoil2 < 0.03 then
			local actor = MovableMan:GetMOFromID(self.RootID);
			self.recoil = recoil2 + 0.0007 + (6 - actor.Sharpness) * 0.45 * 0.0007;

			self.FireTimer:Reset();

		local soundfx2 = CreateAEmitter("Westar Muzzle Action"); -- Sound FX Emitter PresetName

		local velFactor = FrameMan.PPM * TimerMan.DeltaTimeSecs;
		local checkVect = actor.Vel * velFactor;

		soundfx2.Pos = self.MuzzlePos + (checkVect * 1.2);

		if self.HFlipped then
			soundfx2.RotAngle = self.RotAngle + math.pi;
		else
			soundfx2.RotAngle = self.RotAngle;
		end
		MovableMan:AddParticle(soundfx2);

		end

	  end
 	end


		local randb = math.random(-7,7);


		local recoil = self.recoil
		local recoilrand = randb * recoil;

		self.RotAngle = self.RotAngle + recoilrand;

if not self:IsActivated() then
	if recoil > 0 then
		self.recoil = recoil - 0.00013;

	elseif recoil < 0 then
		self.recoil = 0;
	end

end
end

end


end 