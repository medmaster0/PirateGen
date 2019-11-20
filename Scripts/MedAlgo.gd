extends Node

#Caclulate the "opposite color"
#This is the color with each of it's rgb channels 128 (or 0.5) away from the color
#ex. (255,108,176) and (128,236,48)
func oppositeColor(in_col):
	
	var r = in_col.r + 0.5
	if r > 1:
		r = r - 1
	var g = in_col.g + 0.5
	if g > 1:
		g = g - 1
	var b = in_col.b + 0.5
	if b > 1:
		b = b - 1
	
	var out_col = Color(r,g,b)
	return out_col
	
	
#Determine which color will better contrast input color:
#Black or White?	
func contrastColor(in_col):
	
	var in_brightness_count = 0 #this will keep track of which channels are bright (over 0.5)
	if in_col.r > 0.5:
		in_brightness_count = in_brightness_count + 1
	if in_col.g > 0.5:
		in_brightness_count = in_brightness_count + 1
	if in_col.b > 0.5:
		in_brightness_count = in_brightness_count + 1
		
	#If the majority of channels are bright, return black (for contrast)
	if in_brightness_count >=2:
		return(Color(0,0,0))
	#Otherwise return white
	else: 
		return(Color(1,1,1))
	
	
#Blend two colors
func blendColor(col1, col2):
	
	var r = (col1.r+col2.r)/2.0
	var g = (col1.g+col2.g)/2.0
	var b = (col1.b+col2.b)/2.0
	return( Color(r,g,b) )
	
#Generate color cycle schema
#These are meant to be moody color that cycle unto each other
#Right now, RANDOM
#eventually more artistic and shit
#Things we can filter:
	#Green? doesn't look good as a sky
	#blue? pure doesn't look good as a sky neither...
	#too much red will get boring, some otherworldy is cool
	# like one or two out of all of them can be freaky, but no more
func colorCycle():
	
	randomize() #randomize just to be safe, fuckhead
	
	var colors = [] #the list of colors that form the cycle
	
	#now add some random colors boyeee
	var cycle_length = randi()%3 + 3
	for i in range(cycle_length):
		colors.append(Color(randf(),randf(), randf()))
	
	return colors
	
#MAYBE TODO????????
#Generates a discrete list of colors to go through
#that slowly changes ino one from the other
#Will list colors to get from color1 to color2, in random RGB increments

#Function that will return a color a step in the "direction" of the other step
func colorTransitionStep(color1,color2):
	
	#Determine how big of steps to adjust each color channel in
	var STEP_SIZE = 0.0125
	
	var temp_color = color1 #the color we'll be returning (will be manipulated but starts at color1)
	
	#We first need to analyze which channels need to go higher or lower
	var shouldGoUp = [] #will hold boolean values indicating if channel should go up or down
	for i in range(3):
		if color1[i] < color2[i]: #If target is greater
			shouldGoUp.append(true)
		else: #then target is lower
			shouldGoUp.append(false)
			
	#Need to pick which channel (R,G, or B) we'll change
	var channel_choice = randi()%3 
	match(channel_choice):
		0:
			#Chose Red
			#Check array for if we should increment or decrement
			if shouldGoUp[0] == true:
				temp_color.r = temp_color.r + STEP_SIZE
			else:
				temp_color.r = temp_color.r - STEP_SIZE
		1:
			#Chose Green
			#Check array for if we should increment or decrement
			if shouldGoUp[1] == true:
				temp_color.g = temp_color.g + STEP_SIZE
			else:
				temp_color.g = temp_color.g - STEP_SIZE
		2:
			#Chose Blue
			#Check array for if we should increment or decrement
			if shouldGoUp[2] == true:
				temp_color.b = temp_color.b + STEP_SIZE
			else:
				temp_color.b = temp_color.b - STEP_SIZE
	
	return(temp_color)




#A STAR FUNCTIONS!!!!
#A* Path Finding 
#returns an array of steps to follow between the two points
#returns (9999,9999) if no path 
#input two vectors you want to search for (global non-tilemap coords)
#
#Also need a tile map that you search on
#
#How it works:
#We have two sets, open and closed set
func find_path(global_start, global_end, tile_map):
	
	#Function vars
	var open_set = []
	var closed_set = []
	var walkable_tiles = [-1,0,1,2,3,4]
	
	#Convert the coordinates to map_coords
	var start = tile_map.world_to_map(global_start)
	var end = tile_map.world_to_map(global_end)
	#var start = map_start
	#var end = map_end


	#Create the FIRST node
	var temp_node = {
		"g" : 0,
		"h" : abs(start.x - end.x) + abs(start.y - end.y),
		"f" : abs(start.x - end.x) + abs(start.y - end.y),
		"coords" : start,
		"last_node" : null
	}
	#And add it to the open_set
	open_set.append(temp_node)
	
	#Now an infinite loop that only breaks once we find our target...
	while(true):
		
		#print(open_set.size())
		
		#EACH ITERATION...
		#find the node in open_set with the least f (next node)
		var least_f = 9999 #temp var to keep track of what the lowest f is
		var next_node #the temp var for the node that has the lowest f
		for node in open_set:
			if node.f <= least_f: #use equals so we get the last one checked (added to open set)
				next_node = node
				least_f = node.f
		#next_node now points to the node with the lowest f
		
		#if there is no next_node (we got through open set), then just exit
		if next_node == null:
			print("got to end of open set and no target")
			return(false)
		
		#remove that node from open_set (so we don't check it again)
		open_set.erase(next_node)
		
		#Now, add each of next_node's neighbors (if walkable)
		#RIGHT
		if tile_map.get_cell(next_node.coords.x+1, next_node.coords.y) in walkable_tiles:
			#Make a new node (with calculations) and add to set
			var temp_x = next_node.coords.x+1
			var temp_y = next_node.coords.y
			if Vector2(temp_x,temp_y) == end: #check if reached target
				return( path_from_set(next_node,end) )
				break
				
			#Check if node coords have already been entered in closed_set
			if isVectorInSet(Vector2(temp_x,temp_y), closed_set) == false: #If not closed yet
				#Then add a new node for those coords
				var neighbor_node = {
					"g" : next_node.g + 1,
					"h" : abs(end.x - temp_x) + abs(end.y - temp_y), #Manhattan Distance"
					"f" : "not set yet",
					"coords" : Vector2(temp_x, temp_y),
					"last_node" : next_node
				}
				neighbor_node.f = neighbor_node.g + neighbor_node.h #Now calculate f
				open_set.append(neighbor_node)
			
		#LEFT
		if tile_map.get_cell(next_node.coords.x-1, next_node.coords.y) in walkable_tiles:
			#Make a new node (with calculations) and add to set
			var temp_x = next_node.coords.x-1
			var temp_y = next_node.coords.y
			if Vector2(temp_x,temp_y) == end: #check if reached target
				return( path_from_set(next_node,end) )
				break
				
			#Check if node coords have already been entered in closed_set
			if isVectorInSet(Vector2(temp_x,temp_y), closed_set) == false: #If not closed yet
				#Then add a new node for those coords
				var neighbor_node = {
					"g" : next_node.g + 1,
					"h" : abs(end.x - temp_x) + abs(end.y - temp_y), #Manhattan Distance"
					"f" : "not set yet",
					"coords" : Vector2(temp_x, temp_y),
					"last_node" : next_node
				}
				neighbor_node.f = neighbor_node.g + neighbor_node.h #Now calculate f
				open_set.append(neighbor_node)
			
		#UP
		if tile_map.get_cell(next_node.coords.x, next_node.coords.y-1) in walkable_tiles:
			#Make a new node (with calculations) and add to set
			var temp_x = next_node.coords.x
			var temp_y = next_node.coords.y-1
			if Vector2(temp_x,temp_y) == end: #check if reached target
				return( path_from_set(next_node,end) )
				break
				
			#Check if node coords have already been entered in closed_set
			if isVectorInSet(Vector2(temp_x,temp_y), closed_set) == false: #If not closed yet
				#Then add a new node for those coords
				var neighbor_node = {
					"g" : next_node.g + 1,
					"h" : abs(end.x - temp_x) + abs(end.y - temp_y), #Manhattan Distance"
					"f" : "not set yet",
					"coords" : Vector2(temp_x, temp_y),
					"last_node" : next_node
				}
				neighbor_node.f = neighbor_node.g + neighbor_node.h #Now calculate f
				open_set.append(neighbor_node)
			
		#DOWN
		if tile_map.get_cell(next_node.coords.x, next_node.coords.y+1) in walkable_tiles:
			#Make a new node (with calculations) and add to set
			var temp_x = next_node.coords.x
			var temp_y = next_node.coords.y+1
			if Vector2(temp_x,temp_y) == end: #check if reached target
				return( path_from_set(next_node, end) )
				break
				
			#Check if node coords have already been entered in closed_set
			if isVectorInSet(Vector2(temp_x,temp_y), closed_set) == false: #If not closed yet
				#Then add a new node for those coords
				var neighbor_node = {
					"g" : next_node.g + 1,
					"h" : abs(end.x - temp_x) + abs(end.y - temp_y), #Manhattan Distance"
					"f" : "not set yet",
					"coords" : Vector2(temp_x, temp_y),
					"last_node" : next_node
				}
				neighbor_node.f = neighbor_node.g + neighbor_node.h #Now calculate f
				open_set.append(neighbor_node)
			
		#Finally, add the node to the closed set
		closed_set.append(next_node)
			
	#end while - If this while broke, means we found target
	

#A utility function for A* that will reconstruct the path from given node
#Returns a list of steps only 
#array of Vector2
func path_from_set(latest_node, end_coords):
	
	var path_array = [] #The list of coords we'll be returning back
	
	var current_node = latest_node #temp node for interating list
	while(current_node.last_node != null):
		path_array.push_front(current_node.coords)
		current_node = current_node.last_node
		
	path_array.append(end_coords)
		
	return(path_array)
		

#Checks if the input coords (Vector2) have already been entered in the search set
func isVectorInSet(search_coords, search_set):
	
	#Iterate through all the nodes in set
	for node in search_set:
		if search_coords == node.coords: #If the coords match the target
			return(true)
	
	#If it makes it here, not in set
	return(false)
#END A STAR SEARCH AFFILIATED FUNCTIONS
	
#############################################################
#### Here Be some RogueCiv Search functions
#These functions can search through 3D lists -> item_array[x coord][y coord][z coord] = [list of items]

#Utility function that check if a coordinate has an item of certain index in it...
#Looks in and iterates an item list at the position 
#returns true if an item in it has the desired index
func is_tile_index_at(item_list, tile_index, check_coord):
	for item in item_list[check_coord.x][check_coord.y][check_coord.z]:
		if item.tile_index == tile_index:
			return(true)
	#If made it to end, no match
	return(false)

#Utility Function that can check if multiple tile indices are at a coord
# (The same as above but with a list of tile_indices
# Also using a Vector3 now for check position
func are_tile_indices_at(item_list, tile_indices, check_coord):
	for tile_index in tile_indices:
		if is_tile_index_at(item_list,tile_index,check_coord)==true:
			return(true)
	#If got to here, no match
	return(false)

##Utility function that checks if a map_coord is within bounds of the array....
func is_in_bounds(map_coord, item_list):
	if(map_coord.x >= item_list.size()):
		return(false)
	if(map_coord.y >= item_list[0].size()):
		return(false)
	if(map_coord.z >= item_list[0][0].size()):
		return(false)
	#If made it here, is in bounds
	return(true)

#Now ANother A star function!!!!
# But operates on a 3d indexed item list
#A* Path Finding 
#returns an array of steps to follow between the two points
#returns (9999,9999) if no path 
#input two vectors you want to search for (map coords)
#
#Also need 3D indexed item list that you search on
#
#How it works:
#We have two sets, open and closed set
func find_path_items(map_start, map_end, item_map):

	#Function vars
	var open_set = []
	var closed_set = []
	var blocked_tiles = [102] #item tile indices that correspond to obstacles

	#Convert the coordinates to map_coords
#	var start = tile_map.world_to_map(global_start)
#	var end = tile_map.world_to_map(global_end)
	var start = map_start
	var end = map_end

	#Make sure the first search coord, itself, isn't blocked
	#var first_check = Vector3()
	if are_tile_indices_at(item_map, blocked_tiles, map_start):
		print("Starting search on Block Tile!! CHECK FIRST TO MAKE SURE THIS DOESNT HPN")
		return([9999,9999])

	#Create the FIRST node
	var temp_node = {
		"g" : 0,
		"h" : abs(start.x - end.x) + abs(start.y - end.y),
		"f" : abs(start.x - end.x) + abs(start.y - end.y),
		"coords" : start,
		"last_node" : null
	}
	#And add it to the open_set
	open_set.append(temp_node)

	#Now an infinite loop that only breaks once we find our target...
	while(true):

		#EACH ITERATION...
		#find the node in open_set with the least f (next node)
		var least_f = 9999 #temp var to keep track of what the lowest f is
		var next_node #the temp var for the node that has the lowest f
		for node in open_set:
			if node.f <= least_f: #use equals so we get the last one checked (added to open set)
				next_node = node
				least_f = node.f
		#next_node now points to the node with the lowest f

		#if there is no next_node (we got through open set), then just exit
		if next_node == null:
			print("got to end of open set and no target")
			return([9999,9999])
			
		#Also, put a cap on search queue size...
		if open_set.size() > 500:
			print("search is out of control")
			return([9999,9999])

		#remove that node from open_set (so we don't check it again)
		open_set.erase(next_node)

		#Now, add each of next_node's neighbors (if walkable)
		var neighbor_coords #will temporaily hold the neighbor coords to check
		#RIGHT
		neighbor_coords = Vector3(next_node.coords.x + 1, next_node.coords.y, next_node.coords.z)
		if(is_in_bounds(neighbor_coords, item_map) == true):
			if are_tile_indices_at(item_map, blocked_tiles, next_node.coords) == false:
				#Make a new node (with calculations) and add to set
				var temp_x = next_node.coords.x+1
				var temp_y = next_node.coords.y
				if Vector3(temp_x,temp_y,0) == end: #check if reached target
					return( path_from_set(next_node,end) )
					break
	
				#Check if node coords have already been entered in closed_set
				if isVectorInSet(Vector3(temp_x,temp_y,0), closed_set) == false: #If not closed yet
					#Then add a new node for those coords
					var neighbor_node = {
						"g" : next_node.g + 1,
						"h" : abs(end.x - temp_x) + abs(end.y - temp_y), #Manhattan Distance"
						"f" : "not set yet",
						"coords" : Vector3(temp_x, temp_y, 0),
						"last_node" : next_node
					}
					neighbor_node.f = neighbor_node.g + neighbor_node.h #Now calculate f
					open_set.append(neighbor_node)

		#LEFT
		neighbor_coords = Vector3(next_node.coords.x - 1, next_node.coords.y, next_node.coords.z)
		if(is_in_bounds(neighbor_coords, item_map) == true):
			if are_tile_indices_at(item_map, blocked_tiles, next_node.coords) == false:
				#Make a new node (with calculations) and add to set
				var temp_x = next_node.coords.x-1
				var temp_y = next_node.coords.y
				if Vector3(temp_x,temp_y,0) == end: #check if reached target
					return( path_from_set(next_node,end) )
					break
	
				#Check if node coords have already been entered in closed_set
				if isVectorInSet(Vector3(temp_x,temp_y,0), closed_set) == false: #If not closed yet
					#Then add a new node for those coords
					var neighbor_node = {
						"g" : next_node.g + 1,
						"h" : abs(end.x - temp_x) + abs(end.y - temp_y), #Manhattan Distance"
						"f" : "not set yet",
						"coords" : Vector3(temp_x, temp_y, 0),
						"last_node" : next_node
					}
					neighbor_node.f = neighbor_node.g + neighbor_node.h #Now calculate f
					open_set.append(neighbor_node)

		#UP
		neighbor_coords = Vector3(next_node.coords.x, next_node.coords.y - 1, next_node.coords.z)
		if(is_in_bounds(neighbor_coords, item_map) == true):
			if are_tile_indices_at(item_map, blocked_tiles, next_node.coords) == false:
				#Make a new node (with calculations) and add to set
				var temp_x = next_node.coords.x
				var temp_y = next_node.coords.y-1
				if Vector3(temp_x,temp_y,0) == end: #check if reached target
					return( path_from_set(next_node,end) )
					break
	
				#Check if node coords have already been entered in closed_set
				if isVectorInSet(Vector3(temp_x,temp_y,0), closed_set) == false: #If not closed yet
					#Then add a new node for those coords
					var neighbor_node = {
						"g" : next_node.g + 1,
						"h" : abs(end.x - temp_x) + abs(end.y - temp_y), #Manhattan Distance"
						"f" : "not set yet",
						"coords" : Vector3(temp_x, temp_y, 0),
						"last_node" : next_node
					}
					neighbor_node.f = neighbor_node.g + neighbor_node.h #Now calculate f
					open_set.append(neighbor_node)

		#DOWN
		neighbor_coords = Vector3(next_node.coords.x, next_node.coords.y + 1, next_node.coords.z)
		if(is_in_bounds(neighbor_coords, item_map) == true):
			if are_tile_indices_at(item_map, blocked_tiles, next_node.coords) == false:
				#Make a new node (with calculations) and add to set
				var temp_x = next_node.coords.x
				var temp_y = next_node.coords.y+1
				if Vector3(temp_x,temp_y,0) == end: #check if reached target
					return( path_from_set(next_node, end) )
					break
	
				#Check if node coords have already been entered in closed_set
				if isVectorInSet(Vector3(temp_x,temp_y,0), closed_set) == false: #If not closed yet
					#Then add a new node for those coords
					var neighbor_node = {
						"g" : next_node.g + 1,
						"h" : abs(end.x - temp_x) + abs(end.y - temp_y), #Manhattan Distance"
						"f" : "not set yet",
						"coords" : Vector3(temp_x, temp_y, 0),
						"last_node" : next_node
					}
					neighbor_node.f = neighbor_node.g + neighbor_node.h #Now calculate f
					open_set.append(neighbor_node)

		#Finally, add the node to the closed set
		closed_set.append(next_node)

	#end while - If this while broke, means we found target









#33333 END ROGUE CIV FUNCTIONS
############################################################################

#NEED TO MODIFY FOR ALCHEMY!!!!
#POSSIBLY GENERAL USE??? LETS SEE ONCE IMPLEMENTED SINCE IM WRITING THIS BEFORE
#This is a flood search
#Creates a list of nodes
#Nodes have form: (position, distance from target)
#FOR ALCHEMY: searches item_array (form item_array[ypos*map_width + xpos]
func find_tile(global_start, target_symbol, tile_map, item_array, map_width, map_height):
	
	var walkable_tiles = [-1,0,1,2,3,4]
	
	var search_q = [] #The list of nodes to search through
	var search_index = 0 #Which node in the search queue we are currently searching
	
	#Add First node
	var temp_position = tile_map.world_to_map(global_start)
	var temp_distance = 0
	var temp_node = {
					"coords": temp_position, 
					"distance": temp_distance}
	search_q.append(temp_node)

	#Now iterate the search queue , will have to break out when found target
	while(true):
		
		#Bounds check on the search_index (check if we've searched everything...)
		if search_index >= search_q.size():
			return([]) #return empty array
		
		#get the next node
		var next_node = search_q[search_index]
		
		#Increment counter for the next node
		search_index = search_index + 1
		
		#Do some bounds checking, son... 
		if next_node.coords.x < 0 || next_node.coords.x >= map_width || next_node.coords.y < 0 || next_node.coords.y >= map_height:
			continue #don't search there
		
#		#Check if that node was the target?!??!
#		if tile_map.get_cellv(next_node.coords) == target_symbol:
#			break
		#Check if there's an item on that tile
		if item_array[ next_node.coords.y*map_width + next_node.coords.x] != null:
			#Check if it's the item we wanted
			if item_array[ next_node.coords.y*map_width + next_node.coords.x].tile_index == target_symbol:
				#Decrement the search_index so it's pointing to this current node...
				search_index = search_index - 1
				break

			
		#else, need to add all the other nodes onto search queue
		### ALL ADJACENT NODES
		#LEFT
		if tile_map.get_cell(next_node.coords.x-1, next_node.coords.y) in walkable_tiles:
			var new_node = {
				"coords": next_node.coords + Vector2(-1,0),
				"distance": next_node.distance + 1
				}
			#Make sure the new node isn't already in the search_q
			if isVectorInSet(new_node.coords,search_q) == false:
				search_q.append(new_node)
			
		#RIGHT
		if tile_map.get_cell(next_node.coords.x+1, next_node.coords.y) in walkable_tiles:
			var new_node = {
				"coords": next_node.coords + Vector2(1,0),
				"distance": next_node.distance + 1
				}
			#Make sure the new node isn't already in the search_q
			if isVectorInSet(new_node.coords,search_q) == false:
				search_q.append(new_node)
			
		#UP
		if tile_map.get_cell(next_node.coords.x, next_node.coords.y-1) in walkable_tiles:
			var new_node = {
				"coords": next_node.coords + Vector2(0,-1),
				"distance": next_node.distance + 1
				}
			#Make sure the new node isn't already in the search_q
			if isVectorInSet(new_node.coords,search_q) == false:
				search_q.append(new_node)
			
		#DOWN
		if tile_map.get_cell(next_node.coords.x, next_node.coords.y+1) in walkable_tiles:
			var new_node = {
				"coords": next_node.coords + Vector2(0,1),
				"distance": next_node.distance + 1
				}
			#Make sure the new node isn't already in the search_q
			if isVectorInSet(new_node.coords,search_q) == false:
				search_q.append(new_node)
			

	#end while
	print("found target")
	
	#Now need to go through and construct the path back
	var return_path = []
	return_path.push_front(search_q[search_index].coords)
	#cycle through the search_q
	while(search_index != -1):
		#go back down the search_q in reverse
		search_index = search_index - 1
		
		#check if the next tile is within one step of the next return step
		if search_q[search_index].coords.distance_to(return_path[0]) == 1:
			return_path.push_front(search_q[search_index].coords)
		
	
	#return the path
	return(return_path)
	
	



#generate a shade of golden yellow (for the perfume gold topper thingy)
func generate_gold():
	
	var r = 0.7 + rand_range(0,0.3)
	#var g = rand_range(0,r)
	var g = rand_range(0.7,r)
	var b = 0
	
	var gold = Color(r,g,b)
	return(gold)
	

#generate a shade of random brown
func generate_brown():
	
	var r = 0.6 + rand_range(0,0.2)
	var g = r - rand_range(0,0.2) - 0.2 #between a fifth and 2 fifths less than r
	var b = rand_range(0,g) #no more than g
	
	var brown = Color(r,g,b)
	return(brown)

#generate a pastel color -> lots of white
func generate_pastel():
	var r = rand_range(0.8, 1.0); 
	var g = rand_range(0.8, 1.0); 
	var b = rand_range(0.8, 1.0); 

	var pastel = Color(r,g,b);
	return(pastel) 
	

#Generates a color who's channels are all above a threshhold
func generate_darkenable_color(thresh):
	var r = 0
	while(true):
		if r > thresh:
			break
		else:
			r = randf()
	var g = 0
	while(true):
		if g > thresh:
			break
		else:
			g = randf()
	var b = 0
	while(true):
		if b > thresh:
			break
		else:
			b = randf()
	
	var color = Color(r,g,b)
	return(color)

##same as above, but you set a limit
#func generate_pastel_limit(limit):
#	var r = rand_range(limit, 1.0)
#	var g = rand_range(limit, 1.0)
#	var b = rand_range(limit, 1.0)
#	var color = Color(r,g,b)
#	return(color)
#
##same as above, but below limit
#func generate_dark_limit(limit):
#	var r = rand_range(0.0, limit)
#	var g = rand_range(0.0, limit)
#	var b = rand_range(0.0, limit)
#	var color = Color(r,g,b)
#	return(color)

#COlor Algorithms...

#Shift all the channels of a color by a certain amount...
func color_shift(in_col, shift_amt):
	var r = in_col.r + shift_amt;
	var g = in_col.g + shift_amt;
	var b = in_col.b + shift_amt;
	
	var out_col = Color(r,g,b)
	return(out_col)

###STORY ALGORITHMS!!!
func generateName():
	var consonants = "bcdfghjklmnpqrstvwxyz"
	var vowels = "aeiou"
	
	var temp_name = "" #the string we'll be returning
	var temp_char = "" #temporary character to store the char we'll be appending
	
	# ADD A CONSONANT
	temp_char = consonants[randi()%consonants.length()]
	temp_name = temp_name + temp_char
	
	#ADD A VOWEL
	temp_char = vowels[randi()%vowels.length()]
	temp_name = temp_name + temp_char	
	
	# ADD A CONSONANT (TWICE)
	temp_char = consonants[randi()%consonants.length()]
	temp_name = temp_name + temp_char
	temp_name = temp_name + temp_char
	
	#ADD A VOWEL
	temp_char = vowels[randi()%vowels.length()]
	temp_name = temp_name + temp_char
	temp_name = temp_name.capitalize()

	return(temp_name)
	
#Name Evolution
# Grant a new syllable to the previously generated names...
# Xonno -> Xo'Noku

#CREATUVE NOTES>>>>
#SOme name-endings
#ex, liyah, fiah, ,,,,


#Human(ish) stuff

#Generate a random hair color
#Selecte from three bases -> black, blonde, red
func generate_hair_color():
	
	#The components to be generated/calculated
	var r 
	var g
	var b
	
	var choice = randi()%3 #choose one of three hair colors...
	match(choice):
		0:	
			#GOLDEN HAIR
			r = rand_range(0.85,1)
			g = rand_range(0.7,0.75)
			b = 0

		1:
			#RED HAIR
			#Red between 175 and 255 -> 0.69 and 1
			#Green no more than 125 less than red -> 0.49
			#Green at least 50 less than red -> 0.2
			#No Blue
			r = rand_range(0.69,1)
			g = r - rand_range(0.2,0.49)
			b = 0
		
		2:
			#BLACK HAIR... Kinda color-tinted though
			#Red can go up to 100 -> 0.39
			#Green can only go up to 50 -> 0.2
			#Blue can go up to 100 -> 0.39
			r = rand_range(0,0.39)
			g = rand_range(0,0.2)
			b = rand_range(0,0.39)
	
	var hair_color = Color(r,g,b)
	
	return(hair_color)

#Generate browns for skin colors
#You start with a red between 175 and 245 -> 0.69 to 0.96
#Then a constant delta is subrtracted for green
#Then the same constant delta is subtracted for blue
#Delta goes between 18 and 50 -> 0.07 to 0.2
#BUT!!!!
#Delta should be higher for lower red.... Under 200 -> 0.78
#For lower, delta between 30 and 50 -> 0.12 to 0.2
func generate_skin_color():
	
	var r = rand_range(0.60,0.96)
	var delta #The delta we subtract from r for g, and from g for b
	if r < 0.78:
		delta = rand_range(0.12,0.2)
	else:
		delta = rand_range(0.07,0.2)
	var g = r - delta
	var b = g - delta
	var skin_color = Color(r,g,b)

	return(skin_color)
	

