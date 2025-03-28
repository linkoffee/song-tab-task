extends Node

const SongLoader = preload("res://scripts/utils/SongLoader.gd")
const SongFormatter = preload("res://scripts/utils/SongFormatter.gd")

var db
var db_path = "user://songs.db"

func _ready():
	init_database()
	load_songs_from_files()

func init_database():
	db = SQLite.new()
	db.path = db_path
	
	if not FileAccess.file_exists(db_path):
		var file = FileAccess.open(db_path, FileAccess.WRITE)
		file.close()
		print("Created new database file")
	
	if not db.open_db():
		push_error("Failed to open database!")
		return
	
	create_tables()

func create_tables():
	var queries = [
		"""CREATE TABLE IF NOT EXISTS songs (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			title TEXT NOT NULL,
			artist TEXT,
			content TEXT NOT NULL,
			UNIQUE(title, artist) ON CONFLICT REPLACE
		);""",
		"CREATE INDEX IF NOT EXISTS idx_songs_title ON songs(title);",
		"CREATE INDEX IF NOT EXISTS idx_songs_artist ON songs(artist);"
	]
	
	for query in queries:
		if not db.query(query):
			push_error("Failed to execute query: " + query)

func load_songs_from_files():
	if get_songs_count() > 0:
		print("Songs already loaded, skipping...")
		return
	
	var dir = DirAccess.open("res://songs/")
	if not dir:
		push_error("Cannot open songs directory!")
		return
	
	var loader = SongLoader.new()
	var formatter = SongFormatter.new()
	var count = 0
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".txt"):
			var song_path = "res://songs/" + file_name
			var song = loader.load_song(song_path)
			if song:
				var formatted_content = formatter.format_song(song)
				save_song_to_db(song, formatted_content)
				count += 1
		file_name = dir.get_next()
	
	loader.queue_free()
	formatter.queue_free()
	print("Loaded", count, "songs from files")

func save_song_to_db(song: Dictionary, formatted_content: String):
	if not db:
		push_error("Database not initialized!")
		return
	
	var query = """
	INSERT INTO songs (title, artist, content)
	VALUES ('%s', '%s', '%s')
	""" % [
		song.get("title", "").replace("'", "''"),
		song.get("artist", "").replace("'", "''"),
		formatted_content.replace("'", "''")
	]
	
	if not db.query(query):
		push_error("Failed to save song to DB: " + song.get("title", "unknown"))

func get_songs_count():
	if not db.query("SELECT COUNT(*) as count FROM songs;"):
		return 0
	return db.query_result[0]["count"]

func get_all_songs():
	db.query("SELECT * FROM songs ORDER BY title;")
	return db.query_result

func get_song_by_id(id):
	db.query("SELECT * FROM songs WHERE id = %d;" % id)
	return db.query_result[0] if db.query_result else null

func search_songs(term: String) -> Array:
	term = term.strip_edges()
	if term.is_empty():
		return get_all_songs()
	
	var safe_term = term.replace("'", "''").replace("%", "\\%").replace("_", "\\_")
	
	var any_pattern = "%%%s%%" % safe_term
	var start_pattern = "%s%%" % safe_term
	
	var query = """
	SELECT * FROM songs 
	WHERE LOWER(title) LIKE LOWER('%s') 
	   OR LOWER(artist) LIKE LOWER('%s')
	ORDER BY 
		CASE 
			WHEN LOWER(title) LIKE LOWER('%s') THEN 0
			WHEN LOWER(artist) LIKE LOWER('%s') THEN 1
			ELSE 2
		END,
		title
	""" % [any_pattern, any_pattern, start_pattern, start_pattern]
	
	if not db.query(query):
		push_error("Search query failed: " + query)
		return []
	
	return db.query_result
