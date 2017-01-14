function Create(self)
	self.recoil = 0;
 
	self.ff = false;
 
	self.f0 = ToMagazine(self.Magazine).RoundCount;
 
	self.f1 = ToMagazine(self.Magazine).RoundCount;


end



function Update(self)

if self.RootID ~= self.ID then
if self:IsReloading() then
	self.recoil = 0.0;
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
		local recoil2 = self.recoil;
		if recoil2 < 0.03 then
			local actor = MovableMan:GetMOFromID(self.RootID);
			self.recoil = recoil2 + 0.001 + (4 - actor.Sharpness) * 0.6 * 0.0005;
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