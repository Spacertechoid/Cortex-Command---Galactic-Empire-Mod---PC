
dofile("Base.rte/Constants.lua")
require("Actors/AI/NativeHumanAI")	--dofile("Base.rte/Actors/AI/NativeHumanAI.lua")

function Create(self)

	self.mapwrapx = SceneMan.SceneWrapsX;

	self.garbTimer = Timer(); 

	self.RearmTimer = Timer();
	self.FireTimer = Timer();
	self.recentlyfired = 0;

	self.AI = NativeHumanAI:Create(self)
end

function Update(self)

local health = self.Health;
  if health > 0 then

	if not self:HasObject("Thermal Detonator") and self.RearmTimer:IsPastSimMS(5350) then
		local hook = CreateTDExplosive("Thermal Detonator");
		self:AddInventoryItem(hook);
		self.RearmTimer:Reset();
		print("rearm");
	end



	self:ClearForces()
	self.AngularVel = self.AngularVel * 0.97;

if self:GetController():IsState(Controller.WEAPON_FIRE) then

   if self.EquippedItem.PresetName == "Thermal Detonator" then
		self.RearmTimer:Reset();
   end


   if self.EquippedItem.PresetName == "DC-17" then
	if ToHDFirearm(self.EquippedItem):IsActivated() and not ToHDFirearm(self.EquippedItem):IsReloading() then
		if self.recentlyfired == 0 then
			self.recentlyfired = 1;
			self.FireTimer:Reset();
		end
	end
   end

   if self.recentlyfired == 1 and not self.FireTimer:IsPastSimMS(157) then
		for i = 0, MovableMan:GetMOIDCount() do
			if MovableMan:GetRootMOID(i) == self.ID then
				local object = MovableMan:GetMOFromID(i);
				if object.PresetName == "DC-17 Offhand" then
					ToHDFirearm(object):Deactivate();
				end
			end
		end
   end
else
	self.recentlyfired = 0
end

	if self.garbTimer:IsPastSimMS(3500 - (100 - health)*10) then
		collectgarbage("collect");
		self.garbTimer:Reset();
		if health < 100 then
			self.Health = health + 1;
		end
	end  
  end

end

function UpdateAI(self)
	self.AI:Update(self)
end
