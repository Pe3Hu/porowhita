extends Node2D


#region vars
var mainland = null
var type = null
var areas = []
var frontier = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	mainland = input_.mainland
	type = input_.type

	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	add_area(input_.area)


func add_area(area_: Polygon2D) -> void:
	areas.append(area_)
	area_.biome = self
	
	for trail in area_.trails:
		var area = area_.trails[trail]
		
		if area.biome == null:
			frontier[area] = 0
			
			for _trail in area.trails:
				var neighbor = area.trails[trail]
				
				if neighbor.biome == self:
					frontier[area] += 1
			
			if frontier[area] == 0:
				frontier.erase(area)
	
	for biome in mainland.biomes.get_children():
		if biome.frontier.has(area_):
			biome.frontier.erase(area_)


func bestow_area(biome_: Node2D, area_: Polygon2D) -> void:
	areas.erase(area_)
	biome_.areas.append(area_)
	area_.biome = biome_
