extends MarginContainer


#region var
@onready var settlements = $HBox/Settlements
@onready var communities = $HBox/Communities

var planet = null
var manageable = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	planet = input_.planet
	
	init_basic_setting()


func init_basic_setting() -> void:
	pass


func init_communities() -> void:
	var datas = []
	datas.append_array(settlements.get_children())
	datas.sort_custom(func(a, b): return a.area.index.get_value() < b.area.index.get_value())
	
	#while !datas.is_empty():
		#var settlement = datas.pop_front()
		#add_community(settlement)
	
	var settlement = datas.pop_front()
	add_community(settlement)
	manageable = communities.get_child(0)
	manageable.visible = true


func add_community(settlement_: MarginContainer) -> void:
	settlements.remove_child(settlement_)
	var input = {}
	input.policy = self
	input.settlement = settlement_
	
	var community = Global.scene.community.instantiate()
	communities.add_child(community)
	community.set_attributes(input)
#endregion
