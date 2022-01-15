extends Label

var running = true

onready var label = get_node(".")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if running:
		get_time()
	
func get_time():
	var elapsed_milliseconds = OS.get_ticks_msec()
	var milliseconds = elapsed_milliseconds % 1000
	var seconds = elapsed_milliseconds / 1000 % 60
	var minutes = elapsed_milliseconds / 60000 % 60
	var elapsed_hours = elapsed_milliseconds / 3600000
	var elapsed_time = "%02d:%02d:%02d:%03d" % [elapsed_hours, minutes, seconds, milliseconds]
	label.text = elapsed_time
