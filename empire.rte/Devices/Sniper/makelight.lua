function Create(self)
self.Mass = 0.1
self.Sharpness = 37

local velFactor = FrameMan.PPM * TimerMan.DeltaTimeSecs; 
local checkVect = self.Vel * velFactor; 
local moid = SceneMan:CastMORay(self.Pos,checkVect,self.ID,self.Team,0,false,0); 
	if moid ~= 255 and moid ~= 0 then 
		self.Mass =  0.01
		self.Sharpness = 0
	else
		self.Mass = 0.15
		self.Sharpness = 9
	end 		

end

function Update(self)

local velFactor = FrameMan.PPM * TimerMan.DeltaTimeSecs; 
local checkVect = self.Vel * velFactor; 
local moid = SceneMan:CastMORay(self.Pos,checkVect,self.ID,self.Team,0,false,0); 
	if moid ~= 255 and moid ~= 0 then 
		self.Mass =  0.01
		self.Sharpness = 0
	else
		self.Mass = 0.13
		self.Sharpness = 9
	end 		


end