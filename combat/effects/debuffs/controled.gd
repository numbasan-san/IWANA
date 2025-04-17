# TODO: for now, we will control the opponent by blocking every skill except the
# selected one. If there is more than one selected skill, each turn it will 
# select the next one and if there are no more available or the duration reaches
# 0, the debuff is removed and all skills are restored to their original state.
# We must think if there is a better way to implement this.
class_name Controled extends SkillSelectionEffect

# Because there might be other effects or conditions that block the target's
# skills and we don't want to override them, at the start of each turn we will
# read which skills are enabled, block the ones that the target isn't going to use,
# and at the end of the turn we'll restoreo their original state so that after
# each turn other skills could be disabled.
var skill_enabled: Array[bool]

func before_turn(target: Character):
	if chosen.size() == 0:
		duration = 0
		return
	skill_enabled = []
	for skill in target.combat_handler.skills:
		skill_enabled.append(skill.enabled)
		if skill != chosen[0]:
			skill.enabled = false

func after_turn(target: Character):
	for skill in target.combat_handler.skills:
		skill.enabled = skill_enabled.pop_front()
	chosen.pop_front()
	if chosen.size() == 0:
		duration = 0
		return

func on_unapply(target: Character):
	# This is to restore the original state just in case the debuff is removed
	# before it runs out naturally
	for skill in target.combat_handler.skills:
		skill.enabled = skill_enabled.pop_front()
	chosen.clear()
