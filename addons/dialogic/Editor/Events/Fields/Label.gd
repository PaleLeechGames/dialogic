tool
extends Control


export(String) var text = "Hello World"


# Called when the node enters the scene tree for the first time.
func _ready():
	print('Text Label Ready!')
	$Label.text = DTS.translate(text)
