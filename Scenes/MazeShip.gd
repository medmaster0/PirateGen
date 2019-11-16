extends Node2D

export (PackedScene) var BuildingTile

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

################
### 3-D Indexed ITEM arrays -> Really a 4-D list
#######
### Access: map_items[x_coord][y_coord][z-_coord] = {list of Item scenes}
var map_items = [] #items that can be picked up...
var map_buildings = [] #building items (no diff between top and bottom) -> Always under creature

#STANDARD GAME SCENE GLOBALS
var world_width #the size of the map (in pixels)
var world_height #the size of the map (in pixels)
var map_width #the size of the map (in cells/tiles) SCREEN DIMS!!
var map_height #the size of the map (in cells/tiles) SCREEN DIMS!!
var cell_size #the amount of pixels in a cell/tile

#BROADER WORLD VARS
#var max_x_block = 7
#var max_y_block = 7
#var max_x_map = 8 * max_x_block #How big the generated map is... (8 tiles per block)
#var max_y_map = 8 * max_y_block
#var min_x_map = 0
#var min_y_map = 0
var max_z_map = 20 #How high the map goes
#var min_z_map = 0 #The lowest level

# SHIP VARS... MIGHT BE MOVED
var primCol  
var secoCol
var ladderCol

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	randomize()
	
	#Screen Dimension stuff
	world_width = get_viewport().size.x
	world_height = get_viewport().size.y
	map_width = int($TileMap.world_to_map(Vector2(world_width,0)).x)
	map_height = int($TileMap.world_to_map(Vector2(0,world_height)).y)
	cell_size = $TileMap.cell_size.x
	
	#BUILDINGS
	for i in range(map_width + 1):
		var x_list = []
		for j in range(map_height + 1):
			var y_list = []
			for z in range(max_z_map+16):
				var z_list = []
				y_list.append(z_list)
			x_list.append(y_list)
		map_buildings.append(x_list)
	
	#Generate a ship
	primCol = Color(randf(), randf(), randf())
	secoCol = Color(randf(), randf(), randf())
	ladderCol = Color(randf(), randf(), randf())
	var ship_data = RogueGen.GenerateMazeShip(5 + randi()%5)
	print(ship_data)
	
	var x_index = 0 
	var y_index = 0
	for row in ship_data:
		x_index = 0
		for e in row:
			#Gonna make a new BuildingTile
			var BuildingTile = load("res://Scenes//BuildingTile.tscn") #Used as a template for making items
			var buildingTile = BuildingTile.instance()
			buildingTile.position = Vector2( (10+x_index)*cell_size,world_height - (cell_size*(y_index+1)))
			x_index = x_index + 1
			add_child(buildingTile)
			buildingTile.setColors(primCol, secoCol)
			#buildingTile.setTile(5)
			#The tile index depends on the value of e...
			match(e):
				0:
					buildingTile.setTile(0)
				1:
					buildingTile.setTile(4)
				2:
					buildingTile.setTile(1+randi()%3)
				3:
					buildingTile.setTile(5)
					buildingTile.setColors(ladderCol,ladderCol)
			
		y_index = y_index + 1
		
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass





# TODO: We'll eventually have to create a similarily sized ship wall side view (that can cover the maze inside)