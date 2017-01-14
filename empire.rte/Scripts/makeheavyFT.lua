function Create(self)

	self.OrigTeam = self.Team;
                           
end

function Update(self)

if self.Team ~= self.OrigTeam then
	self.ToDelete = true;
end

end