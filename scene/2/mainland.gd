extends MarginContainer


#region var
@onready var areas = $Areas
@onready var trails = $Trails
@onready var regions = $Regions
@onready var settlements = $Settlements
@onready var biomes = $Biomes

var planet = null
var grids = {}
var dangers = {}
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
	init_settlements()
	init_biomes()


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
	
	for area in areas.get_children():
		var n = area.trails.keys().size() - Global.num.trail.min
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


func init_settlements() -> void:
	var options = {}
	
	for area in areas.get_children():
		if area.trails.keys().size() == 4 and area.region.type == "nesw":
			if !options.has(area.remoteness.center):
				options[area.remoteness.center] = []
			
			options[area.remoteness.center].append(area)
	
	while !options.keys().is_empty():
		find_area_for_settlement(options)
	
	options = {}
	
	for area in areas.get_children():
		if area.trails.keys().size() == 4 and area.isolations.is_empty():
			if !options.has(area.remoteness.center):
				options[area.remoteness.center] = []
			
			options[area.remoteness.center].append(area)
	
	while !options.keys().is_empty():
		find_area_for_settlement(options)


func find_area_for_settlement(options_: Dictionary) -> void:
	var keys = options_.keys()
	keys.sort()
	var area = options_[keys.back()].pick_random()
	add_settlement(area)
	
	var waves = {}
	waves.next = []
	waves.previous = [area]
	waves.total = [area]
	
	for _i in Global.num.remoteness.settlement:
		for _area in waves.previous:
			for trail in _area.trails:
				var neighbor = _area.trails[trail]
				
				if !waves.total.has(neighbor):
					waves.next.append(neighbor)
					waves.total.append(neighbor)
		
		waves.total.append_array(waves.next)
		waves.previous = []
		waves.previous.append_array(waves.next)
		waves.next = []
	
	for _area in waves.total:
		_area.isolations.append(area.settlement)
		
		if options_.has(_area.remoteness.center):
			if options_[_area.remoteness.center].has(_area):
				options_[_area.remoteness.center].erase(_area)
				
				if options_[_area.remoteness.center].is_empty():
					options_.erase(_area.remoteness.center)


func add_settlement(area_: Polygon2D) -> void:
	var input = {}
	input.mainland = self
	input.area = area_
	
	var settlement = Global.scene.settlement.instantiate()
	settlements.add_child(settlement)
	settlement.set_attributes(input)


func init_biomes() -> void:
	var k = Global.num.area.n / 2
	var grid = Vector2.ONE * k
	var centers = []
	
	for direction in Global.dict.neighbor.zero:
		var _grid = grid - direction
		centers.append(_grid)
	
	var directions = {}
	
	for direction in Global.dict.neighbor.linear2:
		directions[direction] = []
		
		for center in centers:
			var _grid = center + direction * (k - 1)
			var area = get_area_based_on_grid(_grid)
			
			if area != null:
				directions[direction].append(area)
	
	for type in Global.arr.terrain:
		var direction = directions.keys().pick_random()
		var area = directions[direction].pick_random()
		add_biome(type, area)
		directions.erase(direction)
	
	assign_ares_to_biomes()
	redistribute_disputed_araes()
	update_areas_wilderness()
	update_areas_danger()
	paint_areas("danger")


func add_biome(type_: String, area_: Polygon2D) -> void:
	var input = {}
	input.mainland = self
	input.type = type_
	input.area = area_
	
	var biome = Global.scene.biome.instantiate()
	biomes.add_child(biome)
	biome.set_attributes(input)


func assign_ares_to_biomes() -> void:
	var options = []
	
	for area in areas.get_children():
		if area.biome == null:
			options.append(area)
	
	while !options.is_empty():
		var terrains = []
		terrains.append_array(Global.arr.terrain)
		terrains.shuffle()
		
		while !terrains.is_empty():
			var terrain = terrains.pick_random()
			spread_biome(terrain, options)
			terrains.erase(terrain)


func redistribute_disputed_araes() -> void:
	var flag = true
	
	while flag:
		flag = false
	
		for area in areas.get_children():
			var terrains = {}
			
			for trail in area.trails:
				var _area = area.trails[trail]
				
				if !terrains.has(_area.biome.type):
					terrains[_area.biome.type] = 0
				
				terrains[_area.biome.type] += 1
			
			var dominants = [terrains.keys().front()]
			
			for terrain in terrains:
				if terrains[terrain] == terrains[dominants.front()] and !dominants.has(terrain):
					dominants.append(terrain)
				elif terrains[terrain] > terrains[dominants.front()]:
					dominants = [terrain]
			
			if !dominants.has(area.biome.type):
				if terrains[dominants.front()] > 1:
					var biome = get_biome_based_on_terrain(dominants.front())
					area.biome.bestow_area(biome, area)
					#area.color = Color.BLACK
					flag = true


func spread_biome(terrain_: String, options_: Array) -> void:
	var biome = get_biome_based_on_terrain(terrain_)
	
	if !biome.frontier.keys().is_empty():
		var area = Global.get_random_key(biome.frontier)
		biome.add_area(area)
		options_.erase(area)


func update_areas_wilderness() -> void:
	var waves = {}
	waves.next = []
	waves.previous = []
	var remoteness = 0
	
	for region in regions.get_children(): 
		for settlement in region.settlements:
			waves.previous.append(settlement.area)
			settlement.area.remoteness.settlement = int(remoteness)
	
	while !waves.previous.is_empty():
		remoteness += 1
		
		for area in waves.previous:
			for trail in area.trails:
				var _area = area.trails[trail]
				
				if _area.remoteness.settlement == null:
					waves.next.append(_area)
					_area.remoteness.settlement = int(remoteness)
		
		waves.previous = []
		waves.previous.append_array(waves.next)
		waves.next = []


func update_areas_danger() -> void:
	var datas = {}
	
	for area in areas.get_children():
		var remoteness = 0
		
		if area.settlement == null:
			for trail in area.trails:
				var _area = area.trails[trail]
				
				remoteness += _area.remoteness.settlement
		
		var types = []
		types.append_array(Global.dict.danger.rank.keys())
		
		while area.danger == null:
			var danger = types.pop_front()
			
			if Global.dict.danger.rank[danger].has(remoteness):
				area.danger = int(danger)
				
				if !datas.has(danger):
					datas[danger] = []
				
				datas[danger].append(area)
	
	for danger in Global.dict.danger.rank:
		if datas.has(danger):
			dangers[danger] = datas[danger]
	
	#for danger in dangers:
	#	print([danger, dangers[danger].size()])


func get_biome_based_on_terrain(terrain_: String) -> Variant:
	for biome in biomes.get_children():
		if biome.type == terrain_:
			return biome
	
	return null


func get_area_based_on_grid(grid_: Vector2) -> Variant:
	grid_.x = int(grid_.x)
	grid_.y = int(grid_.y)
	
	
	if grids.has(grid_):
		return grids[grid_]
	
	return null


func paint_areas(layer_: String) -> void:
	reset_areas_color()
	
	for area in areas.get_children():
		match layer_:
			"only settlement with region":
				if area.settlement != null:
					area.paint_to_match("region")
		match layer_:
			"only settlement with biome":
				if area.biome != null:
					area.paint_to_match("biome")
				
				if area.settlement != null:
					area.paint_to_match("region")
			"biome":
				if area.biome != null:
					area.paint_to_match("biome")
			"wilderness":
				if area.settlement != null:
					area.paint_to_match("region")
				else:
					area.paint_to_match("wilderness")
			"danger":
				if area.settlement != null:
					area.paint_to_match("danger")
					#area.color = Color.BLACK
				else:
					area.paint_to_match("danger")


func reset_areas_color() -> void:
	for area in areas.get_children():
		area.color = Color.GRAY
#endregion
