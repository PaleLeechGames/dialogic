@tool
extends DialogicEvent


# DEFINE ALL PROPERTIES OF THE EVENT
# var MySetting :String = ""

func _execute() -> void:
	# I have no idea how this event works
	finish()


################################################################################
## 						INITIALIZE
################################################################################

# SET ALL VALUES THAT SHOULD NEVER CHANGE HERE
func _init() -> void:
	event_name = "Default"
	event_color = Color("#ffffff")
	event_category = Category.MAIN
	event_sorting_index = 0
	


################################################################################
## 						SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "default_shortcode"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 	: property_name
		#"arg_name"		: "NameOfProperty",
	}

# You can alternatively overwrite these 3 functions:
# - get_as_string_to_store(), 
# - load_from_string_to_store(),
# - is_valid_event_string()

################################################################################
## 						EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	pass
