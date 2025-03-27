extends Control

@onready var content_label = $ViewContainer/Content
@onready var auto_scroll_toggle = $SettingsContainer/AutoScrollToggle
@onready var speed_slider = $SettingsContainer/SpeedSlider
@onready var font_size_slider = $SettingsContainer/FontSizeSlider
@onready var scroll_container = $ViewContainer
@onready var back_button = $BackToListBtn

var db
var auto_scroll_speed = 50
var auto_scroll_active = false
var current_song = null

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	auto_scroll_toggle.connect("toggled", Callable(self, "_on_auto_scroll_toggled"))
	speed_slider.connect("value_changed", Callable(self, "_on_speed_changed"))
	font_size_slider.connect("value_changed", Callable(self, "_on_font_size_changed"))

func set_song(song):
	if not song:
		push_error("Attempt to set null song!")
		return
		
	current_song = song
	
	if not is_instance_valid(content_label):
		push_error("Content label is not valid!")
		return
	
	if not song.has("content"):
		push_error("Song data is missing 'content' field!")
		return
 
	content_label.text = song["content"]
	if font_size_slider:
		update_font_size()
	else:
		call_deferred("update_font_size")

func _process(delta):
	if auto_scroll_active:
		scroll_container.scroll_vertical += auto_scroll_speed * delta
		if scroll_container.scroll_vertical >= scroll_container.get_v_scroll_bar().max_value:
			auto_scroll_active = false
			auto_scroll_toggle.set_pressed(false)

func _on_auto_scroll_toggled(button_pressed):
	auto_scroll_active = button_pressed
	if button_pressed:
		scroll_container.scroll_vertical = 0

func _on_speed_changed(value):
	auto_scroll_speed = value

func _on_font_size_changed(value):
	update_font_size()

func update_font_size():
	if not is_instance_valid(content_label) or not current_song or not font_size_slider:
		push_error("Cannot update font size - missing required components")
		return
	
	if not current_song.has("content"):
		push_error("Current song is missing content!")
		return
	
	var font = content_label.get_theme_font("normal_font")
	var font_size = font_size_slider.value
	
	var bbcode = current_song["content"]
	bbcode = bbcode.replace("[", "[font_size=%d][" % (font_size * 1.2))
	bbcode = bbcode.replace("]", "][/font_size]")
	
	content_label.text = ""
	content_label.append_text(bbcode)

func _on_back_pressed():
	get_node("/root/Main").show_song_list()
