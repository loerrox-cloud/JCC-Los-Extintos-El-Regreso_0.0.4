extends Area2D
#area_entered.connect(_on_area_entered)
var boton_abajo = false
var carta_adjudicada = "" 
var cantidad_carta: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area) -> void:
	#print(boton_abajo)
	if boton_abajo == false:

		if "NombreLabel" in area.get_parent(): 
			#print("claroo")
			carta_adjudicada = area.get_parent().NombreLabel.text
			#print(area.get_parent().NombreLabel.text)
			#print(Global.mazo_array)
			pass
	pass # Replace with function body.


func _on_button_2_button_down() -> void:
	if cantidad_carta < 10:
		#boton_abajo = true
		cantidad_carta += 1
		$"../HBoxContainer/Label".text = str(cantidad_carta)
		Global.mazo_array.append(carta_adjudicada)
	#print(carta_adjudicada)
		#print(Global.mazo_array)
		pass # Replace with function body.


func _on_button_button_down() -> void:
	if cantidad_carta > 0 && Global.mazo_array.find(carta_adjudicada) != null:
		cantidad_carta -= 1
		$"../HBoxContainer/Label".text = str(cantidad_carta)
		Global.mazo_array.erase(carta_adjudicada)
		#print(Global.mazo_array)
		#get_parent().
		
	pass # Replace with function body.
