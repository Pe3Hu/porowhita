extends Polygon2D


#region vars
@onready var index = $Index

var mainland = null
var grid = null
var neighbors = {}
var trails = {}
var directions = {}
var region = null
var remoteness = {}
var settlement = null
var isolations = []
var biome = null
var danger = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	mainland = input_.mainland
	grid = input_.grid

	init_basic_setting()


func init_basic_setting() -> void:
	if grid != null:
		grid.x = int(grid.x)
		grid.y = int(grid.y)
		position = grid * Global.vec.size.area
		mainland.grids[grid] = self
		init_index()
		#set_regions()

	set_vertexs()
	set_remoteness()


func init_index() -> void:
	var input = {}
	input.type = "number"
	input.subtype = Global.num.index.area
	index.set_attributes(input)
	Global.num.index.area += 1


func set_vertexs() -> void:
	var order = "even"
	var corners = 4
	var r = Global.num.area.r
	var vertexs = []

	for corner in corners:
		var vertex = Global.dict.corner.vector[corners][order][corner] * r
		vertexs.append(vertex)

	set_polygon(vertexs)


func set_remoteness() -> void:
	var x = abs(Global.num.area.col / 2 - grid.x)
	var y = abs(Global.num.area.row / 2 - grid.y)
	remoteness.center = x + y
	remoteness.settlement = null


func set_region(region_: Node2D) -> void:
	if region != null:
		region.areas.erase(self)
	
	region = region_
	region.areas.append(self)
	
	paint_to_match("region")


func paint_to_match(layer_: String) -> void:
	match layer_:
		"region":
			color = Global.color.region[region.type]
		"biome":
			color = Global.color.biome[biome.type]
		"wilderness":
			var v = 1 - float(remoteness.settlement) / Global.num.remoteness.danger
			color = Color.from_hsv(0, 0, v)
		"danger":
			color = Global.color.danger[danger]
#endregion


func get_trails_around_socket_perimeter() -> Array:
	var areas = []

	for direction in Global.dict.neighbor.diagonal:
		var _grid = grid + direction
		var area = mainland.grids.area[_grid]
		areas.append(area)

	var _trails = mainland.get_trails_based_on_areas(areas)
	return _trails
