extends Node

var screen := "main_menu"
var score := 0
var game_time := 0.0

func change_screen(_screen):
	screen = _screen
	get_tree().change_scene("res://Menu.tscn")
	
