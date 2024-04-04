extends MarginContainer


#region var
@onready var areas = $Areas
@onready var trails = $Trails
@onready var regions = $Regions

var planet = null
var grids = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	planet = input_.planet
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_offsets()
	init_areas()
	init_trails()
	init_regions()


func init_offsets() -> void:
	custom_minimum_size = Global.vec.size.mainland
	var offest = Vector2.ONE * Global.num.area.r
	var keys = ["trails", "areas"]
	
	for key in keys:
		var node = get(key)
		node.position = offest


func init_areas() -> void:
	var corners = {}
	corners.x = [0, Global.num.area.col - 1]
	corners.y = [0, Global.num.area.row - 1]
	
	for _i in Global.num.area.row:
		for _j in Global.num.area.col:
			var input = {}
			input.mainland = self
			input.grid = Vector2(_j, _i)
			
			if corners.y.has(_i) or corners.x.has(_j):
				if corners.y.has(_i) and corners.x.has(_j):
					input.type = "corner"
				else:
					input.type = "edge"
			else:
				input.type = "center"
	
			var area = Global.scene.area.instantiate()
			areas.add_child(area)
			area.set_attributes(input)


func init_trails() -> void:
	for area in areas.get_children():
		for direction in Global.dict.neighbor.windrose:
			var grid = area.grid + direction

			if grids.has(grid):
				var neighbor = grids[grid]
				
				if !area.neighbors.has(neighbor):
					add_trail(area, neighbor, direction)
	
	clear_intersecting_trails()
	clear_redundant_trails()


func add_trail(first_: Polygon2D, second_: Polygon2D, direction_: Vector2) -> void:
	var input = {}
	input.mainland = self
	input.areas = [first_, second_]

	var trail = Global.scene.trail.instantiate()
	trails.add_child(trail)
	trail.set_attributes(input)

	first_.neighbors[second_] = trail
	second_.neighbors[first_] = trail
	first_.trails[trail] = second_
	second_.trails[trail] = first_
	first_.directions[direction_] = trail
	var index = Global.dict.neighbor.windrose.find(direction_)
	var n = Global.dict.neighbor.windrose.size()
	index = (index + n / 2) % n
	second_.directions[Global.dict.neighbor.windrose[index]] = trail


func clear_intersecting_trails() -> void:
	var n = Global.num.area.n - 1
	var k = Global.num.area.n - 2
	var exceptions = []
	exceptions.append(Vector2(0, 0))
	exceptions.append(Vector2(k, 0))
	exceptions.append(Vector2(k, k))
	exceptions.append(Vector2(0, k))
	var directions = []
	directions.append(Vector2(1, -1))
	directions.append(Vector2(1, 1))
	directions.append(Vector2(1, -1))
	directions.append(Vector2(1, 1))
	var offsets = []
	offsets.append(Vector2(0, 1))
	offsets.append(Vector2(0, 0))
	offsets.append(Vector2(0, 1))
	offsets.append(Vector2(0, 0))
	
	for _i in n:
		for _j in n:
			var grid = Vector2(_j, _i)
			
			if !exceptions.has(grid):
				var options = []
				var area = grids[grid]
				var direction = Vector2(1, 1)
				var trail = area.directions[direction]
				options.append(trail)
				
				grid.x += 1
				area = grids[grid]
				direction = Vector2(-1, 1)
				trail = area.directions[direction]
				options.append(trail)
				
				trail = options.pick_random()
				trail.crush()
	
	for _i in exceptions.size():
		var grid = exceptions[_i] + offsets[_i]
		var area = grids[grid]
		var direction = directions[_i]
		var trail = area.directions[direction]
		trail.crush()


func clear_redundant_trails() -> void:
	var redundants = {}
	var exceptions = []
	var problems = []
	var maximum = 0
	
	for area in areas.get_children():
		var n = area.trails.keys().size()
		
		if n > Global.num.trail.min:
			if !redundants.has(n):
				redundants[n] = []
				
				if maximum < n:
					maximum = int(n)
			
			redundants[n].append(area)
		else:
			exceptions.append(area)
	
	#reduce trails each area of which exceeds the maximum number of trails
	while maximum > Global.num.trail.max:
		if redundants[maximum].is_empty():
			redundants.erase(maximum)
			maximum -= 1
		else:
			var area = redundants[maximum].pick_random()
			var options = []
			
			for trail in area.trails:
				if !exceptions.has(area.trails[trail]):
					options.append(trail)
			
			if !options.is_empty():
				var trail = options.pick_random()
				var flag = true
				
				for _area in trail.areas:
					if exceptions.has(_area):
						flag = false
			
				if flag:
					var keys = redundants.keys()
					keys.sort()
					
					for _area in trail.areas:
						for _i in keys:
							if redundants[_i].has(_area):
								redundants[_i].erase(_area)
								var _j = _i - 1
								
								if _j > Global.num.trail.min:
									redundants[_j].append(_area)
								else:
									exceptions.append(_area)
					
					trail.crush()
			else:
				redundants[maximum].erase(area)
				problems.append(area)
				
				#if maximum - 1 > Global.num.trail.min:
					#redundants[maximum - 1].append(area)
				#else:
					#exceptions.append(area)
	
	#reduce trails with only one area exceeding the maximum number of trails
	#while !redundants[maximum].is_empty():
		#var area = redundants[maximum].pick_random()
		#var options = []
		#
		#for trail in area.trails:
			#if redundants[maximum].has(area.trails[trail]):
				#options.append(trail)
		#
		#if !options.is_empty():
			#var trail = options.pick_random()
			#
			#for _area in trail.areas:
				#redundants[maximum].erase(_area)
				#
				#if maximum - 1 > Global.num.trail.min:
					#redundants[maximum-1].append(area)
			#
			#trail.crush()
		#else:
			#redundants[maximum].erase(area)
			#
			#if maximum - 1 > Global.num.trail.min:
				#redundants[maximum-1].append(area)
	
	##reduce trails with only one area exceeding the maximum number of trails
	#while !redundants[maximum].is_empty():
		#var area = redundants[maximum].pick_random()
		#redundants[maximum].erase(area)
		#var options = []
		#
		#for trail in area.trails:
			#var _area = trail.get_another_area(area)
			#
			#if !total.has(_area):
				#options.append(trail)
		#
		#var trail = options.pick_random()
		#for _area in trail.areas:
			#redundants[maximum].erase(_area)
		#
		#trail.crush()
	
	
	for area in areas.get_children():
		var n = area.trails.keys().size() - 3
		var hue = float(n) / 6
		area.color = Color.from_hsv(hue, 0.9, 0.9)
		
		if n == -1:
			area.color = Color.BLACK


func init_regions() -> void:
	for type in Global.arr.region:
		add_region(type)


func add_region(type_: String) -> void:
	var input = {}
	input.mainland = self
	input.type = type_
	
	var region = Global.scene.region.instantiate()
	regions.add_child(region)
	region.set_attributes(input)
#endregion
