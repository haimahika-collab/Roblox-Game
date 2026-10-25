return {
	RoundSeconds = 600,
	IntermissionSeconds = 15,
	MaxPlayers = 4,
	MonsterSpeed = 13,
	MonsterSprintSpeed = 22,
	DetectionRadius = 85,
	AttackRadius = 5,
	AttackDamage = 25,
	Houses = {
		{ Number = "13", Position = Vector3.new(-65, 0, -70), Rule = "Leave it at the door. Never ring twice.", Kind = "Bell" },
		{ Number = "27", Position = Vector3.new(65, 0, -145), Rule = "The tenant is asleep. Walk slowly near the porch.", Kind = "Quiet" },
		{ Number = "41", Position = Vector3.new(-65, 0, -220), Rule = "Keep your flashlight OFF while you deliver.", Kind = "Dark" },
	},
}
