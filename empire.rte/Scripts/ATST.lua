
dofile("Base.rte/Constants.lua")
require("Actors/AI/NativeHumanAI")	--dofile("Base.rte/Actors/AI/NativeHumanAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.AngularVel = self.AngularVel*0.97;
end

function Update(self)
	self.AngularVel = self.AngularVel*0.85;

	self:GetController():SetState(Controller.BODY_CROUCH,false);

	self:GetController():SetState(Controller.WEAPON_PICKUP,false); 
	self:GetController():SetState(Controller.WEAPON_DROP,false);

	if self.Health < 0 or self.ToSettle == true then
		local terrcheck = Vector(0,0);

		local ray = SceneMan:CastStrengthRay(self.Pos,Vector(0,35),0,terrcheck,1,0,true);
	
		if ray == true then
			self:GibThis()
		end
	end

end

function UpdateAI(self)
	self.AI:Update(self)
end
