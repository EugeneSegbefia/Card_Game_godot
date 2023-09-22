extends MarginContainer
var InFocus =false
var cardInPlace = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#size = Vector2(125,175)
	#$Slot.position = position
	$Slot.scale *= size/$Slot.texture.get_size()
	#$Slot.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_mouse_entered():
	$Slot.visible = true
	InFocus = true

func _on_mouse_exited():
#	$Slot.visible = false
#	if cardInPlace:
	$Slot.visible = true
