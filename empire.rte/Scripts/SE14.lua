function Create(self)

     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
	self.RateOfFire = math.min(25 + self.parent.Sharpness * 55, 200);
     end



	self.recoil = 0;
 
	self.ff = false;
 
	self.f0 = ToMagazine(self.Magazine).RoundCount;
 
	self.f1 = ToMagazine(self.Magazine).RoundCount;

	self.firecounter = 0;
	self.recoilcooldown = 0.00013;

end



function Update(self)

if self:IsReloading() then
	self.recoil = 0.0;
     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
	self.RateOfFire = math.min(25 + self.parent.Sharpness * 55, 200);
     end
end





if self.Magazine ~= nil then
 
	if self.ff then
	 
		self.f0 = ToMagazine(self.Magazine).RoundCount;
	 
		self.ff = false;
 
	else
	 
		self.f1 = ToMagazine(self.Magazine).RoundCount;
	 
		self.ff = true;
 
	end

 
	if self:IsActivated() and self.f1 ~= self.f0 then

if not self.parent then
     local actor = MovableMan:GetMOFromID(self.RootID);
     if MovableMan:IsActor(actor) then
	self.parent = ToActor(actor);
     end

end
		local recoil2 = self.recoil;
		if recoil2 < 0.03 then
			self.recoil = recoil2 + 0.0015 + (4 - self.parent.Sharpness) * 0.65 * 0.0005;
		end

 	end


		local randb = math.random(-4,4);


		local recoil = self.recoil
		local recoilrand = randb * recoil;

		self.RotAngle = self.RotAngle + recoilrand;

if not self:IsActivated() then
	if recoil > 0 then
		self.recoil = recoil - self.recoilcooldown;

	elseif recoil < 0 then
		self.recoil = 0;
	end

end
end




end 