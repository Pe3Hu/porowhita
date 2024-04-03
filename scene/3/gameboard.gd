extends MarginContainer


#region vars
@onready var available = $VBox/Cards/Available
@onready var discharged = $VBox/Cards/Discharged
@onready var broken = $VBox/Cards/Broken
@onready var hand = $VBox/Cards/Hand
@onready var storage = $VBox/Storage

var god = null
var capacity = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	input_.gameboard = self
	
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	custom_minimum_size = Global.vec.size.gameboard
	capacity.limit = Global.num.hand.n
	capacity.current = int(capacity.limit)
	
	var input = {}
	input.gameboard = self
	storage.set_attributes(input_)
	init_starter_kit_cards()
	
	for key in Global.dict.area.next:
		if key != null:
			input_.type = key
			var cardstack = get(key)
			cardstack.set_attributes(input_)


func init_starter_kit_cards() -> void:
	var values = {}
	values.primary = 2
	values.secondary = 1
	
	var aspects = {}
	
	for aspect in Global.arr.aspect:
		aspects[aspect] = 1
	
	for pair in Global.dict.aspect.pair:
		var input = {}
		input.proprietor = self
		input.rank = 1
		input.area = "discharged"
		input.prestige = {}
		input.prestige.type = "soldier"
		input.prestige.subtype = "recruit"
		input.aspects = aspects.duplicate()
		
		for key in pair:
			input.aspects[pair[key]] = int(values[key])
	
		var card = Global.scene.card.instantiate()
		discharged.cards.add_child(card)
		card.set_attributes(input)
		card.set_gameboard_as_proprietor(self)
	
	assign_officers()


func assign_officers() -> void:
	var options = []
	options.append_array(available.cards.get_children())
	
	for _i in Global.num.officer.n:
		var card = options.pick_random()
		options.erase(card)
		promote_to_basic_officer(card)


func promote_to_basic_officer(card_: MarginContainer) -> void:
	var values = {}
	values.primary = 2
	values.secondary = 1
	
	var primary = card_.get_maximum_aspect()
	
	for aspect in card_.aspects.get_children():
		var value = int(values.secondary)
		
		if aspect == primary:
			value = int(values.primary)
		
		card_.change_base_aspect_value(aspect.subtype, value)
	
	var input = {}
	input.proprietor = card_
	input.type = "officer"
	input.subtype = "recruit"
	card_.prestige.set_attributes(input)
#endregion



func refill_hand() -> void:
	var cardstack = get(Global.dict.area.prior[hand.type])
	
	cardstack.advance_card_based_on_prestige("officer")
	
	while hand.cards.get_child_count() < capacity.current:
		cardstack.advance_card_based_on_prestige("soldier")


func discard_hand() -> void:
	hand.advance_all_cards()


func fill_storage() -> void:
	for card in hand.cards.get_children():
		for aspect in card.aspects.get_children():
			storage.obtain_aspect(aspect)
