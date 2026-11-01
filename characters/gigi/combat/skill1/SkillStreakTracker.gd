class_name SkillStreakTracker extends LastingEffect

var last_used_skill: Skill = null
var streak: int = 0

func on_skill_used(used_skill: Skill):
	if last_used_skill == used_skill:
		streak += 1
	else:
		last_used_skill = used_skill
		streak = 1
