--[[
Mod by Pixel Generator, pixelgeneratorhun@gmail.com
This mod is based on the original Raid mod files.
Noticible changes:
-Rank system
-Respawn depending on number of lives (COL)
-CPU disabled
-difficulty changes only the number of lives to have
-game time is fixed 3 minutes by default
-player slots and list of players connected in array: player = human player, IOP[player] = player slot
--]]

function LastMS:SceneTest()
--[[ THIS TEST IS DONE AUTOMATICALLY BY THE GAME NOW; IT SCANS THE SCRIPT FOR ANY MENTIONS OF "GetArea" AND TESTS THE SCENES FOR HAVING THOSE USED AREAS DEFINED!
	-- See if the required areas are present in the test scene
	if not (TestScene:HasArea("Sith Training")) then
		-- If the test scene failed the compatibility test, invalidate it
		TestScene = nil;
	end
--]]
end

function LastMS:StartActivity()
	print("START! -- LastMS:StartActivity()!");

	self.respawntimer = Timer();
	-------------------------------------------------
	-- Equipment configuration:
	Character = "Ronin Jedi Knight"; -- body
	-------------------------------------------------
	-- Game configuration:
	Gametime = 1260; -- time limit in seconds
	-------------------------------------------------
	if self.Difficulty <= GameActivity.CAKEDIFFICULTY then
		lives = 19;
	elseif self.Difficulty <= GameActivity.EASYDIFFICULTY then
		lives = 13;
	elseif self.Difficulty <= GameActivity.MEDIUMDIFFICULTY then
		lives = 9;
	elseif self.Difficulty <= GameActivity.HARDDIFFICULTY then
		lives = 5;
	elseif self.Difficulty <= GameActivity.NUTSDIFFICULTY then
		lives = 2;
	elseif self.Difficulty <= GameActivity.MAXDIFFICULTY then
		lives = 0;
	end
	IOP = {};
	ind = 0;
	TOD = {};
	COL = {};
	RANK = {};
	dead = {};
	for start_player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(start_player) and self:PlayerHuman(start_player) then
			IOP[ind] = start_player;
			TOD[ind] = 0;
			COL[ind] = lives + 1;
			dead[ind] = false;
			RANK[ind] = 1;
			ind = ind + 1;
			if not self:GetPlayerBrain(start_player) then
				local foundBrain = MovableMan:GetUnassignedBrain(self:GetTeamOfPlayer(start_player));
				if not foundBrain then

				local brainteam = self:GetTeamOfPlayer(start_player);

				if brainteam == 0 then
					Character = "Asajj Ventress Jedi";
				elseif brainteam == 1 then
					Character = "Count Dooku";
				elseif brainteam == 2 then
					Character = "Darth Maul";
				elseif brainteam == 3 then
					Character = "Jango Fett";
				end

				foundBrain = CreateAHuman(Character);
				foundBrain.Team = self:GetTeamOfPlayer(start_player);	

					foundBrain.Pos = SceneMan:MovePointToGround(Vector(math.random(0, SceneMan.SceneWidth), 0), 0, 0) + Vector(0, -50);

					MovableMan:AddActor(foundBrain);
					self:SetPlayerBrain(foundBrain, start_player);
					self:SwitchToActor(foundBrain, start_player, self:GetTeamOfPlayer(start_player));
					self:SetLandingZone(self:GetPlayerBrain(start_player).Pos, start_player);
					self:SetObservationTarget(self:GetPlayerBrain(start_player).Pos, start_player);
				else
					self:SetPlayerBrain(foundBrain, start_player);
					self:SwitchToActor(foundBrain, start_player, self:GetTeamOfPlayer(start_player));
					self:SetLandingZone(self:GetPlayerBrain(start_player).Pos, start_player);
					self:SetObservationTarget(self:GetPlayerBrain(start_player).Pos, start_player);
				end
			end
		end
	end
	self.SurvivalTimer = Timer();
	self.TimeLimit = 5000 + (Gametime*1000);
	self.StartTimer = Timer();
	NOAP = ind;
end

function LastMS:PauseActivity(pause)
    	print("PAUSE! -- LastMS:PauseActivity()!");
end

function LastMS:EndActivity()
    	print("END! -- LastMS:EndActivity()!");
		
end

function LastMS:Ranking()
	local max1 = -1;
	local max2 = -1;
	local max3 = -1;
	local max4 = -1;
	for i=0, ind-1 do
		if max1 < COL[i] then
			max1 = COL[i];
		end
	end
	for i=0, ind-1 do
		if max2 < COL[i] and COL[i] ~= max1 then
			max2 = COL[i];
		end
	end
	for i=0, ind-1 do
		if max3 < COL[i] and COL[i] ~= max1 and COL[i] ~= max2 then
			max3 = COL[i];
		end
	end
	for i=0, ind-1 do
		if max4 < COL[i] and COL[i] ~= max1 and COL[i] ~= max2 and COL[i] ~= max3 then
			max4 = COL[i];
		end
	end
	for i=0, ind-1 do
		if COL[i] == max1 then
			RANK[i]=1;
		elseif COL[i] == max2 then
			RANK[i]=2;
		elseif COL[i] == max3 then
			RANK[i]=3;
		elseif COL[i] == max4 then
			RANK[i]=4;
		end
	end
end

function LastMS:UpdateActivity()
	if self.ActivityState ~= Activity.OVER then

	-- Remove lingering items
	for Item in MovableMan.Items do
		if Item.ClassName == "HDFirearm" then
			if Item.PresetName ~= "Ventress Lightsaber Blue" and Item.PresetName ~= "Ventress Lightsaber Green" and Item.PresetName ~= "Maul's Staff" and Item.PresetName ~= "Fett Arm Flamethrower" and Item.PresetName ~= "Dooku's Lightsaber" and Item.PresetName ~= "WESTAR-34" and Item.PresetName ~= "WESTAR-34 Offhand" then
				Item.ToDelete = true;
			end
		end
	end

	local ZombieCount = 0;
	for Zombie in MovableMan.Actors do
		if Zombie.Team == -1 and Zombie.ClassName == "AHuman" then
			ZombieCount = ZombieCount + 1;
		end
	end

	if ZombieCount < 7 then
		if self.respawntimer:IsPastSimMS(9000) then
			local stormTroop = CreateAHuman("Imperial Stormtrooper PvP");
			stormTroop.Team = -1;
			stormTroop.Pos = SceneMan:MovePointToGround(Vector(math.random(0, SceneMan.SceneWidth), 0), 0, 0) + Vector(0, -50);
			MovableMan:AddActor(stormTroop);
			self.respawntimer:Reset();
		end
	end
		self.Ranking();
		GameTimeLeft = math.floor(self.SurvivalTimer:LeftTillSimMS(self.TimeLimit) / 1000);
		for index = 0, ind - 1 do
			ActivityMan:GetActivity():SetTeamFunds(0,self:GetTeamOfPlayer(IOP[index]));
			if self.StartTimer:IsPastSimMS(3000) then
				FrameMan:SetScreenText("Time left: " .. GameTimeLeft .. "   Lives: " .. COL[index] - 1 .. "   Rank: " .. RANK[index], index, 0, 1000, false);
			else
				FrameMan:SetScreenText("Game time is " .. Gametime .. " seconds, Starting lives: " .. lives, index, 333, 5000, true);
			end
			if not MovableMan:IsActor(self:GetControlledActor(IOP[index])) then
				if TOD[index] == 0 then
					TOD[index] = GameTimeLeft;
					COL[index] = COL[index] - 1;
				elseif TOD[index] - GameTimeLeft <= 2 and COL[index] > 0 then
					FrameMan:ClearScreenText(index);
					FrameMan:SetScreenText("Respawn in " .. 3 - (TOD[index] - GameTimeLeft), index, 333, -1, false);
				elseif TOD[index] - GameTimeLeft > 2 and COL[index] > 0 then
				local brainteam = self:GetTeamOfPlayer(IOP[index]);


				if brainteam == 0 then
					Character = "Asajj Ventress Jedi";
				elseif brainteam == 1 then
					Character = "Count Dooku";
				elseif brainteam == 2 then
					Character = "Darth Maul";
				elseif brainteam == 3 then
					Character = "Jango Fett";
				end

					foundBrain = CreateAHuman(Character);
					foundBrain.Team = self:GetTeamOfPlayer(IOP[index]);
					foundBrain.Pos = SceneMan:MovePointToGround(Vector(math.random(0, SceneMan.SceneWidth), 0), 0, 0) + Vector(0, -50);
					MovableMan:AddActor(foundBrain);
					self:SetPlayerBrain(foundBrain, IOP[index]);
					self:SwitchToActor(foundBrain, IOP[index], self:GetTeamOfPlayer(IOP[index]));
					self:SetObservationTarget(foundBrain.Pos, IOP[index]);
					TOD[index] = 0;
				elseif COL[index] == 0 then
					if dead[index] == false then
						NOAP = NOAP - 1;
						dead[index] = true;
					end
					FrameMan:ClearScreenText(index);
					FrameMan:SetScreenText("You died!", index, 333, -1, false);
				end
			end
		end
		if self.SurvivalTimer:IsPastSimMS(self.TimeLimit) or NOAP == 1 then
			for index = 0, ind - 1 do
				self:ResetMessageTimer(IOP[index]);
				FrameMan:ClearScreenText(index);
				FrameMan:SetScreenText("Rank: " .. RANK[index] .. "   Lives remained: " .. COL[index], index, 0, -1, false);
				if RANK[index] == 1 then
					self.WinnerTeam = self:GetTeamOfPlayer(IOP[index]);
				end
			end
			ActivityMan:EndActivity();
		end
	end
end