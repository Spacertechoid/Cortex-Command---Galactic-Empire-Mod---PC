function Create(self)

    self.Timer = Timer();

		local velFactor = FrameMan.PPM * TimerMan.DeltaTimeSecs;

		local checkVect = self.Vel * velFactor;

	local magseal = CreateMOPixel("E11 Magnetic Seal");
	magseal.Pos = self.Pos + Vector(1,1):RadRotate(self.Vel.AbsRadAngle);
	magseal.Vel = self.Vel;
	magseal.Team = self.Team;
	MovableMan:AddParticle(magseal);

	local magseal = CreateMOPixel("E11 Magnetic Seal");
	magseal.Pos = self.Pos + Vector(-0.5,-0.5):RadRotate(self.Vel.AbsRadAngle);
	magseal.Vel = self.Vel;
	magseal.Team = self.Team;
	MovableMan:AddParticle(magseal);
                           
end

function Update(self)

	local magseal = CreateMOPixel("E11 Magnetic Seal");
	magseal.Pos = self.Pos + Vector(0.5,0.5):RadRotate(self.Vel.AbsRadAngle);
	magseal.Vel = self.Vel;
	magseal.Team = self.Team;
	MovableMan:AddParticle(magseal);

	local magseal = CreateMOPixel("E11 Magnetic Seal");
	magseal.Pos = self.Pos + Vector(-0.5,-0.5):RadRotate(self.Vel.AbsRadAngle);
	magseal.Vel = self.Vel;
	magseal.Team = self.Team;
	MovableMan:AddParticle(magseal);


local terrcheck = Vector(0,0);

	if SceneMan:CastStrengthRay(self.Pos,Vector(self.Vel.X,self.Vel.Y):SetMagnitude(15),0,terrcheck,0,0,true) then
      		self.ToDelete = true;
  	end


	if self.Timer:IsPastSimMS(770) == true then
		self.ToDelete = true;
	end


	if self.ToDelete == true or self.ToSettle == true then

		local velFactor = FrameMan.PPM * TimerMan.DeltaTimeSecs;
		local checkVect = self.Vel * velFactor;


    	i = 0;
		while i < 6 do

    		local e = CreateMOPixel("Rifle Frag 1");
    		e.Vel.X = math.random(-30,30);
    		e.Vel.Y = math.random(-30,30);
    		e.Pos = self.Pos + (checkVect * 0.5);
		e.Team = self.Team;
		e.IgnoresTeamHits = true;
    		MovableMan:AddMO(e);

    		i = i+1;
    	end

	
    		local e = CreateMOPixel("Spark Yellow 1");
      		e.Vel.X = math.random(-5,5);
    		e.Vel.Y = math.random(-6,6);
    		e.Pos = self.Pos + (checkVect * 0.5);
    		MovableMan:AddMO(e);


	    	local e = CreateMOSParticle("Fire Puff Small");
    		e.Vel.X = math.random(-4,4);
    		e.Vel.Y = math.random(-4,4);
    		e.Pos = self.Pos + (checkVect * 0.5);
    		MovableMan:AddMO(e);

	    	local e = CreateMOSParticle("Tiny Smoke Ball 1");
    		e.Vel.X = math.random(-5,5);
    		e.Vel.Y = math.random(-5,5);
    		e.Pos = self.Pos + (checkVect * 0.5);
    		MovableMan:AddMO(e);

    		local e = CreateMOPixel("Glow Particle Yellow Small");
    		e.Vel.X = 0;
    		e.Vel.Y = 0;
    		e.Pos = self.Pos + (checkVect * 0.5);
    		MovableMan:AddMO(e);

	end
end