extends Control

@onready var title_label = $TitleLabel
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
var song_formatter = preload("res://scripts/utils/SongFormatter.gd").new()

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
	title_label.text = "%s - %s" % [song.title, song.artist]
	content_label.text = song.content
	
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
	auto_scroll_speed = value * 2

func _on_font_size_changed(value):
	update_font_size()

func update_font_size():
	if not font_size_slider:
		return
		
	var base_size = font_size_slider.value
	content_label.add_theme_font_size_override("normal_font_size", base_size)
	content_label.add_theme_font_size_override("bold_font_size", base_size * 1.1)

func _on_back_pressed():
	get_node("/root/Main").show_song_list()
