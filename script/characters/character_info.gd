
extends Resource

class_name CharacterInfo

@export var name : String = ''
@export var portrait : Texture2D
@export var description : String = ''
@export var affinity : QuestsManager.AFFINITY = QuestsManager.AFFINITY.NEUTRAL
@export var satiety : int = 0
@export var person : QuestsManager.PERSON = QuestsManager.PERSON.NONE
var emotions = []

func load_emotions():
	for i in range(15):
		emotions[i] = Texture2D.new()

