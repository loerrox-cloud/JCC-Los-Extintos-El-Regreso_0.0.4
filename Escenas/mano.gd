@tool
class_name Hand extends Node2D

@export var card_angle: float = 1000 
@export var hand_radius: int = 100
@export var angle_limit: float = 25
@export var max_card_spread_angle: float = 10

@onready var carta = $Carta
@onready var colission_shape: CollisionShape2D = $DebugShape

var hand: Array = []
var touched: Array = []
var highlight_index: int = -1
var dragged_card = null


func add_card(card: Node2D):
	hand.push_back(card)
	add_child(card)
	card.mouse_entered.connect(_handle_card_touched)
	card.mouse_exited.connect(_handle_card_untouched)
	reposition_cards()
	
func remove_card(card: Node2D): # Antes remove_card(index: int) -> Node2D:
	var index = hand.find(card)
	var removing_card = hand[index]
	hand.remove_at(index)
	#remove_child(removing_card)
	reposition_cards()
	return removing_card

func reposition_cards():
	var card_spread = min(angle_limit / hand.size(), max_card_spread_angle)
	var current_angle = -(card_spread * hand.size() - 1 )/2 - 90
	for card in hand :
		_update_card_transform(card, current_angle)
		current_angle += card_spread
	
func get_card_position (angle_in_deg: float) -> Vector2:
	var x: float = hand_radius * cos(deg_to_rad(angle_in_deg))
	var y: float = hand_radius * sin(deg_to_rad(angle_in_deg))
	return Vector2(int(x), int(y))
	
func _update_card_transform(card: Node2D, angle_in_drag: float):
	card.set_position(get_card_position(angle_in_drag))
	card.set_rotation(deg_to_rad(angle_in_drag + 90))
	
	
func _handle_card_touched(card):
	#if Input.is_action_pressed("mouse_click"):# Anteriormente if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#print("Listo para arrastrar")
		#if touched.size() > 0: #  o touched ?
			#print("Listo para arrastrar")
			#hand[highlight_index].global_position = get_global_mouse_position()
	
	#print(touched)
	if card == null: #consejo de la IA no del video
		return #consejo de la IA no del video
	
	if not touched.has(card): #consejo de la IA no del video
		touched.push_back(card)
		
	#print("sí, tocado : " + str(carta.name))
	var card_index = hand.find(card) 
	#print(card_index)
	#print("tocado : " + str(card.name))
	if highlight_index != -1: # consejo de la IA no del video, el vídeo ponía < card_index:
		highlight_index = card_index
		
		

	
func _handle_card_untouched(card):
	if card == null: #consejo de la IA no del video
		return #consejo de la IA no del video
	
	var card_index = hand.find(card)
	#print(card_index)
	touched.erase(card)
	#print("untouched : " + str(card.NombreLabel.text))
	if highlight_index == card_index: 
		highlight_index = -1
		hand[highlight_index].unhighlight()
	
	
	
#func _unhandled_input(event: InputEvent) -> void:  #para arrastrar cartas
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
	#	if event.pressed and highlight_index >= 0 and highlight_index < hand.size():
	#		print("arrastar")
	#		dragged_card = hand[highlight_index]
		
	#	elif not event.pressed and dragged_card != null: # Al soltar deja de arrastrar
			
	#		dragged_card = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	for card in hand:
		card.unhighlight()
		
		
	if !touched.is_empty():
		var highest_touched_index: int = -1
		
		for touched_card in touched:
			highest_touched_index = max(highest_touched_index, hand.find(touched_card))  
		
		if highest_touched_index >= 0 && highest_touched_index < hand.size(): 
			hand[highest_touched_index].highlight()
		
	if highlight_index >= 0 && highlight_index < hand.size() -1: 
		hand[highlight_index].highlight()
	
	if (colission_shape.shape as CircleShape2D).radius != hand_radius:
		(colission_shape.shape as CircleShape2D).set_radius(hand_radius)  
		
	carta.set_position(get_card_position(card_angle))
	carta.set_rotation(deg_to_rad(card_angle + 90))
	
	#if Input.is_action_just_pressed("ui_up"):
		#if touched.size() > 0:
			
			#pass
			#print(highlight_index)
			#print(touched[highlight_index].NombreLabel.text) #De momento no va y te dice la carta con el mayor índice no de las que estás tocando sino de la mano en general

	pass
		
	
	# ESTO DE ABAJO PARA QUE LA CARTA SE ARRASTRE:
	#if is_instance_valid(dragged_card): 
		#dragged_card.position = get_global_mouse_position()  # antes ponía global_position en vez de .position a secas
		#for card in hand:  Lo dijo la IA pero no sé si funciona
		#	if card == dragged_card:
		#		card.highlight()
		#	else:
		#		card.unhighlight()
		#return
		
		#get_global_mouse_position()
	#for card in hand: # Lógica de resaltado. Lo dijo la IA pero si se activa no funciona
		#card.unhighlight()
	
	#if highlight_index >= 0 and highlight_index < hand.size(): # Lógica de resaltado. Lo dijo la IA pero si se activa no funciona 
		#hand[highlight_index].highlight()
