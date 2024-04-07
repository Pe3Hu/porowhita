extends MarginContainer


#region vars
@onready var index = $HBox/Index
@onready var monsters = $HBox/Monsters

var community = null
var area = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	community = input_.community
	area = input_.area

	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()
	area.index.visible = true
	refill_monsters()


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "index"
	input.subtype = "borderland"
	input.value = area.index.get_value()
	index.set_attributes(input)
	
	index.init_bg()
	var color = Global.color.danger[area.danger]
	index.set_bg_color(color)


func refill_monsters() -> void:
	add_monster()


func add_monster() -> void:
	var options = Global.dict.monster.biome[area.biome.type]
	var input = {}
	input.borderland = self
	roll_rank(input)
	roll_age(input)
	input.embodiment = options.pick_random()
	
	var monster = Global.scene.monster.instantiate()
	monsters.add_child(monster)
	monster.set_attributes(input)


func roll_rank(input_: Dictionary) -> void:
	var options = Global.dict.danger.rank[area.danger]
	input_.rank = Global.get_random_key(options)


func roll_age(input_: Dictionary) -> void:
	var options = Global.dict.danger.age[area.danger]
	input_.age = Global.get_random_key(options)
	
	var limits = Global.dict.age.month[input_.age]
	Global.rng.randomize()
	input_.month = Global.rng.randi_range(limits.min, limits.max)
#endregion
