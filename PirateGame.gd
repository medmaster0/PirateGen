extends Node2D

export (PackedScene) var MazeShip

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var num_ships = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	
	for i in range(num_ships):
		var temp_ship = MazeShip.instance()
		add_child(temp_ship)
		temp_ship.position.x = rand_range(-300,300)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	pass
