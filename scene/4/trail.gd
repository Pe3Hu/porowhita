extends Line2D


#region vars
@onready var index = $Index

var mainland = null
var areas = []
var status = null
var side = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	mainland = input_.mainland
	areas = input_.areas

	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()
	set_vertexs()
	#advance_status()


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "index"
	input.subtype = "trail"
	input.value = Global.num.index.trail
	index.set_attributes(input)
	Global.num.index.trail += 1


func set_vertexs() -> void:
	for area in areas:
		var vertex = area.position
		add_point(vertex)
		index.position += vertex

	index.position /= areas.size()
	index.position.x -= index.custom_minimum_size.x * 0.5
	index.position.y -= index.custom_minimum_size.y * 0.5


func advance_status() -> void:
	status = Global.dict.chain.status[status]
	paint_to_match()


func paint_to_match() -> void:
	default_color = Global.color.trail[status]


func crush() -> void:
	for area in areas:
		for direction in area.directions:
			if area.directions[direction] == self:
				area.directions.erase(direction)
		
		#for neighbor in area.neighbors:
			#if area.neighbors[neighbor] == self:
				#area.neighbors.erase(neighbor)
		
		area.trails.erase(self)
	
	mainland.trails.remove_child(self)
	queue_free()
#endregion


func get_another_area(area_: Polygon2D) -> Variant:
	if areas.has(area_):
		for area in areas:
			if area != area_:
				return area

	return null


func update_axis() -> void:
	for axis in Global.arr.axis:
		var flag = true

		for area in areas:
			flag = flag and mainland.axises.area[axis].has(area)

		if flag:
			mainland.axises.trail[axis].append(self)
			update_side()


func update_side() -> void:
	var sides = {}

	for area in areas:
		for _side in area.sides:
			if !sides.has(_side):
				sides[_side] = 0

			sides[_side] += 1

	for _side in sides:
		if sides[_side] == 2:
			side = _side
			mainland.sides.trail[side].append(self)
