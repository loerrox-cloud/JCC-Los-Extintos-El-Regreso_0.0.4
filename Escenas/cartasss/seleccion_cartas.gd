extends Node2D

@onready var Carta: PackedScene = preload("res://Escenas/cartasss/CartaEscena.tscn")
@onready var Botones: PackedScene = preload("res://Escenas/botones_seleccion_carta.tscn")
@export var escena_item: PackedScene
@export var cantidad: int = 8
@export var items: Array[Node2D] = []
@export var columnas: int = 13
@export var separacion: Vector2 = Vector2(140.0, 180.0) 

	#COPIADAS DE "DECK":
var text_file_path = "res://cartas.txt" 
var text_content = get_text_file_content(text_file_path) 
var text_content_parts: PackedStringArray = text_content.split("\n")
var text_content_parts_criaturas: PackedStringArray = text_content.split("Criatura")
var Listado: Array = []
var NombreCarta = "Aegirocassis"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#generar_ejemplo()
	bucle_contador_Criaturas()
	
	generar_criaturas()
	
	organizar_cuadricula()
	
	
	
	#print("está funcionando")
	pass # Replace with function body.

func generar_ejemplo() -> void:
	if not escena_item:
		print("FALTA ASIGNAR ESCENA EN EL INSPECTOR (escena_item)")
		#index_array_fallback()
		return
		
	for i in range(cantidad):
		var nuevo_nodo = escena_item.instantiate() as Node2D
		if nuevo_nodo:
			add_child(nuevo_nodo)
			items.append(nuevo_nodo)
			#print("1")
	
func organizar_cuadricula() -> void:
	for i in range(items.size()):
		if not items[i]:
			print("no hay nada")
			continue
		var fila = i / columnas
		var columna = i % columnas
		
		#print("Item", i , " Fila: ", fila, "Columna: ", columnas)
	
		var posX = columna * separacion.x
		var posY = fila * separacion.y
		#print("Item transformado", i , " Fila: ", fila, "Columna: ", columna)
	#var PosZ = fila separacion.z
	
		items[i].position = Vector2(posX, posY)
		#print("reposicionando")

func get_text_file_content(filePath):  # Función para leer archivo .txt
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	return content

func bucle_contador_Criaturas() -> void:
	var ConteoCriaturas = 1
	while ConteoCriaturas < text_content_parts_criaturas.size():
		ConteoCriaturas += 1
		Listado.append(text_content_parts[text_content_parts.find("Criatura " + str(ConteoCriaturas) + ":")+1])
	#print(text_content_parts_criaturas.size()-1)
	#print(Listado)

func generar_criaturas():
	#print(Listado)
	var numero_indice = 0
	while numero_indice < Listado.size():
		numero_indice += 1
		var NombreCarta = Listado[numero_indice-1]
		var Carta = Carta.instantiate()
		add_child(Carta)
		var IndiceCriatura = text_content_parts.find(NombreCarta)
		Carta.set_values(text_content_parts[IndiceCriatura+0], int(text_content_parts[IndiceCriatura+1]), int(text_content_parts[IndiceCriatura+2]), int(text_content_parts[IndiceCriatura+3]), int(text_content_parts[IndiceCriatura+4]), int(text_content_parts[IndiceCriatura+5]), text_content_parts[IndiceCriatura+6], text_content_parts[IndiceCriatura+7], text_content_parts[IndiceCriatura+8], str(text_content_parts[IndiceCriatura+9]) + "\n" + str(text_content_parts[IndiceCriatura+10]) + "\n" + str(text_content_parts[IndiceCriatura+11]) )
		items.append(Carta)
		Carta.add_child(Botones.instantiate())
		
		#print(items.size())
		#print(items)

func actualizar_numeros():

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Mazo.text = str("Tu mazo es: " + str(Global.mazo_array))
	$Numero_mazo.text = str(str(Global.mazo_array.size()) + "/10")
	if Global.mazo_array.size() == 10:
		$Button.set_modulate(Color(1, 1, 1, 1))
	if Global.mazo_array.size() != 10:
		$Button.set_modulate(Color(0.477, 0.473, 0.485, 0.514))
		
	pass


func _on_button_button_down() -> void:
	if Global.mazo_array.size() == 10:
		get_tree().change_scene_to_file("res://Escenas/deck.tscn")
	pass # Replace with function body.
