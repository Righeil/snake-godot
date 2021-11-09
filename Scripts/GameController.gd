extends Node2D

onready var player = $Player
onready var tail_part = load("res://Objects/Tail.tscn")
onready var apple = $Apple
onready var label = $Label
onready var eat_sound = $AudioStreamPlayer2D
onready var move_sound = $AudioStreamPlayer2D2

var player_cell_position = Vector2(0, 0)
var score := 0

var tail = []
var tail_size := 0

const WINDOW_SIZE := Vector2(832, 832)
const CELL_SIZE := 64 #WORLD CELL SIZE AND PLAYER/APPLE SIZE
const MAP_SIZE := Vector2(13, 13)

var direction := Vector2.RIGHT
var new_direction := Vector2.RIGHT

var time := 0.0
const TIME_INTERVAL := 0.25

var random = RandomNumberGenerator.new()

func _ready():
	_set_position(player, Vector2(6, 6), false)
	_randomize_apple_position()
	for i in range(3):
		tail.append(tail_part.instance())
		add_child_below_node($Tail, tail[i])
		tail_size += 1
		var color = 1 - (tail_size * 0.01)
		tail[i].modulate = Color(color, color, color)
		_set_position(tail[i], Vector2(5 - i, 6), false)

func _process(delta):
	_process_movement(delta)
	_process_collision()
	pass

func _process_movement(delta : float) -> void:
	if time >= TIME_INTERVAL:
		_process_tail()
		direction = new_direction
		_set_position(player, direction, true)
		_teleport_player()
		player_cell_position = Vector2((player.position.x - 32) / CELL_SIZE, (player.position.y - 32) / CELL_SIZE)
		for i in tail:
			if player.position == i.position:
				get_tree().change_scene("res://DeadScene.tscn")
		time = 0
		move_sound.play()
	
	time += delta

func _teleport_player():
	if player_cell_position.x == 13:
		_set_position(player, Vector2(0, player_cell_position.y), false)
	elif player_cell_position.x == -1:
		_set_position(player, Vector2(12, player_cell_position.y), false)
	if player_cell_position.y == 13:
		_set_position(player, Vector2(player_cell_position.x, 0), false)
	elif player_cell_position.y == -1:
		_set_position(player, Vector2(player_cell_position.x, 12), false)
	
func _process_tail():
	for i in range(tail_size - 1, 0, -1):
		tail[i].position = tail[i - 1].position
	tail[0].position = player.position
	
func _add_tail():
	tail.append(tail_part.instance())
	add_child_below_node($Tail, tail[tail_size])
	tail[tail_size].position = player.position
	var color = 1 - (tail_size * 0.01)
	tail[tail_size].modulate = Color(color, color, color)
	tail_size += 1

func _process_collision():
	if player.position == apple.position:
		_randomize_apple_position()
		_add_tail()
		eat_sound.play()
		score += 1
		label.text = "Score: " + str(score)

func _set_position(object, position : Vector2, add_position : bool) -> void:
	var additional_position := Vector2(32, 32)
	if add_position == true:
		additional_position = object.position
	
	object.position = Vector2(
		additional_position.x + (position.x * CELL_SIZE),
		additional_position.y + (position.y * CELL_SIZE)
	)

func _randomize_apple_position():
	for cell in range(MAP_SIZE.x * MAP_SIZE.y):
		var is_valid_position := true
		var cell_position := Vector2(
			random.randi_range(0, MAP_SIZE.x - 1),
			random.randi_range(0, MAP_SIZE.y - 1))
		var apple_position = Vector2(
			32 + (cell_position.x * CELL_SIZE),
			32 + (cell_position.y * CELL_SIZE)
		)
		for i in tail:
			if apple_position == i.position:
				is_valid_position = false
		
		if apple_position == player.position:
			is_valid_position = false
			return
		
		if is_valid_position:
			_set_position(apple, cell_position, false)
			return

func _input(event):
	if event.is_pressed():
		if event.is_action_pressed("up") and direction != Vector2.DOWN:
			new_direction = Vector2.UP
		if event.is_action_pressed("down") and direction != Vector2.UP:
			new_direction = Vector2.DOWN
		if event.is_action_pressed("left") and direction != Vector2.RIGHT:
			new_direction = Vector2.LEFT
		if event.is_action_pressed("right") and direction != Vector2.LEFT:
			new_direction = Vector2.RIGHT
