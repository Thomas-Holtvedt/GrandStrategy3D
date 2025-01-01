extends StaticBody3D

@onready var Provinces = get_node("Provinces")
@onready var States = get_node("States")

# Called when the node enters the scene tree for the first time.
func _ready() ->  void:
	generate_provinces()
	generate_states()

func generate_provinces():
	print("\n--- STARTING PROVINCE GENERATOR ---\n")
	#Import the.txt file containing province info
	var provincefile:String = FileAccess.open("res://map/map_data/Provinces.txt", FileAccess.READ).get_as_text()
	var rows:Array = provincefile.split("\n")
	var province_colors:Array = []
	for row in rows:
		if row.strip_edges() != "":
			var columns:Array = row.split(";")
			#
			var province_id:String = columns[0]
			var province_color:Color = Color(float(columns[1]) / 255.0, float(columns[2]) / 255.0, float(columns[3]) / 255.0)
			var province_type:String = columns[4]
			var province_unknown = columns[5]
			var province_subtype:String = columns[6]
			var owner_tag:String = columns[7]
			var controller_tag:String = columns[8]
			var province_name:String = columns[9]
			province_colors.append(province_color)
			#Creating a province node
			var province:Province = Province.new()
			province.name = province_id
			province.province_id = province_id
			province.province_color = province_color
			province.province_type = province_type
			province.province_unknown = province_unknown
			province.province_subtype = province_subtype
			province.owner_tag = owner_tag
			province.controller_tag = controller_tag
			province.province_name = province_name
			Provinces.add_child(province)
			province.add_to_group("provinces")
			
			#Creating a record in a global dictionary
			GlobalResources.color_to_province_id[province_color.to_html()] = province
	create_image(province_colors)
	print("Finished generating provinces!")
	
func generate_states():	
	print("\n--- STARTING STATE GENERATOR ---\n")
	var states_folder = DirAccess.open("res://map/map_data/States/")
	states_folder.list_dir_begin()
	var file_name = states_folder.get_next()
	while file_name != "":
		var file = FileAccess.open("res://map/map_data/States/" + file_name, FileAccess.READ)
		var content = file.get_as_text()
		var state_id = parse_id(content)
		var state_name = parse_name(content)
		var provinces = parse_provinces(content)
		
		var state:State = State.new()
		state.name = state_id
		state.state_id = state_id
		state.state_name = state_name
		States.add_child(state)
		States.add_to_group("States")
		
		for province in provinces:
			var node_to_move = Provinces.get_node(province)
			node_to_move.reparent(state)
		
		file_name = states_folder.get_next()
		file.close()
	states_folder.list_dir_end()
	print("Finished generating states!")

func parse_id(content):
	var id_pattern = "id="
	var start_index = content.find(id_pattern) + id_pattern.length()
	var end_index = content.find("name", start_index) - 1
	return content.substr(start_index, end_index - start_index).strip_edges()

func parse_name(content):
	var name_pattern = 'name="'
	var start_index = content.find(name_pattern) + name_pattern.length()
	var end_index = content.find('"', start_index)
	return content.substr(start_index, end_index - start_index)

func parse_provinces(content):
	var provinces_pattern = 'provinces={'
	var start_index = content.find(provinces_pattern) + provinces_pattern.length()
	var end_index = content.find('}', start_index)
	var provinces_str = content.substr(start_index, end_index - start_index).strip_edges()
	return provinces_str.split(" ")
	
func create_image(province_colors): 
	var height = province_colors.size() 
	var image = Image.create_empty(2, height, false, Image.FORMAT_RGB8) 
	for y in range(height): 
		image.set_pixel(0, y, province_colors[y]) 
		image.set_pixel(1, y, Color(0, 0, 255)) # Blue color 
	image.save_png("res://map/map_data/province_owner.png") 
