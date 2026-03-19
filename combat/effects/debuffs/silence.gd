class_name Silence extends LastingEffect

# This effect remembers the blocked skill of the opponent. This is in case somehow
# other skills have silenced the same target and blocked other skills, or if the
# target manages to use another skill and change its last used one, which means
# this skill wouldn't have access to the blocked skill anymore.
var blocked_skill: Skill

func on_apply(target: Character):
	blocked_skill = target.combat_handler.last_skill
	blocked_skill.enabled = false

func on_unapply(target: Character):
	blocked_skill.enabled = true
