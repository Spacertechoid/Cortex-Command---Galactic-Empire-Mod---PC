function Create(self)
self.ExplodeTimer = Timer();
self.explodetime = 300;
end

function Update(self)
	self.ToSettle = false;

if self.ExplodeTimer:IsPastSimMS(self.explodetime) then
	local explode = CreateMOSRotating("ISD Explosion Secondary");

	explode.Pos.X = self.Pos.X + math.random(-305,12);
	explode.Pos.Y = self.Pos.Y + math.random(-195,20);

	MovableMan:AddParticle(explode);
	self.ExplodeTimer:Reset();
	self.explodetime = math.random(25,127);
end

end