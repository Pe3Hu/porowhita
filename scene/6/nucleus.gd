extends MarginContainer


#region vars
@onready var aspects = $Aspects

var proprietor = null
var priorities = null
var subtypes = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	priorities = input_.priorities
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_aspects()


func init_aspects() -> void:
	for subtype in Global.arr.aspect:
		add_aspect(subtype)
	
	var total = 0
	
	for subtype in priorities:
		total += priorities[subtype]
	
	for subtype in priorities:
		priorities[subtype] = float(priorities[subtype]) / total


func add_aspect(subtype_: String) -> void:
	var input = {}
	input.proprietor = self
	input.type = "aspect"
	input.subtype = subtype_
	input.value = 0

	var token = Global.scene.token.instantiate()
	aspects.add_child(token)
	token.set_attributes(input)
	
	subtypes[subtype_] = token
#endregion


func obtain_aspect(aspect_: MarginContainer) -> void:
	var aspect = subtypes[aspect_.subtype]
	var value = aspect_.get_value()
	aspect.change_value(value)


func change_aspect(subtype_: String, value_: int) -> void:
	var aspect = subtypes[subtype_]
	aspect.change_value(value_)


func reset() -> void:
	for aspect in aspects.get_children():
		aspect.set_value(0)
