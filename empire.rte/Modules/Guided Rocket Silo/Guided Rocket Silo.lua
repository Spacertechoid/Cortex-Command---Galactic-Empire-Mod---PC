 --     __           _         _            _   _
--  /\ \ \__ _ _ __| | ____ _| | ___ _ __ | |_(_) ___
-- /  \/ / _` | '__| |/ / _` | |/ _ \ '_ \| __| |/ __|
--/ /\  / (_| | |  |   < (_| | |  __/ |_) | |_| | (__
--\_\ \/ \__,_|_|  |_|\_\__,_|_|\___| .__/ \__|_|\___|
--                                  |_|
-- /Narkaleptic/              narkaleptic@mainelan.net

function Create( self )

	self.Center = Vector( self.Pos.X, self.Pos.Y );	

	self.Rocket = false;

	self.States = { VACANT = 0, ARRIVING = 1, DEPARTING = 2, OCCUPIED = 3 };
	self.State = self.States.VACANT;
	
	self.Lights = { RED = 0, RED_FLASHING = 1, GREEN = 2 };
	self.LightTimer = Timer();
	
	self.GuidingTimer = Timer();
	self.SimulationTimer = Timer();
	self.LastSimTime = self.SimulationTimer.ElapsedSimTimeMS;
	
end

function Update( self )

	self.DeltaTime = ( self.SimulationTimer.ElapsedSimTimeMS - self.LastSimTime ) / 1000;
	self.LastSimTime = self.SimulationTimer.ElapsedSimTimeMS;
	
	if not self.Rocket then
		CheckForRocket( self )
	end
	
	if self.Rocket then
		MaintainRocket( self )
	end

	if self.State == self.States.VACANT then
		ShowLights( self, self.Lights.GREEN )
	elseif self.State == self.States.OCCUPIED then
		ShowLights( self, self.Lights.RED )
	else
		ShowLights( self, self.Lights.RED_FLASHING )
	end
	
end

function CheckForRocket( self )

	-- Examine all rockets
	local BestRocket, BestRocketDistance = false, 0
	for Rocket in MovableMan.Actors do
	
		-- Check for a landing, own team rocket
		if Rocket.Team == self.Team
		and Rocket.ClassName == "ACRocket" 
		and Rocket.AIMode ~= Actor.AIMODE_RETURN then

			-- If rocket is over the bay
			if Rocket.Pos.X > self.Center.X - 64 
			and Rocket.Pos.X < self.Center.X + 64 then
				BestRocket = Rocket
				break;
			end
			
		end
		
	end

	if BestRocket then
		print( "Guided Rocket Silo: Found a landing rocket" );
		self.Rocket = BestRocket;
		self.State = self.States.ARRIVING;
	else
		self.Rocket = false;
		self.State = self.States.VACANT;
	end
	
end

function MakeVacant( self )
	print( "Guided Rocket Silo: Rocket tracking ended" );
	self.Rocket = false;
	self.State = self.States.VACANT;
end

function MaintainRocket( self )

	-- Only think four times per second
	if not self.Rocket.AIMode == Actor.AIMODE_RETURN
	and not self.GuidingTimer:IsPastSimMS( 100 ) then
		return
	end
	self.GuidingTimer:Reset();

	-- If our rocket is gone, mark as vacant.
	if not MovableMan:IsActor( self.Rocket ) then
		MakeVacant( self );
		return;
	end
	
	local Rocket = self.Rocket
	local RocketPos = Rocket.Pos
	local Center = self.Center
	local HalfPI = math.pi / 2;

	-- If our rocket is too far away, mark as vacant
	if RocketPos.X < Center.X - 64 
	or RocketPos.X > Center.X + 64 then
		MakeVacant( self );
		return;
	end

	-- Push away other rockets
	for Rocket in MovableMan.Actors do
		if Rocket.ClassName == "ACRocket" 
		and Rocket.Team == self.Team
		and Rocket.ID ~= self.Rocket.ID then
		
			-- If rocket is over the bay
			if Rocket.Pos.X > self.Center.X - 64 
			and Rocket.Pos.X < self.Center.X + 64 then

				local DistanceX = math.min( 1, math.max( -1, ( Center.X - Rocket.Pos.X ) / 64 ) );
				local TargetVelocity = math.cos( DistanceX * HalfPI ) * -10;
				Rocket.Vel.X = Approach( Rocket.Vel.X, TargetVelocity, 14 * self.DeltaTime );
					
			end
			
		end		
	end
		
	-- Guide the rocket when it enters the silo
	local DistanceY = Center.Y - RocketPos.Y;	
	
	if DistanceY < 256 then
	
		local DistanceY = math.min( 1, math.max( 0, ( Center.Y - 128 - RocketPos.Y ) / 96 ) );
		local MaximumX = math.sin( DistanceY * HalfPI ) * 24;
		local DistanceY = math.min( 1, math.max( 0, ( Center.Y - 128 - RocketPos.Y ) / 96 ) );
		local MaximumAngle = math.sin( DistanceY * HalfPI / 2 );
		local MaximumDrop = math.sin( DistanceY * HalfPI / 2 ) * 50 + 5;
		
		Rocket.Pos.X = math.min( Center.X + MaximumX, math.max( Center.X - MaximumX, Rocket.Pos.X ) );
		Rocket.RotAngle = math.min( MaximumAngle, math.max( -MaximumAngle, Rocket.RotAngle ) );
		Rocket.Vel.Y = math.min( MaximumDrop, Rocket.Vel.Y );
		if MaximumAngle < 0.01 then
			Rocket.AngularVel = 0;
			Rocket.Vel.X = 0;
			Rocket.Vel.Y = Rocket.Vel.Y * 0.9;
			self.State = self.States.OCCUPIED;
		else
			if Rocket.AIMode ~= Actor.AIMODE_RETURN then
				self.State = self.States.ARRIVING;
			else
				self.State = self.States.DEPARTING;
			end
		end
	
	elseif DistanceY >= 256 then

		-- Guide the rocket into the mouth of the silo
		local DistanceX = math.min( 1, math.max( -1, ( Center.X - RocketPos.X ) / 64 ) );
		if math.abs( DistanceX ) > 0.25 then
			local TargetVelocity = math.sin( DistanceX * HalfPI ) * 10;
			Rocket.Vel.X = Approach( Rocket.Vel.X, TargetVelocity, 14 * self.DeltaTime );
		end
		
	end

end

function SetBulb( self, EmitterName, Visible, Pos )

	if Visible and not MovableMan:IsParticle( self[EmitterName] ) then
		local Emitter = CreateAEmitter( EmitterName, "Zombie.rte" );
		Emitter:EnableEmission( true );
		Emitter.Pos = Pos;
		MovableMan:AddParticle( Emitter );
		self[EmitterName] = Emitter;
	elseif not Visible and MovableMan:IsParticle( self[EmitterName] ) then
		self[EmitterName].Lifetime = 1;
		self[EmitterName] = nil;
	end
	
end

function ShowLights( self, Mode )

	if self.LightTimer:IsPastSimMS( 500 ) then
	
		local PixelLeft, PixelRight
		if Mode == self.Lights.RED then
			PixelLeft = CreateMOPixel( "Red Light", "Zombie.rte" );
			PixelRight = CreateMOPixel( "Red Light", "Zombie.rte" );
		elseif Mode == self.Lights.RED_FLASHING then
			PixelLeft = CreateMOPixel( "Red Light Flashing", "Zombie.rte" );
			PixelRight = CreateMOPixel( "Red Light Flashing", "Zombie.rte" );
		else
			PixelLeft = CreateMOPixel( "Green Light", "Zombie.rte" );
			PixelRight = CreateMOPixel( "Green Light", "Zombie.rte" );
		end

		local Left = Vector( self.Center.X - 45, self.Center.Y - 230 );
		local Right = Vector(  self.Center.X + 45, self.Center.Y - 230 );
		
		SetBulb( self, "Left Red Hyper Bulb", Mode == self.Lights.RED, Left );
		SetBulb( self, "Right Red Hyper Bulb", Mode == self.Lights.RED, Right );
		SetBulb( self, "Left Orange Hyper Bulb", Mode == self.Lights.RED_FLASHING, Left );
		SetBulb( self, "Right Orange Hyper Bulb", Mode == self.Lights.RED_FLASHING, Right );
		SetBulb( self, "Left Green Hyper Bulb", Mode == self.Lights.GREEN, Left );
		SetBulb( self, "Right Green Hyper Bulb", Mode == self.Lights.GREEN, Right );

		PixelLeft.Pos = Left + Vector( 10, -2 );
		PixelRight.Pos = Right - Vector( 10, 2 );
		
		MovableMan:AddParticle( PixelLeft );		
		MovableMan:AddParticle( PixelRight );
		
		self.LightTimer:Reset()
		
	end

end

function Approach( cur, target, inc )

	inc = math.abs( inc )

	if cur < target then
		
		return math.min( cur + inc, target )

	elseif cur > target then

		return math.max( cur - inc, target )

	end

	return target
	
end