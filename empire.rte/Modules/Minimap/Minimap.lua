function Create( self )
	
	self.ScreenWidth = 66;
	self.ScreenHeight = 42;
	
	self.RatioX = self.ScreenWidth / SceneMan.SceneWidth;
	self.RatioY = self.ScreenHeight / SceneMan.SceneHeight;
	self.CenterX = self.Pos.X;
	self.CenterY = self.Pos.Y;
	self.Center = Vector( self.CenterX, self.CenterY );

	self.ScreenLeft = self.CenterX - self.ScreenWidth / 2;
	self.ScreenRight = self.CenterX + self.ScreenWidth / 2;
	self.ScreenTop = self.CenterY - self.ScreenHeight / 2;
	self.ScreenBottom = self.CenterY + self.ScreenHeight / 2;
	
	if self.Team ~= 0 and self.Team ~= 1 then
		self.Team = 0;
	end

	self.ScanTimer = Timer();	
	
end

function Bounds( self, X, Y )

	if X < self.ScreenLeft then
		X = self.ScreenLeft;
	elseif X > self.ScreenRight then
		X = self.ScreenRight;
	end

	if Y < self.ScreenTop then
		Y = self.ScreenTop;
	elseif Y > self.ScreenBottom then
		Y = self.ScreenBottom;
	end
	
	return Vector( X, Y );
	
end

function Update( self )

	if not self.ScanTimer:IsPastSimMS( 250 ) then
		return 
	end
	self.ScanTimer:Reset();

	for Minimap in MovableMan.Particles do
		if Minimap.PresetName == "Minimap" then
			Pixel = CreateMOPixel( "Screen Glow", "Zombie.rte" );
			local Offset = SceneMan:ShortestDistance( self.Center, Minimap.Pos, false )
			Pixel.Pos.X = self.CenterX + Offset.X * self.RatioX;
			Pixel.Pos.Y = self.CenterY + Offset.Y * self.RatioY;
			MovableMan:AddParticle( Pixel );
		end
	end	
	
	for Actor in MovableMan.Actors do
		
		local Pixel = false;
		
		if Actor.ClassName == "ACRocket" or Actor.ClassName == "ACDropShip" then		
			if Actor.Team ~= self.Team then
				Pixel = CreateMOPixel( "Red Craft Glow", "Zombie.rte" );
			else
				Pixel = CreateMOPixel( "Green Craft Glow", "Zombie.rte" );
			end
		elseif Actor:IsInGroup( "Brains" ) == true then
			if Actor.Team ~= self.Team then
				Pixel = CreateMOPixel( "Red Brain Glow", "Zombie.rte" );
			else
				Pixel = CreateMOPixel( "Green Brain Glow", "Zombie.rte" );
			end
		elseif Actor.ClassName == "AHuman" or Actor.ClassName == "ACrab" then
			if Actor.Team ~= self.Team then
				Pixel = CreateMOPixel( "Red Actor Glow", "Zombie.rte" );
			else
				Pixel = CreateMOPixel( "Green Actor Glow", "Zombie.rte" );
			end
		end
		
		if Pixel then
			local Offset = SceneMan:ShortestDistance( self.Center, Actor.Pos, false )
			Pixel.Pos = Bounds( self, self.CenterX + Offset.X * self.RatioX, self.CenterY + Offset.Y * self.RatioY )
			MovableMan:AddParticle( Pixel );
		end
		
	end
	
end
