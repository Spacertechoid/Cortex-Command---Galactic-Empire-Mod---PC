require("Actors/AI/PID")

function Create(self)
	---------------- AI variables start ----------------
	self.StuckTimer = Timer()
	self.HatchTimer = Timer(50)
	self.Loiter = Timer()
	
	self.AvoidTimer = Timer()
	self.AvoidTimer:SetSimTimeLimitMS(500)
	
	self.PlayerInterferedTimer = Timer()
	self.PlayerInterferedTimer:SetSimTimeLimitMS(500)
	
	if self.AIMode == Actor.AIMODE_DELIVER and self:IsInventoryEmpty() then
		self.AIMode = Actor.AIMODE_STAY	-- Stop the craft from returning to orbit immediately
	end
	
	self.Controller = self:GetController()
	self.LastAIMode = Actor.AIMODE_STAY
	
	-- The drop ship tries to hover this many pixels above the ground
	if self.AIMode == Actor.AIMODE_BRAINHUNT then
		self.hoverAlt = self.Radius * 10
	elseif self.AIMode == Actor.AIMODE_GOTO then
		self.hoverAlt = self.Radius * 10
	else
		self.hoverAlt = self.Radius * 10
	end
	-- The drop ship tries to hover this many pixels above the ground
	if Members.AIMode == Actor.AIMODE_BRAINHUNT then
		Members.hoverAlt = Owner.Radius * 10
	elseif Members.AIMode == Actor.AIMODE_BOMB then
		Members.hoverAlt = Owner.Radius * 10
	elseif Members.AIMode == Actor.AIMODE_BOMB then
		Members.hoverAlt = Owner.Radius * 10
	else
		Members.hoverAlt = Owner.Radius * 10
	end
	
	-- The controllers
	self.XposPID = RegulatorPID:New{p=0.05, i=0.01, d=2.5, filter_leak=0.8, integral_max=50}
	self.YposPID = RegulatorPID:New{p=0.1, d=2.5, filter_leak=0.6}
	
	---------------- AI variables end ----------------

	--working variables
	self.garbTimer = Timer();  
	self.Turret = {};


	self.Turret[16] = CreateACrab("ISD Turbo Laser Control");
	self.Turret[16].Team = self.Team;
	MovableMan:AddActor(self.Turret[16]);
	self.Turret[16].Offset = Vector(0,-39);

	self.Turret[17] = CreateACrab("ISD Turbo Laser Control");
	self.Turret[17].Team = self.Team;
	MovableMan:AddActor(self.Turret[17]);
	self.Turret[17].Offset = Vector(0,70);
end

function Update(self)

	self.AIMode = Actor.AIMODE_STAY


if self.Health > 1 then
	-- Stabilize
	if self.RotAngle > 0.2 then
		self.AngularVel = self.AngularVel - 0.2
	elseif self.RotAngle < -0.2 then
		self.AngularVel = self.AngularVel + 0.2
	else
		self.AngularVel = self.AngularVel * 0.98
	end 

end

	--update turret spatial properties
	for i = 16, 17 do
		if MovableMan:IsActor(self.Turret[i]) == true then
			--basic turret position upkeep (so it doesn't fall at 999999m/s)
			self.Turret[i].Vel.X = 0;
			self.Turret[i].Vel.Y = 0;
			--update turret position
			self.Turret[i].RotAngle = self.RotAngle;
			self.Turret[i].Pos = self.Pos + self:RotateOffset(self.Turret[i].Offset)
		end
	end

--GARBAGE COLLECTION 
if self.garbTimer:IsPastSimMS(10000) then
	collectgarbage("collect");
	self.garbTimer:Reset();
end  

end


function UpdateAI(self)
	if self.AIMode ~= self.LastAIMode then	-- We have new orders
		self.LastAIMode = self.AIMode
		
		if self.AIMode == Actor.AIMODE_RETURN then
			if health > 50 --hang around and shoot shit before leaving, 911pm test
			self.CraftDeliverySequence = ACraft.HOVER
			self.AIMode = Actor.AIMODE_STAY
			else
			self.CraftDeliverySequence = ACraft.HOVER
			self.AIMode = Actor.AIMODE_STAY
//			self.AIMode = Actor.AIMODE_RETURN
			end
		else -- Actor.AIMODE_STAY and Actor.AIMODE_DELIVER
			local FuturePos = self.Pos + self.Vel*20
			
			-- Make sure FuturePos is inside the scene
			if FuturePos.X > SceneMan.SceneWidth then
				if SceneMan.SceneWrapsX then
					FuturePos.X = FuturePos.X - SceneMan.SceneWidth
				else
					FuturePos.X = SceneMan.SceneWidth - self.Radius
				end
			elseif FuturePos.X < 0 then
				if SceneMan.SceneWrapsX then
					FuturePos.X = FuturePos.X + SceneMan.SceneWidth
				else
					FuturePos.X = self.Radius
				end
			end
			
			-- Use self:GetLastAIWaypoint() as a LZ so the AI can give orders to dropships
			local Wpt = self:GetLastAIWaypoint()
			if (self.Pos - Wpt).Largest > 1 then
				self.Waypoint = Wpt
			else
				local WptL = SceneMan:MovePointToGround(self.Pos-Vector(self.Radius, 0), self.hoverAlt, 532)
				local WptC = SceneMan:MovePointToGround(self.Pos, self.hoverAlt, 532)
				local WptR = SceneMan:MovePointToGround(self.Pos+Vector(self.Radius, 0), self.hoverAlt, 532)
				self.Waypoint = Vector(self.Pos.X, math.min(WptL.Y, WptC.Y, WptR.Y))
			end
			
			self.CraftDeliverySequence = ACraft.FALL
		end
	end
	
	if self.PlayerInterferedTimer:IsPastSimTimeLimit() then
		self.StuckTimer:Reset()
		
		local FuturePos = self.Pos + self.Vel*20
		
		-- Make sure FuturePos is inside the scene
		if FuturePos.X > SceneMan.SceneWidth then
			if SceneMan.SceneWrapsX then
				FuturePos.X = FuturePos.X - SceneMan.SceneWidth
			else
				FuturePos.X = SceneMan.SceneWidth - self.Radius
			end
		elseif FuturePos.X < 0 then
			if SceneMan.SceneWrapsX then
				FuturePos.X = FuturePos.X + SceneMan.SceneWidth
			else
				FuturePos.X = self.Radius
			end
		end
		
		local Dist = SceneMan:ShortestDistance(FuturePos, self.Waypoint, false)
		if math.abs(Dist.X) > 100 then
			if self.CraftDeliverySequence == ACraft.LAUNCH then
				
				self.Waypoint.Y = self.hoverAlt -- 9pm test
//				self.Waypoint.X = FuturePos.X
//				self.Waypoint.Y = -500

			else
				local WptL = SceneMan:MovePointToGround(self.Pos-Vector(self.Radius, 0), self.hoverAlt, 552)
				local WptC = SceneMan:MovePointToGround(self.Pos, self.hoverAlt, 552)
				local WptR = SceneMan:MovePointToGround(self.Pos+Vector(self.Radius, 0), self.hoverAlt, 552)
				self.Waypoint = Vector(self.Pos.X, math.min(WptL.Y, WptC.Y, WptR.Y))
			end
		end
	end
	
	self.PlayerInterferedTimer:Reset()
	
	-- Control right/left movement
	local Dist = SceneMan:ShortestDistance(self.Pos+self.Vel*30, self.Waypoint, false)
	local change = self.XposPID:Update(Dist.X, 0)
	if change > 2 then
		self.Controller.AnalogMove = Vector(change/30, 0)
	elseif change < -2 then
		self.Controller.AnalogMove = Vector(change/30, 0)
	end
	
	-- Control up/down movement
	Dist = SceneMan:ShortestDistance(self.Pos+self.Vel*5, self.Waypoint, false)
	change = self.YposPID:Update(Dist.Y, 0)
	if change > 2 then
		self.AltitudeMoveState = ACraft.DESCEND
	elseif change < -2 then
		self.AltitudeMoveState = ACraft.ASCEND
	end
	
	-- Delivery Sequence logic
	if self.CraftDeliverySequence == ACraft.FALL then
		-- Don't descend if we have nothing to deliver
		if self:IsInventoryEmpty() and self.AIMode ~= Actor.AIMODE_NONE then
				self.CraftDeliverySequence = ACraft.HOVER
				self.HatchTimer:Reset()
			end
		else
			local dist = SceneMan:ShortestDistance(self.Pos, self.Waypoint, false).Magnitude
			if dist < self.Radius and math.abs(change) < 3 and math.abs(self.Vel.X) < 4 then	-- If we passed the hover check, check if we can start unloading
				local WptL = SceneMan:MovePointToGround(self.Pos+Vector(-self.Radius, -self.Radius), self.hoverAlt, 652)
				local WptC = SceneMan:MovePointToGround(self.Pos+Vector(0, -self.Radius), self.hoverAlt, 652)
				local WptR = SceneMan:MovePointToGround(self.Pos+Vector(self.Radius, -self.Radius), self.hoverAlt, 652)
				self.Waypoint = Vector(self.Pos.X, math.min(WptL.Y, WptC.Y, WptR.Y))
				
				dist = SceneMan:ShortestDistance(self.Pos, self.Waypoint, false).Magnitude
				if dist < 900 then
					-- We are close enough to our waypoint
					if self.AIMode == Actor.AIMODE_STAY then
						self.CraftDeliverySequence = ACraft.HOVER
				-- Check for something in the way of our descent, and hover to the side to avoid it
				if self.AvoidTimer:IsPastSimTimeLimit() then
					self.AvoidTimer:Reset()
					self.search = not self.search	-- Search every second update
					if self.search then
						local obstID = self:DetectObstacle(self.Diameter + self.Vel.Magnitude * 70)
						if obstID > 0 and obstID < 555 then
							local MO = MovableMan:GetMOFromID(MovableMan:GetRootMOID(obstID))
							if MO.ClassName == "ACDropShip" or MO.ClassName == "ACRocket" then
//								self.AvoidMoveState = ACraft.HOVER
								self.Waypoint.X = self.Waypoint.X + self.Diameter * 4
							end
						else
							self.AvoidMoveState = nil
						end
					else	-- Avoid terrain
						local Free = Vector()
						local Start = self.Pos + Vector(self.Radius, 0)
						local Trace = self.Vel * (self.Radius/2) + Vector(0,50)
						if PosRand() < 0.5 then
							Start.X = Start.X - self.Diameter
						end
						
						if SceneMan:CastStrengthRay(Start, Trace, 0, Free, 4, 0, true) then
							self.Waypoint.X = self.Pos.X
							self.Waypoint.Y = Free.Y - self.hoverAlt
						end
					end
				end
					else
						self.CraftDeliverySequence = ACraft.UNLOAD
						self.HatchTimer:Reset()			
						Owner:OpenHatch()						
					end
				end
			else
//				if self.AvoidMoveState then
//					self.CraftDeliverySequence = ACraft.HOVER
				end
			end
		end
	elseif self.CraftDeliverySequence == ACraft.UNLOAD then
		if self.HatchTimer:IsPastSimMS(50) then	-- Start unloading if there's something to unload
			self.HatchTimer:Reset()
			self:OpenHatch()
			
			if self.AIMode == Actor.AIMODE_BRAINHUNT and self:HasObjectInGroup("Brains") then
				self.AIMode = Actor.AIMODE_RETURN
			else
				self.CraftDeliverySequence = ACraft.FALL
			end
		end
	elseif self.CraftDeliverySequence == ACraft.LAUNCH then
		if self.HatchTimer:IsPastSimMS(300) then
			self.HatchTimer:Reset()
			self:CloseHatch()
			self.AIMode = Actor.AIMODE_STAY
		end
	end
	
	-- Input translation
	if self.AltitudeMoveState == ACraft.ASCEND then
		self.Controller:SetState(Controller.MOVE_UP, true)
	elseif self.AltitudeMoveState == ACraft.DESCEND then
		self.Controller:SetState(Controller.MOVE_DOWN, true)
	else
		self.Controller:SetState(Controller.MOVE_UP, false)
		self.Controller:SetState(Controller.MOVE_DOWN, false)
	end
	
	-- If we are hopelessly stuck, self destruct
	if self.Vel.Largest > 3 or self.AIMode == Actor.AIMODE_STAY then
		self.StuckTimer:Reset()
	elseif self.AIMode == Actor.AIMODE_SCUTTLE or self.StuckTimer:IsPastSimMS(4000) then
		self:GibThis()
	end
end