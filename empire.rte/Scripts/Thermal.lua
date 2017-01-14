function Create(self)		
end

function Update(self)

	if self:IsActivated() == true then

	   if self.RootID == self.ID then

		self:MoveOutOfTerrain(-10);

		if not self.timer then
			self.timer = Timer();
			self.a = 0
			self.armed = CreateMOPixel("Thermal Grenade Armed Effect")
		end
		
		self.armed = CreateMOPixel("Thermal Grenade Armed Effect")
		self.armed.Pos = self.Pos

		self.tick = CreateAEmitter("Grenade Tick")
		self.tick.Pos = self.Pos
	
		if self.timer:IsPastSimMS(800) and self.a == 0 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 1;
		elseif self.timer:IsPastSimMS(600) and self.a == 1 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 2;
		elseif self.timer:IsPastSimMS(400) and self.a == 2 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 3;
		elseif self.timer:IsPastSimMS(350) and self.a == 3 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 4;
		elseif self.timer:IsPastSimMS(250) and self.a == 4 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 5;
		elseif self.timer:IsPastSimMS(175) and self.a == 5 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 6;
		elseif self.timer:IsPastSimMS(125) and self.a == 6 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 7;
		elseif self.timer:IsPastSimMS(75) and self.a == 7 then
			self.armed = CreateMOPixel("Thermal Grenade Armed Effect 2");
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 8;
		elseif self.timer:IsPastSimMS(75) and self.a == 8 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 9;
		elseif self.timer:IsPastSimMS(75) and self.a == 9 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 10;
		elseif self.timer:IsPastSimMS(75) and self.a == 10 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 11;
		elseif self.timer:IsPastSimMS(75) and self.a == 11 then
			MovableMan:AddParticle(self.armed)
			MovableMan:AddParticle(self.tick);
			self.timer:Reset()
			self.a = 12;
		elseif self.timer:IsPastSimMS(50) and self.a == 12 then

			local Payload = CreateMOSRotating("Thermal Detonator Payload", "Empire.rte")
			if Payload then
				Payload.Pos = self.Pos
				MovableMan:AddParticle(Payload)
				Payload:GibThis()
			end

			self:GibThis()
		end
	   end
	end
end
		
-----------------------------------------------------------
--