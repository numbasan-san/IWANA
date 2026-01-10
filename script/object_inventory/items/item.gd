extends Resource
class_name Item

@export var name: String = ""
@export var texture : Texture2D
@export var max_stack: int = 999
@export var effect: Effect
@export var cost: int = 1
@export var sellable: bool = true
@export var consumable: bool = true
@export var description: String = ""
@export var rarity: int = 1
@export var item_type: String = "consumable"

@export var texture_atlas: Texture2D = preload(
	"res://assets/rpg_sprites/items/hover/objetossss - hover.png"
)
@export var atlas_grid_x: int = 0
@export var atlas_grid_y: int = 0

# Propiedad calculada que devuelve un AtlasTexture
var hover_texture: AtlasTexture:
	get:
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = texture_atlas
		atlas_texture.region = icon_region
		return atlas_texture


# Propiedad calculada para la región del icono
var icon_region: Rect2:
	get:
		var icon_size = Vector2(18, 18)
		var icon_offset = 15
		var pos = Vector2(
			(32 * atlas_grid_x) + icon_offset,
			(32 * atlas_grid_y) + icon_offset
		)
		return Rect2(pos, icon_size)

func _init():
	effect = preload("res://combat/effects/effect.gd").new()
