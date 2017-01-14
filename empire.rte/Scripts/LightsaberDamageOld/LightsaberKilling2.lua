function Create(self)

local velFactor = FrameMan.PPM * TimerMan.DeltaTimeSecs; 
local checkVect = self.Vel * velFactor; 
local moid = SceneMan:CastMORay(self.Pos,checkVect,self.ID,self.Team,0,false,0); 
	if moid ~= 255 and moid ~= 0 then 
		self.Mass =  0.05
		self.Sharpness = 1000
		self.Vel = self.Vel * 0.6;

			local hitMO = MovableMan:GetMOFromID(moid);
			self.target = hitMO

	else
		self.Mass = 0.005
		self.Sharpness = 1
	end 
                           
end

function Update(self)

	self.HitsMOs = true;


	if self.target then
		local launch = SceneMan:ShortestDistance(self.Pos,self.target.Pos, true)
			if launch ~= 0 then
			local angle = SceneMan:ShortestDistance(self.Pos,self.target.Pos, true).AbsRadAngle
				if launch.Magnitude < 25 then
					self.Vel = Vector(25,0):RadRotate(angle);
				elseif launch.Magnitude > 50 then
					self.Vel = Vector(50,0):RadRotate(angle);
				else
					self.Vel = launch;
				end
			end

		self.Mass =  0.05
		self.Sharpness = 1000


	else
		self.Mass = 0.001
		self.Sharpness = 1
	end 

end