extends Label

onready var label = get_node(".")

func _process(delta):
	if !global.robert_finished:
		global.robert_time += delta
	
	var milsecs = fmod(global.robert_time, 1) * 1000
	var secs = fmod(global.robert_time, 60)
	var mins = fmod(global.robert_time, 60 * 60) / 60
	var hours = fmod(fmod(global.robert_time, 3600 * 24) / 3600, 24)

	label.text = "%02d:%02d:%02d.%03d" % [hours, mins, secs, milsecs]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if !global.robert_finished:
#		get_time()
#	
#func get_time():
#	var elapsed_milliseconds = OS.get_ticks_msec()
#	var milliseconds = elapsed_milliseconds % 1000
#	var seconds = elapsed_milliseconds / 1000 % 60
#	var minutes = elapsed_milliseconds / 60000 % 60
#	var elapsed_hours = elapsed_milliseconds / 3600000
#	var elapsed_time = "%02d:%02d:%02d:%03d" % [elapsed_hours, minutes, seconds, milliseconds]
#	label.text = elapsed_time
