extends Marker2D
class_name Entrance

@export var entrance_id: int
var connected: bool = false
var direction = Vector2i(Vector2.RIGHT.rotated(global_rotation).round())

func placeRoom():
		
	connected = true
