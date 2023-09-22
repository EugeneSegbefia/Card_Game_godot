extends TextureButton

var player1Hand = INF

# Called when the node enters the scene tree for the first time.
func _ready():
	scale *= $'../../'.CardSize/size

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _gui_input(_event):
#	if Input.is_action_just_released("left click"):
#		print("help!")
#		if player1Hand< 5:
#			player1Hand = $'../../'.drawcard()
#			if player1Hand <5:
#				disabled = true



func _on_pressed():
	print("help!")
	if player1Hand > 0:
		print("help!!")
		player1Hand = $'../../'.drawcard()
		if player1Hand ==0:
			print("help!!!")
			disabled = true
	pass # Replace with function body.
