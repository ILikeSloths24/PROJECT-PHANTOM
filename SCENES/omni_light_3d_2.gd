extends OmniLight3D

@export var min_energy: float = 0
@export var max_energy: float = 2.0

func _ready():flicker()

func flicker():
	while true:
		light_energy = randf_range(min_energy, max_energy)

		await get_tree().create_timer(
			randf_range(0.05, 0.3)
		).timeout
