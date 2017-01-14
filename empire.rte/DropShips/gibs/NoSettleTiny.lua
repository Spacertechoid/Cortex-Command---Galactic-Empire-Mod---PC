function Create(self)

self.ExplodeTimer = Timer();
self.explodetime = 300;

	local explode = CreateMOSRotating("ISD Explosion Tertiary");

	explode.Pos.X = self.Pos.X + math.random(-55,55);
	explode.Pos.Y = self.Pos.Y + math.random(-35,35);

	MovableMan:AddParticle(explode);
end

function Update(self)
	self.ToSettle = false;

if self.ExplodeTimer:IsPastSimMS(self.explodetime) then
	local explode = CreateMOSRotating("ISD Explosion Tertiary");

	explode.Pos.X = self.Pos.X + math.random(-55,55);
	explode.Pos.Y = self.Pos.Y + math.random(-35,35);

	MovableMan:AddParticle(explode);
	self.ExplodeTimer:Reset();
	self.explodetime = math.random(65,227);
end

end