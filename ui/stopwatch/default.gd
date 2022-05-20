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
