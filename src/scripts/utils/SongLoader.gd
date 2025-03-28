extends Node

func load_song(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to load song: " + path)
		return {}
	
	var song = {
		"title": "",
		"artist": "",
		"content": []
	}
	
	var current_section = ""
	var content_started = false
	
	while not file.eof_reached():
		var line = file.get_line()
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.trim_prefix("[").trim_suffix("]").to_lower()
			content_started = (current_section == "content")
			continue
			
		if not content_started:
			if line.contains(":"):
				var parts = line.split(":", true, 1)
				var key = parts[0].strip_edges().to_lower()
				var value = parts[1].strip_edges()
				song[key] = value
		else:
			song.content.append(line)
	
	song.content = "\n".join(song.content)
	return song
