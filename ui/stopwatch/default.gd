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
	var metrics_path = "user://metrics.json"
	var metrics_file = FileAccess.open(metrics_path, FileAccess.READ_WRITE)
	var metrics = {}
	if (FileAccess.file_exists(metrics_path)):
		var metrics_text = metrics_file.get_as_text()
		if (metrics_text != ""):
			var maybe_metrics = JSON.parse_string(metrics_file.get_as_text())
			if (maybe_metrics != null):
				metrics = maybe_metrics

	if (metrics.get("best_run_time") == null):
		set_run_time_as_best_run_time(metrics, metrics_file)
	else:
		if (metrics.get("best_run_time") > global.robert_time):
			set_run_time_as_best_run_time(metrics, metrics_file)

func set_run_time_as_best_run_time(metrics, metrics_file):
	metrics["best_run_time"] = global.robert_time
	metrics_file.store_string(JSON.stringify(metrics))
