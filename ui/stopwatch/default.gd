extends Label

@onready var label = get_node(".")

func _process(delta):
	if !global.robert_finished:
		global.robert_time += delta
	
	var milsecs = fmod(global.robert_time, 1) * 1000
	var secs = fmod(global.robert_time, 60)
	var mins = fmod(global.robert_time, 60 * 60) / 60
	var hours = fmod(fmod(global.robert_time, 3600 * 24) / 3600, 24)

	label.text = "%02d:%02d:%02d.%03d" % [hours, mins, secs, milsecs]

func handle_run_time():
	var persistent_data_path = "user://metrics.cfg"
	var persistent_data = ConfigFile.new()
	persistent_data.load(persistent_data_path)

	if (persistent_data.get_value("metrics", "best_run_time") != null):
		if (float(persistent_data.get_value("metrics", "best_run_time")) < global.robert_time):
			return
	
	persistent_data.set_value("metrics", "best_run_time", global.robert_time)
	if (persistent_data.save(persistent_data_path) != OK):
		print("Failed to save this run's time.")
