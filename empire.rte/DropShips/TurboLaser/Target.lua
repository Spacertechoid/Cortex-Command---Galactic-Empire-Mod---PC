
function Update(self)

local vect = Vector(1700,0);
local rayL = 0;

	vect = vect:RadRotate(self.RotAngle);
	vect = vect:SetMagnitude(1700);
	rayL = SceneMan:CastObstacleRay(Vector(self.Pos.X,self.Pos.Y),vect,vect,vect,self.ID,self.Team,0,3);


if rayL>0 then
	local part = CreateMOPixel("ISD Target Reticle");
	part.Pos = SceneMan:GetLastRayHitPos();
	MovableMan:AddParticle(part);
end

end