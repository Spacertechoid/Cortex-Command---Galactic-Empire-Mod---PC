function Create(self)
	self.GibTimer = Timer()
	
	if math.random() > 0.5 then
		self.AngularVel = -math.random(1, 3)
		self.Vel = Vector(math.random(1, 3), 5)
	else
		self.AngularVel = math.random(1, 3)
		self.Vel = Vector(-math.random(1, 5), 5)
	end
end

function Update(self)
	if self.GibTimer:IsPastSimMS(500) then
		self:GibThis()
	elseif self.Vel.Largest > 5 then
		self.GibTimer:Reset()
	end
end

function Destroy(self)
	ActivityMan:GetActivity():ReportDeath(self.Team, -1)
end
