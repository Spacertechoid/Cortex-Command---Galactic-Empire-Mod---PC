function Create(self)

	self.recoil = 0;
 
	self.ff = false;
 
	self.f0 = ToMagazine(self.Magazine).RoundCount;
 
	self.f1 = ToMagazine(self.Magazine).RoundCount;

	self.firecounter = 0;
	self.recoilcooldown = 0.00013;

end



function Update(self)

if self.RootID ~= self.ID then


	if self:IsReloading() then
		self.recoil = 0.0;
	end



	local vect = Vector(500,0);
	local rayL = 0;

	if self.HFlipped then
		angleadd = self.RotAngle + math.pi;
	else
		angleadd = self.RotAngle;
	end

	vect = vect:RadRotate(angleadd);
	vect = vect:SetMagnitude(800);
	rayL = SceneMan:CastObstacleRay(Vector(self.Pos.X,self.Pos.Y-5),vect,vect,vect,self.ID,self.Team,0,3);

	if rayL>0 then
		local part = CreateMOPixel("PTrail");
		part.Pos = SceneMan:GetLastRayHitPos();
		MovableMan:AddParticle(part);
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
			self.recoil = recoil2 + 0.0015 + (4 - actor.Sharpness) * 0.65 * 0.0005;
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


end 