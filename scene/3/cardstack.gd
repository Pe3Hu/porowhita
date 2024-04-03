extends MarginContainer


#region vars
@onready var cards = $Cards

var gameboard = null
var type = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	gameboard = input_.gameboard
	type = input_.type


func reshuffle_all_cards() -> void:
	var _cards = []
	
	while cards.get_child_count() > 0:
		var card = cards.get_child(0)
		cards.remove_child(card)
		_cards.append(card)
	
	_cards.shuffle()
	
	for card in _cards:
		cards.add_child(card)


func advance_random_card() -> void:
	refill_check()
	var card = cards.get_children().pick_random()
	card.advance_area()


func advance_card_based_on_prestige(type_: String) -> void:
	refill_check()
	var options = []
	
	for card in cards.get_children():
		if card.prestige.type == type_:
			options.append(card)
	
	var card = options.pick_random()
	card.advance_area()
	


func advance_all_cards() -> void:
	while cards.get_child_count() > 0:
		advance_random_card()


func refill_check() -> void:
	if cards.get_child_count() == 0:
		var donor = Global.dict.area.prior[type]
		var cardstack = gameboard.get(donor)
		cardstack.advance_all_cards()
#endregion
