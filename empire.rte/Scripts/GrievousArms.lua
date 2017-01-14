
dofile("Base.rte/Constants.lua")
require("Actors/AI/NativeHumanAI")	--dofile("Base.rte/Actors/AI/NativeHumanAI.lua")

function Create(self)


	self.mapwrapx = SceneMan.SceneWrapsX;
	self.garbTimer = Timer(); 

	self.AI = NativeHumanAI:Create(self)


local curdist = 40;

for actor in MovableMan.Actors do
	if SceneMan:ShortestDistance(self.Pos,actor.Pos,SceneMan.SceneWrapsX).Magnitude < 30 and actor.PresetName == "General Grievous" and actor.Team == self.Team then
		self.parent = ToActor(actor);
	end
end
				

end

function Update(self)

local health = self.Health;

if health > 0 then

	if not self:HasObject("Grievous Lightsaber Green 2") then
		local hook = CreateHDFirearm("Grievous Lightsaber Green 2");
		self:AddInventoryItem(hook);
	end

	if not self:HasObject("Grievous Lightsaber Blue 2") then
		local hook = CreateHDFirearm("Grievous Lightsaber Blue 2");
		self:AddInventoryItem(hook);
	end



   	self:GetController():SetState(Controller.CIM_AI,true);
	local ownCont = self.parent:GetController();

		self:GetController():SetState(Controller.BODY_CROUCH,false);
--		self:GetController():SetState(Controller.WEAPON_FIRE,false);

if self.parent then

	self.ToDelete = false

	self.Age = 0


	self:ClearForces()


	if self.garbTimer:IsPastSimMS(2750) then
		collectgarbage("collect");
		self.garbTimer:Reset();
		if health < 100 then
			self.Health = health + 1;
		end
	end  


--	    self:GetController():SetState(Controller.CIM_AI,false);
	self:GetController():SetState(Controller.CIM_AI,true);

	if ownCont:IsState(14) then
		self:GetController():SetState(Controller.WEAPON_FIRE,true);
	else
		self:GetController():SetState(Controller.WEAPON_FIRE,false);
	end

            if ownCont:IsState(3) then
               self:GetController():SetState(Controller.HOLD_RIGHT,true);
            elseif ownCont:IsState(4) then
               self:GetController():SetState(Controller.HOLD_LEFT,true);
            elseif ownCont:IsState(13) then
                  self:GetController():SetState(Controller.AIM_SHARP,true);
	    else
		self:GetController():SetState(Controller.BODY_CROUCH,false);
		self:GetController():SetState(Controller.WEAPON_FIRE,false);
            end

     if self:IsPlayerControlled() then
	ActivityMan:GetActivity():SwitchToActor(self.parent, self:GetController().Player, self.Team)
     end


else
	self:GibThis();
end


end

self:MoveOutOfTerrain(-20)
end


function UpdateAI(self)
	self.AI:Update(self)
end
