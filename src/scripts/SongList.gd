extends Control

var db
@onready var search_box = $SearchBox
@onready var song_list = $ScrollContainer/SongsContainer/SongList

func _ready():
	load_songs()
	song_list.item_selected.connect(_on_song_list_item_selected)
	search_box.text_changed.connect(_on_search_text_changed)

func load_songs(filter: String = ""):
	song_list.clear()
	var songs = db.search_songs(filter)
	
	if songs.is_empty() and not filter.is_empty():
		song_list.add_item("Ничего не найдено")
		return
	
	for song in songs:
		var display_text = "%s - %s" % [song["title"], song["artist"]]
		song_list.add_item(display_text)
		song_list.set_item_metadata(song_list.get_item_count() - 1, song["id"])

func _on_search_text_changed(new_text):
	await get_tree().create_timer(0.3).timeout
	load_songs(new_text)

func _on_song_list_item_selected(index):
	var song_id = song_list.get_item_metadata(index)
	var song = db.get_song_by_id(song_id)
	get_node("/root/Main").show_song_view(song)
