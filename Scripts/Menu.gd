extends Node2D

const main_menu_text := "Welcome to snake-godot! Press ENTER to start game."
const death_text := "You're dead! Press ENTER to restart game."
const finish_text := "You're won! Press ENTER to restart game."

var text := ""

func _ready():
	set_text(Globals.screen)

func set_text(screen):
	match screen:
		"main_menu":
			text = main_menu_text
		"death_screen":
			text = death_text
			add_play_info()
		"finish_screen":
			text = finish_text
			add_play_info()

	$Label.text = text

func add_play_info():
	text += "\n Score: " + str(Globals.score)
	text += "\n Game time: " + str("%0.0f" % Globals.game_time) + " seconds"

func _input(event):
	if event.is_action_pressed("start"):
		Globals.score = 0
		Globals.game_time = 0
		get_tree().change_scene("res://MainScene.tscn")
