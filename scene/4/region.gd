extends Node2D


#region vars
var mainland = null
var type = null
var areas = []
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	mainland = input_.mainland
	type = input_.type

	init_basic_setting()


func init_basic_setting() -> void:
	init_areas()


func init_areas() -> void:
	if type != Global.arr.region.back():
		var corner = Global.dict.region.corner[type]
		var direction = Global.dict.region.direction[type]
		var n = Global.num.area.n / 2
		
		for _i in n:
			for _j in n:
				var grid = corner + Vector2(_j * direction.x, _i * direction.y)
				var area = mainland.grids[grid]
				area.set_region(self)
	else:
		var k = (Global.num.area.n - Global.num.area.nesw) / 2
		var corner = Vector2(k, k)
		var n = Global.num.area.nesw
		
		for _i in n:
			for _j in n:
				var grid = corner + Vector2(_j, _i)
				var area = mainland.grids[grid]
				area.set_region(self)
#region init
