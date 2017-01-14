function Create(self)

	self.recoil = 0;
 
	self.ff = false;
 
	self.f0 = ToMagazine(self.Magazine).RoundCount;
 
	self.f1 = ToMagazine(self.Magazine).RoundCount;

	self.firecounter = 0;
	self.recoilcooldown = 0.0007;
	self.firetimer = Timer();

	self.burstTimer = Timer();
	self.burst = false;
	self.canBurst = true;
end

function Update(self)

if self.Magazine ~= nil then
 
	if self.ff then
	 
		self.f0 = ToMagazine(self.Magazine).RoundCount;
	 
		self.ff = false;
 
	else
	 
		self.f1 = ToMagazine(self.Magazine).RoundCount;
	 
		self.ff = true;
 
	end

 

	if self:IsActivated() and self.f1 ~= self.f0 then
		local recoil2 = self.recoil;
		if recoil2 < 0.022 then

			local actor = MovableMan:GetMOFromID(self.RootID)

			self.recoil = recoil2 + 0.0005 + (4 - actor.Sharpness) * 0.65 * 0.001;
			self.firetimer:Reset();
		end


 	end


		local randb = math.random(-3,3);


		local recoil = self.recoil
		local recoilrand = randb * recoil;

		self.RotAngle = self.RotAngle + recoilrand;


if self.firetimer:IsPastSimMS(350) then
	if recoil > 0 then
		self.recoil = recoil - self.recoilcooldown;

	elseif recoil < 0 then
		self.recoil = 0;
	end

end

end


	if self.canBurst == true and self:IsActivated() and self.Magazine ~= nil and self.Magazine.RoundCount > 0 then
		self.burstTimer:Reset();
		self.canBurst = false;
		self.burst = true;
	end
		

	if self.burst == true then
		if self.burstTimer:IsPastSimMS(250) then
			self.burstTimer:Reset();
			self:Deactivate();
			self.burst = false;
		else
			self:Activate();
		end
	else
		if self.canBurst == false then
			self:Deactivate();
			if self.burstTimer:IsPastSimMS(400) then
				self.canBurst = true;
			end
		end
	end

end