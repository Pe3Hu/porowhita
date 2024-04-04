extends Polygon2D


#region vars
@onready var index = $Index

var mainland = null
var grid = null
var neighbors = {}
var trails = {}
var directions = {}
var region = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	mainland = input_.mainland
	grid = input_.grid

	init_basic_setting()


func init_basic_setting() -> void:
	if grid != null:
		position = grid * Global.vec.size.area
		mainland.grids[grid] = self
		init_index()
		#set_regions()

	set_vertexs()


func set_vertexs() -> void:
	var order = "even"
	var corners = 4
	var r = Global.num.area.r
	var vertexs = []

	for corner in corners:
		var vertex = Global.dict.corner.vector[corners][order][corner] * r
		vertexs.append(vertex)

	set_polygon(vertexs)


func init_index() -> void:
	var input = {}
	input.type = "number"
	input.subtype = Global.num.index.area
	index.set_attributes(input)
	Global.num.index.area += 1


func set_region(region_: Node2D) -> void:
	if region != null:
		region.areas.erase(self)
	
	region = region_
	region.areas.append(self)
	
	#paint_to_match()


func paint_to_match() -> void:
	color = Global.color.region[region.type]
#endregion


func get_trails_around_socket_perimeter() -> Array:
	var areas = []

	for direction in Global.dict.neighbor.diagonal:
		var _grid = grid + direction
		var area = mainland.grids.area[_grid]
		areas.append(area)

	var _trails = mainland.get_trails_based_on_areas(areas)
	return _trails
