extends MarginContainer


#region vars
@onready var triangles = $Triangles

var monster = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	monster = input_.monster

	init_basic_setting()


func init_basic_setting() -> void:
	custom_minimum_size = Vector2(Global.vec.size.omen)
	set_vertexs()


func set_vertexs() -> void:
	var order = "even"
	var r = Global.num.omen.r
	var turn = Global.dict.monster.embodiment[monster.embodiment].order
	var corners = Global.num.omen.n
	triangles.position = Global.vec.size.omen * 0.5
	var indexs = []
	
	for _i in Global.num.omen.aspect:
		var index = (turn + _i) % corners
		indexs.append(index)
	
	for _i in corners:
		var vertexs = [Vector2()]
	
		for _j in 2:
			var corner = (_i + _j) % corners
			var vertex = Global.dict.corner.vector[corners][order][corner] * r
			vertexs.append(vertex)
		
		var triangle = Polygon2D.new()
		triangle.set_polygon(vertexs)
		triangles.add_child(triangle)
		
		if turn == _i:
			triangle.color = Global.color.biome[monster.borderland.area.biome.type]
		else:
			if indexs.has(_i):
				var aspect = monster.aspects.back()
				triangle.color = Global.color.aspect[aspect]
			else:
				var aspect = monster.aspects.front()
				triangle.color = Global.color.aspect[aspect]
				
			
#endregion
