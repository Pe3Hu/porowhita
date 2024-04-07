extends MarginContainer


#region vars
@onready var settlements = $HBox/Settlements
@onready var borderlands = $HBox/Borderlands

var policy = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	policy = input_.policy

	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	add_settlement(input_.settlement)


func add_settlement(settlement_: MarginContainer) -> void:
	settlements.add_child(settlement_)
	update_borderlands(settlement_)


func update_borderlands(settlement_: MarginContainer) -> void:
	var areas = []
	
	for borderland in borderlands.get_children():
		if borderland.area == settlement_.area:
			borderland.crush()
		else:
			areas.append(borderland.area)
	
	for trail in settlement_.area.trails:
		var area = settlement_.area.trails[trail]
		
		if !areas.has(area):
			add_borderland(area)


func add_borderland(area_: Polygon2D) -> void:
	var input = {}
	input.community = self
	input.area = area_
	
	var borderland = Global.scene.borderland.instantiate()
	borderlands.add_child(borderland)
	borderland.set_attributes(input)
#endregion
