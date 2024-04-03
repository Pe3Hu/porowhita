extends MarginContainer


#region vars
@onready var bg = $BG
@onready var aspects = $Aspects
@onready var rank = $Specifications/Rank
@onready var prestige = $Specifications/Prestige

var proprietor = null
var area = null
var values = {}
var experience = 0
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	area = input_.area
	
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	custom_minimum_size = Global.vec.size.card
	init_tokens(input_)
	init_bg()


func init_tokens(input_: Dictionary) -> void:
	var input = {}
	input.proprietor = self
	input.type = input_.prestige.type
	input.subtype = input_.prestige.subtype
	prestige.set_attributes(input)
	
	input.type = "specification"
	input.subtype = "rank"
	input.value = input_.rank
	rank.set_attributes(input)
	
	input.type = "aspect"
	
	for subtype in input_.aspects:
		input.subtype = subtype
		input.value = input_.aspects[subtype]
		
		var token = Global.scene.token.instantiate()
		aspects.add_child(token)
		token.set_attributes(input)
		values[subtype] = input.value
		experience += input.value


func init_bg() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.SLATE_GRAY
	bg.set("theme_override_styles/panel", style)


func advance_area() -> void:
	var cardstack = null
	
	if area == null:
		area = Global.dict.area.next[area]
		advance_area()
	else:
		cardstack = proprietor.get(area)
		cardstack.cards.remove_child(self)
	
		area = Global.dict.area.next[area]
		cardstack = proprietor.get(area)
		cardstack.cards.add_child(self)


func set_gameboard_as_proprietor(gameboard_: MarginContainer) -> void:
	var cardstack = proprietor.get(area)
	var market = false
	
	if cardstack == null:
		cardstack = proprietor
		market = true
	
	cardstack.cards.remove_child(self)
	proprietor = gameboard_
	area = "discharged"
	
	cardstack = proprietor.get(area)
	cardstack.cards.add_child(self)
	
	if !market:
		advance_area()


func get_aspect_based_on_subtype(subtype_: String) -> Variant:
	for aspect in aspects.get_children():
		if aspect.subtype == subtype_:
			return aspect
	
	return null


func change_base_aspect_value(subtype_: String, value_: int) -> void:
	values[subtype_] += value_
	var aspect = get_aspect_based_on_subtype(subtype_)
	aspect.change_value(value_)
	experience += value_
	update_rank()


func update_rank() -> void:
	var milestone = pow(rank.get_value() + 2, 2)
	
	while experience >= milestone:
		rank.change_value(1)
		milestone = pow(rank.get_value() + 2, 2)
#endregion


func get_maximum_aspect() -> MarginContainer:
	var datas = []
	datas.append_array(aspects.get_children())
	datas.sort_custom(func(a, b): return a.get_value() > b.get_value())
	var aspect = datas.front()
	return aspect
