extends Node

var db
var current_scene = null

func _ready():
	db = preload("res://scripts/data/db.gd").new()
	add_child(db)
	
	var song_list = preload("res://scenes/SongList.tscn").instantiate()
	song_list.db = db
	song_list.name = "SongList"
	add_child(song_list)
	
	var song_view = preload("res://scenes/SongView.tscn").instantiate()
	song_view.db = db
	song_view.name = "SongView"
	add_child(song_view)
	song_view.hide()
	
	show_song_list()
	
func show_song_list():
	if has_node("SongView"):
		get_node("SongView").hide()
	if has_node("SongList"):
		get_node("SongList").show()
		get_node("SongList").load_songs()

func show_song_view(song):
	if has_node("SongList"):
		get_node("SongList").hide()
	if has_node("SongView"):
		get_node("SongView").show()
		get_node("SongView").set_song(song)
