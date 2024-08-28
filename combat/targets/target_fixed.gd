## Superclass of all target types that can always know all possible targets.
##
## Subclasses are TargetSelf, TargetParty, TargetEnemyParty and TargetEveryone
class_name TargetFixed extends TargetType

func is_manual_target() -> bool:
	return false
