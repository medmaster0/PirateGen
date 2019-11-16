extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# MASTER ITEM LIST
# 0 - EMPTY
# 1 - ROUGH WALL 1
# 2 - ROUGH WALL 2
# 3 - ROUGH WALL 3
# 4 - SMOOTH WALL
# 5 - LADDER

#LOAD UP ALL THE SPRITES!!!

var wood1Prim = preload("res://Tiles//scenery//wood1Prim.png")
var wood1Seco = preload("res://Tiles//scenery//wood1Seco.png")
var wood2Prim = preload("res://Tiles//scenery//wood2Prim.png")
var wood2Seco = preload("res://Tiles//scenery//wood2Seco.png")
var wood3Prim = preload("res://Tiles//scenery//wood3Prim.png")
var wood3Seco = preload("res://Tiles//scenery//wood3Seco.png")
var prettyWoodPrim = preload("res://Tiles//scenery//prettyLogPrim.png")
var prettyWoodSeco = preload("res://Tiles//scenery//prettyLogSeco.png")
var ladderPrim = preload("res://Tiles//scenery//ladderPrim.png")

#Class Variables
var primColor
var secoColor
var tile_index 

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	setTile(6)
	setColors(Color(randf(), randf(), randf()), Color(randf(), randf(), randf()))
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setTile(in_tile_index):
	tile_index = in_tile_index
	match tile_index:
		0:
			$Prim.texture = null
			$Seco.texture = null
		1:
			#WOOD 1
			$Prim.texture = wood1Prim
			$Seco.texture = wood1Seco
		2:
			#WOOD 2
			$Prim.texture = wood2Prim
			$Seco.texture = wood2Seco
		3:
			#WOOD 3
			$Prim.texture = wood3Prim
			$Seco.texture = wood3Seco
		4:
			#SMOOTH WOOD
			$Prim.texture = prettyWoodPrim
			$Seco.texture = prettyWoodSeco
		5:
			#LADDER
			$Prim.texture = ladderPrim
			$Seco.texture = null
			
#Set the colors of the tile
func setColors(inPrim, inSeco):
	primColor = inPrim
	secoColor = inSeco
	$Prim.modulate = primColor
	$Seco.modulate = secoColor