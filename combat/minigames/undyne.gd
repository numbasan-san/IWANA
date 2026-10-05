extends Control

signal life_changed(current: int, max: int)
signal finished(won: bool)

# Mapa de acciones a nombres de barreras
const DIRECTION_MAP = {
	"rpg_up": "up",
	"rpg_down": "down",
	"rpg_right": "right",
	"rpg_left": "left"
}

@export var max_life: int = 30

# Cada cuántos segundos, como mínimo/máximo, nace un proyectil nuevo desde
# un spawner elegido al azar
@export var min_spawn_interval: float = 0.6
@export var max_spawn_interval: float = 1.4

# Cuánto dura el minijuego si el jugador no pierde antes: al llegar a este
# tiempo se considera "ganado"
@export var survival_time: float = 60.0

# Guarda la dirección actualmente activa
var current_direction: String = ""

# La dirección que está REALMENTE aplicada a las barreras ahora mismo. Se usa
# para no repetir el trabajo cada frame (ver update_barrier). Arranca en "?" (un
# valor imposible) para que la primera pasada siempre aplique el estado inicial.
var _applied_direction: String = "?"

var life: int
var _time_alive: float = 0.0
var _running: bool = false

@onready var _barriers: Dictionary = {
	"up": $barrier1,
	"down": $barrier2,
	"right": $barrier3,
	"left": $barrier4,
}
@onready var _spawners: Array[UndyneProjectileSpawner] = [
	$ProjectileSpawner,
	$ProjectileSpawner2,
	$ProjectileSpawner3,
	$ProjectileSpawner4,
]
@onready var _soul: UndyneSoul = $Soul
@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _life_label: Label = $LifeLabel

func _ready():
	hide_all_barriers()
	_soul.hit.connect(_on_soul_hit)
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	reset()

func _process(delta):
	update_barrier()
	if _running:
		_time_alive += delta
		if _time_alive >= survival_time:
			_finish(true)

# ---------------------------------------------------------------------------
# Barreras
# ---------------------------------------------------------------------------

func update_barrier():
	# Detectar la última tecla presionada
	for action in DIRECTION_MAP:
		if Input.is_action_just_pressed(action):
			current_direction = DIRECTION_MAP[action]
	
	# Si no hay ninguna tecla presionada, limpiar
	var any_pressed = false
	for action in DIRECTION_MAP:
		if Input.is_action_pressed(action):
			any_pressed = true
			break
	
	if not any_pressed:
		current_direction = ""
	
	if current_direction != _applied_direction:
		_applied_direction = current_direction
		hide_all_barriers()
		if current_direction != "":
			show_barrier(current_direction)

func hide_all_barriers():
	for barrier in _barriers.values():
		barrier.set_active(false)

func show_barrier(direction: String):
	if _barriers.has(direction):
		_barriers[direction].set_active(true)

# ---------------------------------------------------------------------------
# Vida y flujo del minijuego
# ---------------------------------------------------------------------------

func reset():
	life = max_life
	_time_alive = 0.0
	_running = true
	life_changed.emit(life, max_life)
	_update_life_label()
	_schedule_next_spawn()

func _on_soul_hit(damage: int):
	if not _running:
		return
	life -= damage
	life_changed.emit(life, max_life)
	_update_life_label()
	if life <= 0:
		_finish(false)

func _finish(won: bool):
	_running = false
	_spawn_timer.stop()
	finished.emit(won)

func _update_life_label():
	if _life_label:
		_life_label.text = "Vida: " + str(max(life, 0)) + " / " + str(max_life)

# ---------------------------------------------------------------------------
# Generación de proyectiles
# ---------------------------------------------------------------------------

func _schedule_next_spawn():
	_spawn_timer.start(randf_range(min_spawn_interval, max_spawn_interval))

func _on_spawn_timer_timeout():
	if _running:
		var spawner: UndyneProjectileSpawner = _spawners[randi() % _spawners.size()]
		spawner.spawn_projectile()
		_schedule_next_spawn()
