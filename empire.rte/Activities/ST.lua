--     __           _         _            _   _
--  /\ \ \__ _ _ __| | ____ _| | ___ _ __ | |_(_) ___
-- /  \/ / _` | '__| |/ / _` | |/ _ \ '_ \| __| |/ __|
--/ /\  / (_| | |  |   < (_| | |  __/ |_) | |_| | (__
--\_\ \/ \__,_|_|  |_|\_\__,_|_|\___| .__/ \__|_|\___|
--                                  |_|
-- /Narkaleptic/              narkaleptic@mainelan.net

function ZombieDefense1:StartActivity()

	print( "Zombie Defense initializing!" );

	self.Zone = SceneMan.Scene:GetArea("Sith Training");


	self.FightStage = { NOFIGHT = 0, FIGHT = 1, AFTERMATH = 2, FIGHTSTAGECOUNT = 3 };
	self.Stage = self.FightStage.NOFIGHT;

	-- Timer to only run the updates every 250ms
	self.UpdateTimer = Timer();

	-- A timer to prevent overriding important messages
	self.MessageTimer = Timer();
	self.ImportantMessageTimer = Timer();

	self.GameOver = false;
	self.ZombieSpawnTime = 1500;

	-- Zombie Spawns
	self.ZombieSpawner = Timer();
	self.ZombieSpawnLeft = SceneMan.Scene:GetArea( "LeftSpawn" );
	self.ZombieSpawnRight = SceneMan.Scene:GetArea( "RightSpawn" );

	-- Zombie Stuck Locations
	self.ZombieStuck = SceneMan.Scene:GetArea( "Stuck" );

	-- Zombie Goal
	self.GoalArea = SceneMan.Scene:GetArea( "Goal" );

	-- Player Start
	self.ReinforceArea = SceneMan.Scene:GetArea( "Reinforce" );

	-- Rescue Shuttle
	self.RescueArea = SceneMan.Scene:GetArea( "Rescue" );
	self.RescuePoint = SceneMan:MovePointToGround( self.RescueArea:GetRandomPoint(), 1, 0 );

	-- Prevent purchasing
	ActivityMan:GetActivity():SetTeamFunds( 0, 0 );

	-- List of earned weapons
	self.WeaponLevel = 0;
	self.Weapons = {};

	-- Glock -> Desert Eagle -> Pumpgun -> M1 Garand -> Kar98 
	-- Uzi -> AK-47 -> M16 -> M60
	-- Thumper -> RPG-7 -> RPC M17
	

	self.StoryElements =
	{
		[0] = "You are stranded here...alone.",
		[1] = "Slay these hapless new recruits!",
		[2] = "Now destroy their squadmates. Do not hesitate!",
		[3] = "Break their fliers and show them that their sky prowess is no match for you!",
		[4] = "With every passing moment you make yourself more my slave!",
		[5] = "Show their battlefield elite that you will break even them.",
		[6] = "Do not fear their high powered rifles. Do not dissapoint me!",
		[7] = "New Jedi recruits. Show them the power of the Dark Side.",
		[8] = "You still live. Your training is nearly complete.",
		[9] = "Prove you are capable of defeating the Dark Trooper!",
		[10] = "Kill them. Kill them now."
	};

	-- Configure zombies
	self.ZombieTypes = { "Republic Clonetrooper Cadet" , "Empire.rte" };
	self.ZombieWeapons = { "E-11 Blastech Rifle" , "Empire.rte" };
	self.ZombieBombs = {}; --{ "Thermal Detonator" , "Empire.rte" };

	-- Track active zombie count and kills
	self.ZombieCount = 0;
	self.ZombieSpawned = 0;
	self.ZombieKilled = 0;
	self.ZombieCap = 12;

	-- Track wave status
	self.Wave = 0;
	self.WaveCap = 15;
	self.WaveCapCap = 100;
	self.WaveSpawned = 0;
	self.WaveKilled = 0;
	self.WaveTimer = Timer();
	self.WaveRest = 3000;
	self.WaveEndRest = 3000;

	print( "Zombie Defense has begun!" );

	function _G.Rescue()
		self:CreateRescueCraft();
	end

	function _G.Reinforce()
		--self:DropDefender();
	end	
	
	self.WaveTimer:Reset();
	FrameMan:SetScreenText( "\"" .. self.StoryElements[0] .. "\"", Activity.PLAYER_1, 0, -1, false );
end

function ZombieDefense1:PauseActivity()

end


function ZombieDefense1:EndActivity()

	self.GameOver = true;

	if self.WinnerTeam == Activity.TEAM_2 then
 		self:UpdateMessage( self.EndText );
	else
		self:UpdateMessage( "The circle is now complete!" );
 	end	

	_G.Rescue = nil;
	_G.Reinforce = nil;

end

function ZombieDefense1:UpdateMessage( Message )

	if Message then
		self.Message = Message;
		self.ImportantMessageTimer:Reset();
	elseif self.ImportantMessageTimer:IsPastRealMS( 6000 ) then
		self.Message = "";
	end

	if self.Wave and self.Wave > 0 then
		Message =
			"Wave " .. self.Wave .. " (" .. math.floor( (self.WaveKilled or 0) / (self.WaveCap or 1) * 100 ) .. "%)\n" ..
			"Kills: " .. tostring( self.ZombieKilled or 0 ) .. "\n" ..
			"Weapons: " .. table.concat( self.Weapons, ", " ) .. "\n";
	else
		Message = "";
	end

    FrameMan:ClearScreenText( Activity.PLAYER_1 );
	FrameMan:SetScreenText( Message .. "\n" .. self.Message, Activity.PLAYER_1, 0, -1, false );
	self:ResetMessageTimer( Activity.PLAYER_1 );
	
end

function ZombieDefense1:StartWave()

	print( "Initializing new wave..." );

	-- Prepare the variables for a new wave
	self.WaveCap = math.min( self.WaveCap + 5, self.WaveCapCap );
	self.WaveSpawned = 0;
	self.WaveKilled = 0;
	self.Wave = self.Wave + 1;

	self.Stage = self.FightStage.FIGHT;

	local Wave = self.Wave;

	self.ZombieTypes = { "Republic Clonetrooper" }; -- { "Spewer Medium", "Spewer Fat" };
	self.ZombieWeapons = {};
	self.ZombieBombs = {};
	self.ZombieRight = false;
	self.ZombieSpawnTime = 2700;
	self.ZombieCap = 6;
	self.ZombieRight = 0.50;

	for Item in MovableMan.Items do
		if Item.ClassName == "TDExplosive" then
			Item.ToDelete = true;
		end
	end


	if Wave >= 2 then

		table.insert( self.ZombieTypes, "Republic Clonetrooper" );
		for Defender in MovableMan.Actors do
			if Defender.Team == 0 and not Defender:IsDead() then
				if Defender.ClassName == "AHuman" then
					if Defender.Sharpness < 10 then
						ToActor(Defender).Sharpness = ToActor(Defender).Sharpness + 0.35;
					end
				end
			end
		end

	end

	if Wave == 2 then
		self.ZombieSpawnTime = 2600;
		self.ZombieCap = self.ZombieCap + 1;
		-- Send a reinforcement if a defender is lost

	end

	if Wave == 3 then
		-- Send a reinforcement if a defender is lost
		table.insert( self.ZombieTypes, "Republic Jump Trooper" );
		table.insert( self.ZombieTypes, "Republic Clonetrooper" );
	end

	if Wave == 4 then
		self.ZombieCap = self.ZombieCap + 1;
		table.insert( self.ZombieTypes, "Republic Jump Trooper" );
		table.insert( self.ZombieTypes, "Republic Scout Trooper" );
		self.ZombieSpawnTime = 2550;
	end

	if Wave == 5 then
		self.ZombieCap = self.ZombieCap + 2;
		table.insert( self.ZombieTypes, "Republic Scout Trooper" );
		table.insert( self.ZombieTypes, "Republic Clonetrooper Sergeant" );
		table.insert( self.ZombieTypes, "Republic Jump Trooper" );
	end

	if Wave == 6 then
		table.insert( self.ZombieTypes, "Republic Scout Trooper" );
		table.insert( self.ZombieTypes, "Republic Jump Trooper" );
		table.insert( self.ZombieTypes, "Republic Clonetrooper Sergeant" );
		table.insert( self.ZombieTypes, "Republic Clonetrooper Commander" );
		self.ZombieCap = self.ZombieCap + 2;
		self.ZombieSpawnTime = 2500;
	end

	if Wave == 7 then
		self.ZombieCap = self.ZombieCap + 2;
		table.insert( self.ZombieTypes, "Ronin Jedi Apprentice ST" );
		table.insert( self.ZombieTypes, "Republic Jump Trooper" );
		table.insert( self.ZombieTypes, "Republic Clonetrooper Sergeant" );
		table.insert( self.ZombieTypes, "Republic Clonetrooper Commander" );
		self.ZombieSpawnTime = 2350;
	end

	if Wave == 8 then
		self.ZombieSpawnTime = 2100;
		table.insert( self.ZombieTypes, "Republic ARC Trooper" );
	end

	if Wave == 9 then
		self.ZombieSpawnTime = 1900;
		table.insert( self.ZombieTypes, "Dark Trooper Phase Zero" );
	end


	if Wave == 9 then
		self.ZombieSpawnTime = 1700;
		table.insert( self.ZombieTypes, "AT-ST" );
		self.ZombieCap = self.ZombieCap + 1;
	end

	if Wave == 10 then
		self.ZombieSpawnTime = 1600;
		self.ZombieCap = self.ZombieCap + 1;
		table.insert( self.ZombieTypes, "Republic Scout Trooper" );
	end

	if Wave >= 10 then
		table.insert( self.ZombieTypes, "Republic Jump Trooper" );
		table.insert( self.ZombieTypes, "Republic Scout Trooper" );
	end

	if self.Wave == 11 then
		self.ZombieSpawnTime = 1450;
		self.ZombieCap = self.ZombieCap + 1;
		table.insert( self.ZombieTypes, "Ronin Jedi Knight ST" );
	end

	if Wave >= 12 then
		self.ZombieSpawnTime = 1350;
		table.insert( self.ZombieTypes, "Republic Clonetrooper" );
		table.insert( self.ZombieTypes, "Republic ARC Trooper" );
	end

	if Wave == 13 then
		self:CreateRescueCraft();
		table.insert( self.ZombieTypes, "Ronin Jedi Knight ST 2" );
	end

	print( "Wave " .. Wave .. " started!" );	
	
	-- Announce new wave
	self:UpdateMessage( "\"" .. self.StoryElements[Wave] .. "\"\n\nWave " .. self.Wave .. " has begun!" );
end

function ZombieDefense1:StopWave()

	print( "Stopping wave..." );

	-- Start countdown until wave end
	self.WaveTimer:Reset();

	-- Each time a zombie is killed, give more time, but don't do anything else.
	if self.Stage ~= self.FightStage.FIGHT then
		return
	end

	self.Stage = self.FightStage.AFTERMATH;

	-- Player has a moment to kill the last few zombies

end

function ZombieDefense1:EndWave()

	print( "Wave ended!" );

	-- Kill off the remaining zombies
	for Zombie in MovableMan.Actors do
		if Zombie.Team == 1 and Zombie.ClassName == "AHuman" and Zombie.Sharpness < 5 then
			Zombie.Health = 0;
			--Zombie:GibThis();
		end
	end
	self.ZombieCount = 0;

	-- Announce end of wave
	self:UpdateMessage( "Wave " .. self.Wave .. " has ended!" );		
	
	-- Start countdown until next wave
	self.WaveTimer:Reset();

	self.Stage = self.FightStage.NOFIGHT;


	if self.Wave == 6 then
		self:CreateReplacements();
	end


end

function ZombieDefense1:UpdateActivity()

	-- Only think four times per second
	if not self.UpdateTimer:IsPastSimMS( 250 ) then
		return
	end
	self.UpdateTimer:Reset();

	-- Update the HUD once per second
	if self.MessageTimer:IsPastRealMS( 1000 ) then
		self:UpdateMessage();
		self.MessageTimer:Reset();
	end

	-- Remove lingering items
	for Item in MovableMan.Items do
		if Item.ClassName == "HDFirearm" then
			if Item.PresetName ~= "Ventress Lightsaber Blue" and Item.PresetName ~= "Ventress Lightsaber Green" and Item.PresetName ~= "Maul's Staff" and Item.PresetName ~= "Grievous Lightsaber Blue" and Item.PresetName ~= "Grievous Lightsaber Green" and Item.PresetName ~= "Grievous Lightsaber Blue 2" and Item.PresetName ~= "Grievous Lightsaber Green 2" and Item.PresetName ~= "WESTAR-34" and Item.PresetName ~= "WESTAR-34 Offhand" and Item.PresetName ~= "Fett Arm Flamethrower" then
				Item.ToDelete = true;
			end
		end
	end

	-- Do not perform game logic if the game is over
	if self.GameOver then
		return
	end

	-- Count player actors
	local PlayerCount = 0;
	local SithCount = 0;
	for Defender in MovableMan.Actors do
		if Defender.Team == 0 and not Defender:IsDead() then
			if Defender.ClassName == "AHuman" then
				PlayerCount = PlayerCount + 1;
				if Defender.PresetName == "Darth Maul ST" then
					SithCount = SithCount + 1
				end
				if Defender.PresetName == "Asajj Ventress Jedi ST" then
					SithCount = SithCount + 1
				end
				if Defender.PresetName == "Jango Fett" then
					SithCount = SithCount + 1
				end
				self.PlayerActor = Defender
			end
		end
	end

	-- Check for living players
	-- Don't start the game until there is a player

	if SithCount == 0 then
		if self.Started then
			self.GameOver = true;
			self.WinnerTeam = Activity.TEAM_2;
			self.EndText = "You have perished.";
			ActivityMan:EndActivity();
		else
			return
		end
	elseif not self.Started then
		self.Started = true
	end

	if PlayerCount == 1 and self.LastPlayerCount ~= 1 then
		--print( "Changing active to " .. tostring( self.PlayerActor ) );
		--self:SwitchToActor( self.PlayerActor, 0, self:GetTeamOfPlayer( 0 ) );
		--self:SetObservationTarget( self.RescuePoint, Activity.PLAYER_1 );

		-- If the last player actor is a rocket or dropship, send it home
	end
	self.LastPlayerCount = PlayerCount;

	-- Zombie spawn
	if self.Stage ~= self.FightStage.NOFIGHT
	and self.ZombieSpawner:IsPastSimMS( self.ZombieSpawnTime ) and MovableMan:GetMOIDCount() < 207 then
		self:SpawnZombie();
	end

	-- Progress waves
	if self.Stage == self.FightStage.NOFIGHT then

		-- After a brief rest, start the wave
		if self.WaveTimer:IsPastRealMS( self.WaveRest ) then
			self:StartWave();
		end

		return;

	elseif self.Stage == self.FightStage.AFTERMATH then

		-- After a moment, or if all zombies are dead, end the wave
		if ( self.WaveKilled >= self.WaveCap )
		or ( self.WaveTimer:IsPastRealMS( self.WaveRest ) ) then
			self:EndWave();
		end

	end


end

function ZombieDefense1:CreateReplacements()

		local SithLord = CreateAHuman("Jango Fett");
		SithLord.Pos = Vector( self.RescueArea:GetRandomPoint().X, -10 )
		SithLord.Team = 0;
		MovableMan:AddActor( SithLord );

end


function ZombieDefense1:CreateRescueCraft()

	print( "Creating rescue craft!" );
	local Craft = CreateACDropShip( "Imperial Star Destroyer" );
	Craft.Pos = Vector( self.RescueArea:GetRandomPoint().X, -50 )

	Craft.Team = 1;
	Craft.AIMode = Actor.AIMODE_STAY;
	Craft:AddAISceneWaypoint( self.RescueArea:GetRandomPoint() );
	MovableMan:AddActor( Craft );

	-- Remove the bay doors
--	for Door in MovableMan.Actors do
--		if ( Door.ClassName == "ADoor" )
--		and ( Door.PresetName == "Door Rotate Long" ) then
--			print( "Opening: " .. tostring( Door ) .. " #" .. Door.ID );
--			Door:GetController():SetState( Controller.PRIMARY_ACTION, true );
--		end
--	end

	-- Announce rescue
	self:UpdateMessage( "It is time to feel the weight of Republic might!" );

end




function ZombieDefense1:SpawnZombie()

	-- Count the zombies
	local ZombieCount = 0;
	for Zombie in MovableMan.Actors do
		if Zombie.Team == 1 and Zombie.ClassName == "AHuman" then
			ZombieCount = ZombieCount + 1;
		end
	end

	-- Determine how many have died
	local Kills = ( self.ZombieCount - ZombieCount )
	if Kills > 0 then
		self.ZombieKilled = self.ZombieKilled + Kills;
		self.WaveKilled = self.WaveKilled + Kills;
		--self:CheckRewards()
		if self.WaveKilled > self.WaveCap - 1 then
			self:StopWave();
		end
	end

	-- Spawn a zombie
	if ZombieCount < self.ZombieCap and self.WaveSpawned < self.WaveCap then
		local ZombieType = self.ZombieTypes[ math.random( #self.ZombieTypes ) ];
		--print( "Spawning " .. ZombieType );
		local Zombie = CreateAHuman( ZombieType );
		Zombie:AddAISceneWaypoint( self.GoalArea:GetRandomPoint() );
		Zombie.AIMode = Actor.AIMODE_BRAINHUNT;

		if Zombie.PresetName == "Republic Jump Trooper" or Zombie.PresetName == "Republic ARC Trooper" then
			Zombie.AIMode = Actor.AIMODE_PATROL;
		end

		if Zombie.PresetName == "Ronin Jedi Apprentice ST" or Zombie.PresetName == "Ronin Jedi Knight ST" then
			Zombie.AIMode = Actor.AIMODE_GOTO;
		end

		--Zombie.AIMode = Actor.AIMODE_PATROL;
		Zombie.Pos = self:PickZombieStart( Zombie )

		Zombie.Team = 1;
		Zombie.Sharpness = Zombie.Sharpness + (self.Wave - 1) * 0.075
		if Zombie.Sharpness > 10 then
			Zombie.Sharpness = 10;
		end

		if #self.ZombieWeapons > 0 then
			Zombie:AddInventoryItem( CreateHDFirearm( self.ZombieWeapons[ math.random( #self.ZombieWeapons ) ] ) );
		end
		MovableMan:AddActor( Zombie );
		ZombieCount = ZombieCount + 1;
		self.ZombieSpawned = self.ZombieSpawned + 1;
		self.WaveSpawned = self.WaveSpawned + 1;

	end

	-- Update the count and resent the timer
	self.ZombieCount = ZombieCount;
	self.ZombieSpawner:Reset();

end

function ZombieDefense1:PickZombieStart()

	local SpawnArea;
	if self.ZombieRight and ( math.random() < self.ZombieRight ) then
		SpawnArea = self.ZombieSpawnRight;
	else
		SpawnArea = self.ZombieSpawnLeft;
	end

--	return SceneMan:MovePointToGround( SpawnArea:GetRandomPoint(), -5, 0 );
	return SceneMan:MovePointToGround( SpawnArea:GetRandomPoint(), 35, 0 );

end

function pt( v )
	for key, value in pairs( v ) do
		if type( value ) == "string" or type( value ) == "number" then
			print( key .. " = [" .. value .. "]" )
		elseif type( value ) == "table" then
			print( key .. " is table" )
		else
			print( key .. " is " .. type( value ) )
		end
	end
end