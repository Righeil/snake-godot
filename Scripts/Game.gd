extends Node2D

const WORLD_SIZE := Vector2(13, 13)
const CELL_SIZE := Vector2(64, 64)

onready var head = $Player
onready var tail_part = load("res://Objects/Tail.tscn")
onready var apple = $Apple

var head_cell_position := Vector2(6, 6)
var tail := Array()
var tail_size := 0
var tail_cell_position := Array()
var apple_cell_position := Vector2(0, 0)

var direction = Vector2.RIGHT
var new_direction = Vector2.RIGHT

var score := 0

const TIMER_TICK_INTERVAL := 0.25
var time := 0.0

var random = RandomNumberGenerator.new()

func _ready():
	random.randomize()
	for i in range(3):
		tail.append(tail_part.instance())
		tail_cell_position.append(Vector2(5 - i, 6))
		tail_size += 1
		add_child_below_node($Tail, tail[i])
		_visualize(tail[i], tail_cell_position[i])
	
	_visualize(head, head_cell_position)
	_randomize_apple_position()

func _process(delta):
	if time >= TIMER_TICK_INTERVAL:
			_process_movement()
			_process_collision()
			time = 0

	time += delta

func _process_movement():
	for i in range(tail_size - 1, 0, -1):
		tail_cell_position[i] = tail_cell_position[i - 1]
	tail_cell_position[0] = head_cell_position
	
	for i in range(tail_size):
		_visualize(tail[i], tail_cell_position[i])
	
	direction = new_direction
	head_cell_position += direction
	
	if head_cell_position.x == -1:
		head_cell_position.x = 12
	if head_cell_position.x == 13:
		head_cell_position.x = 0
	if head_cell_position.y == -1:
		head_cell_position.y = 12
	if head_cell_position.y == 13:
		head_cell_position.y = 0
	
	_visualize(head, head_cell_position)
	$CrawlSound.play()

func _process_collision():
	for i in range(0, tail.size()):
		if head_cell_position == tail_cell_position[i]:
			get_tree().change_scene("res://DeadScene.tscn")
	
	if head_cell_position == apple_cell_position:
		_randomize_apple_position()
		_add_tail()
		
		score += 1
		$ScoreLabel.text = "Score: " + str(score)
		$EatSound.play()

func _randomize_apple_position():
	for cell in range(WORLD_SIZE.x * WORLD_SIZE.y):
		var is_vaild_position := true
		apple_cell_position = Vector2(
			random.randi_range(0, WORLD_SIZE.x - 1),
			random.randi_range(0, WORLD_SIZE.y - 1)
		)
		
		if apple_cell_position == head_cell_position:
			is_vaild_position = false
			
		for i in range(tail_size):
			if apple_cell_position == tail_cell_position[i]:
				is_vaild_position = false
		
		if is_vaild_position:
			_visualize(apple, apple_cell_position)
			return
	get_tree().change_scene("res://FinishScene.tscn")

func _add_tail():
	tail.append(tail_part.instance())
	tail_cell_position.append(head_cell_position)
	add_child_below_node($Tail, tail[tail_size])
	_visualize(tail[tail_size], tail_cell_position[tail_size]) # бред
	tail_size += 1

func _visualize(object, _position):
	object.position = Vector2(
		_position.x * CELL_SIZE.x,
		_position.y * CELL_SIZE.y
	)
	
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
