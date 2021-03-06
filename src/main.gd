tool
extends Node2D

const WHITE = Color(1, 1, 1)
const FORMAT_BINARY = 0
const FORMAT_TEXT = 1
const FORMAT_XML = 2

onready var start = get_node("StartPos")
onready var startpos = start.get_pos()
onready var rect = Rect2(startpos, Vector2(size_x, size_y))
onready var TilesetDiag = get_node("TilesetDialog")
onready var PathDiag = get_node("FileDialog")
var tilescene = preload("res://tile.tscn")
var tileset
var tilesize_x = 32
var tilesize_y = 32
var rows = 2
var columns = 2
var spacing = 0
var margin = 0
var size_x = columns * tilesize_x
var size_y = rows * tilesize_y
var have_tileset = false
var currentSelection
var tiles = {}
var dir
var base_name = ""
var format_str = ".atex"
var line_width = 1.0
func _ready():
	TilesetDiag.set_mode(TilesetDiag.MODE_OPEN_FILE)
	pass

func requestSelection(tile):
	if currentSelection != null:
		currentSelection.deselect()
	currentSelection = tile
	get_node("CurrentTilePanel").show()
	get_node("CurrentTilePanel/TileName").set_text(tile.name)
	get_node("CurrentTilePanel/TileImport").set_pressed(!tile.skip)

func deselect():
	currentSelection = null
	get_node("CurrentTilePanel").hide()

func import():
	print("pressed ok")
	if (dir == null or dir == ""):
		get_node("../pathNotice").show()
		get_node("..").show()
		return
	for tile in start.get_children():
		if tile.skip:
			continue
		var tex = AtlasTexture.new()
		tex.set_name(tile.name)
		tex.set_atlas(tileset)
		tex.set_region(tile.rect)
		ResourceSaver.save(dir + "/" + tile.name + format_str, tex)
		

func deleteTiles():
	for tile in start.get_children():
		tile.queue_free()

func makeTiles():
	var count = 0
	deleteTiles()
	for x in range(columns):
		for y in range(rows):
			var rect = Rect2(Vector2(x * tilesize_x + x * spacing + margin, y * tilesize_y + y * spacing + margin), Vector2(tilesize_x, tilesize_y))
			var tile = tilescene.instance()
			var shape = RectangleShape2D.new()
			shape.set_extents(Vector2(tilesize_x/2, tilesize_y/2))
			tile.set_texture(tileset)
			tile.get_node("Area2D").add_shape(shape)
			tile.get_node("Area2D").set_pos(Vector2(tilesize_x/2, tilesize_y/2))
			tile.rect = rect
			start.add_child(tile)
			tile.set_pos(Vector2(x * tilesize_x + x, y * tilesize_y + y))
			tile.name = base_name + "_" + str(count)
			tile.skip = false
			count += 1

func _on_path_button_pressed():
	get_node("FileDialog").show()

func _on_FileDialog_confirmed():
	dir = get_node("FileDialog").get_current_dir()


func update_vars():
	size_x = columns * tilesize_x
	size_y = rows * tilesize_y
	rect = Rect2(startpos, Vector2(size_x, size_y))
	makeTiles()

func _on_tilesize_x_value_changed( value ):
	tilesize_x = int(value)
	update_vars()

func _on_rows_value_changed( value ):
	rows = int(value)
	update_vars()

func _on_columns_value_changed( value ):
	columns = int(value)
	update_vars()

func _on_tilesize_y_value_changed( value ):
	tilesize_y = int(value)
	update_vars()

func _on_spacing_value_changed( value ):
	spacing = int(value)
	update_vars()

func _on_margin_value_changed( value ):
	margin = int(value)
	update_vars()

func _on_load_pressed():
	get_node("TilesetDialog").show()

func _on_import_toggled( pressed ):
	if (currentSelection != null):
		currentSelection.skip = !pressed

func _on_TileName_text_changed():
	if currentSelection != null:
		currentSelection.name = get_node("CurrentTilePanel/TileName").get_text()
		
func _on_format_changed(format):
	if format == FORMAT_BINARY:
		format_str = ".atex"
	elif format == FORMAT_TEXT:
		format_str = ".tres"
	elif format == FORMAT_XML:
		format_str = ".xatex"
	get_node("format").set_text(get_node("format").get_popup().get_item_text(format))

func _on_FileDialog_dir_selected( Dir ):
	dir = Dir
	get_node("Label").set_text("Path: " + dir)

func _on_TilesetDialog_file_selected( path ):
	tileset = load(path)
	var entries = path.split("/")
	base_name = entries[entries.size() - 1].split(".")[0]
	makeTiles()
	have_tileset = true
