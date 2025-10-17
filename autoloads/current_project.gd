# Autoload Singleton: Holds the state of the currently loaded project.
# This acts as the single source of truth for the application's data.
# Any part of the app can access it to get project data.
# When the project is modified, it emits the `project_changed` signal
# so that the UI and AudioEngine can update themselves.
extends Node

signal project_changed(project: Project)

var project: Project

func set_project(new_project: Project):
	project = new_project
	project_changed.emit(project)

func add_track(track_type: TrackData.TrackType, instrument_scene_path: String = ""):
	var new_track = TrackData.new()
	new_track.track_type = track_type
	
	if track_type == TrackData.TrackType.INSTRUMENT and not instrument_scene_path.is_empty():
		new_track.instrument_scene = load(instrument_scene_path)
		new_track.track_name = instrument_scene_path.get_file().get_basename()
	else:
		new_track.track_name = "Audio Track %d" % (project.tracks.size() + 1)
	
	project.tracks.append(new_track)
	project_changed.emit(project)

func move_event(event: TrackEvent, new_time_sec: float, new_track_index: int):
	# Find and remove the event from its old track
	for track in project.tracks:
		if track.events.has(event):
			track.events.erase(event)
			break
	
	# Add it to the new track at the new time
	event.get_time_component().start_time_sec = new_time_sec
	project.tracks[new_track_index].events.append(event)
	project_changed.emit(project)

func add_event_to_track(event: TrackEvent, track_index: int):
	if track_index >= 0 and track_index < project.tracks.size():
		project.tracks[track_index].events.append(event)
		project_changed.emit(project)
