extends Node

var db
var db_path = "user://songs.db"

func _ready():
	init_database()
	db.query("SELECT * FROM songs;")

func init_database():
	db = SQLite.new()
	db.path = db_path
	
	# Создаем файл БД если его нет
	if not FileAccess.file_exists(db_path):
		var file = FileAccess.open(db_path, FileAccess.WRITE)
		file.close()
		print("Created new database file")
	
	if not db.open_db():
		push_error("Failed to open database!")
		return
	
	create_tables()
	
	if get_songs_count() == 0:
		print("Database is empty, inserting sample songs...")
		insert_sample_songs()
	else:
		print("Database already contains ", get_songs_count(), " songs")

func create_tables():
	var query = """
	CREATE TABLE IF NOT EXISTS songs (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		title TEXT NOT NULL,
		artist TEXT,
		content TEXT NOT NULL
	);
	"""
	if not db.query(query):
		push_error("Failed to create table!")

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

func search_songs(term):
	term = term.to_lower()
	db.query("SELECT * FROM songs WHERE LOWER(title) LIKE '%%%s%%' OR LOWER(artist) LIKE '%%%s%%' ORDER BY title;" % [term, term])
	return db.query_result

func insert_sample_songs():
	var sample_songs = [
		{
			"title": "Лесник",
			"artist": "Король и Шут",
			"content": "  Вступление: Em  C  Am  D   - 4 раза
			
   Em                  C          D
Замученный дорогой, я выбился из сил
	 Em                C         D
И в доме лесника я ночлега попросил.
	Em                    C           D
С улыбкой добродушной старик меня впустил
   Em                                    Am    
И жестом дружелюбным на ужин пригласил. Хэй!

	   Припев:
	  Em                            C
	 Будь как дома, путник, я ни в чем не откажу,
			 Am                    D
	 Я ни в чем не откажу, я ни в чем не откажу.
	  Em                        C
	 Множество историй, коль желаешь - расскажу,
			 Am                       D
	 Коль желаешь - расскажу, коль желаешь - расскажу.

На улице темнело, сидел я за столом,
Лесник сидел напротив, болтал о том, о сем,
Что нет среди животных у старика врагов,
Что нравится ему подкармливать волков.

	   Припев

И волки среди ночи, завыли под окном,
Старик заулыбался и вдруг покинул дом.
Но вскоре возвратился с ружьем наперевес:
Друзья хотят покушать, пойдем, приятель, в лес.

	   Припев"
		},
		{
			"title": "Воля и разум",
			"artist": "Ария",
			"content": "E
В глубокой шахте
Который год
Таится чудище змей
Стальные нервы
Стальная плоть
Стальная хватка когтей

Он копит силы
Лениво ждет
Направив в небо радар
Одна ошибка
Случайный взлет
И неизбежен удар

C       G      D      E
Все во что ты навеки влюблен
C      G   D
Уничтожит разом
C      G    D     E
Тыщеглавый убийца-дракон
C                    D
Должен быть повержен он

Смертельной данью
Обложен мир
Лишен покоя и сна
Многоголосо
Гудит эфир
Опять на старте война

Все во что ты навеки влюблен
Уничтожит разом
Тыщеглавый убийца-дракон
Должен быть повержен он
D
Сильнее всяких войн
E (основная тема)
Воля и разум
Воля и разум

Пока не поздно
Спасайте мир
Нельзя нам больше терпеть
Когда мы вместе
То берегись
Любому чудищу смерть

Все во что ты навеки влюблен
Уничтожит разом
Тыщеглавый убийца-дракон
Должен быть повержен он
Сильнее всяких войн
Воля и разум
Воля и разум"
		},
		{
			"title": "And I Love Her",
			"artist": "The Beatles",
			"content": "F#m        C#m
I give her all my love
F#m         C#m
That's all I do
F#m        C#m
And if you saw my love
A               H
You'd love her too
   E
I love her

She gives me everything
And tenderly
The kiss my lover brings
She brings to me
And I love her

Припев:
C#m         H
А love like ours
C#m         G#m
Could never die
C#m       G#m
Аs long as I
		  H
Have you near me

Bright are the stars that shine
Dark is the sky
I know this love of mine
Will never die
And I love her

Bright are the stars that shine
Dark is the sky
I know this love of mine
Will never die
And I love her"
		},
	]
	
	db.query("BEGIN TRANSACTION;")
	
	for song in sample_songs:
		var title = song["title"].replace("'", "''")
		var artist = song["artist"].replace("'", "''")
		var content = song["content"].replace("'", "''")
		
		var query = "INSERT INTO songs (title, artist, content) VALUES ('%s', '%s', '%s');" % [
			title, artist, content
		]
		
		if not db.query(query):
			push_error("Failed to insert song: " + song["title"])
	
	if not db.query("COMMIT;"):
		push_error("Failed to commit transaction!")
	
	print("Inserted", sample_songs.size(), "sample songs")
