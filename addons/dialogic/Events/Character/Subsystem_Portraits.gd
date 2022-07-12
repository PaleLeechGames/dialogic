extends DialogicSubsystem


####################################################################################################
##					STATE
####################################################################################################

func clear_game_state():
	for character in dialogic.current_state_info.get('portraits', {}).keys():
		remove_portrait(load(character))
	dialogic.current_state_info['portraits'] = {}

func load_game_state():
	for character_path in dialogic.current_state_info['portraits']:
		add_portrait(
			load(character_path), 
			dialogic.current_state_info['portraits'][character_path].portrait, dialogic.current_state_info['portraits'][character_path].position_index
			)


####################################################################################################
##					MAIN METHODS
####################################################################################################

func add_portrait(character:DialogicCharacter, portrait:String,  position_idx:int) -> Node:
	var portrait_node = null
	
	if not character:
		assert(false, "[Dialogic] Cannot add portrait of null character.")
	if not portrait in character.portraits:
		assert(false, "[Dialogic] Character "+ character.display_name+ " has no portrait '"+portrait+"'.")
	if len(get_tree().get_nodes_in_group('dialogic_portrait_holder')) == 0:
		assert(false, '[Dialogic] If you want to display portraits, you need a PortraitHolder scene!')
	
	for node in get_tree().get_nodes_in_group('dialogic_portrait_position'):
		if node.position_index == position_idx:
			var path = character.portraits[portrait].path
			if not path.ends_with('.tscn'):
				var node2d = Node2D.new()
				var sprite = Sprite.new()
				get_tree().get_nodes_in_group('dialogic_portrait_holder')[0].add_child(node2d)
				node2d.add_child(sprite)
				sprite.texture = load(path)
				sprite.centered = false
				sprite.scale = Vector2(1,1)*character.portraits[portrait].scale
				node2d.global_position = node.global_position 
				sprite.position = character.portraits[portrait].offset
				sprite.position.x -= sprite.texture.get_width()/2.0*character.portraits[portrait].scale*character.scale
				sprite.position.y -= sprite.texture.get_height()*character.portraits[portrait].scale*character.scale
				portrait_node = node2d
	
	if portrait_node:
		dialogic.current_state_info['portraits'][character.resource_path] = {'portrait':portrait, 'node':portrait_node, 'position_index':position_idx}
	
	return portrait_node

func change_portrait(character:DialogicCharacter, portrait:String) -> void:
	if not character or not is_character_joined(character):
		assert(false, "[Dialogic] Cannot change portrait of null/not joined character.")
	
	var portrait_node = dialogic.current_state_info.portraits[character.resource_path].node
	
	if 'does_custom_portrait_change' in portrait_node and portrait_node.does_custom_portrait_change():
		portrait_node.change_portrait(character, portrait)
	else:
		dialogic.current_state_info['portraits'][character.resource_path].node.queue_free()
		add_portrait(character, portrait, dialogic.current_state_info['portraits'][character.resource_path].position_index)


func animate_portrait(character:DialogicCharacter, animation_path:String, length:float, repeats = 1):
	if not character or not is_character_joined(character):
		assert(false, "[Dialogic] Cannot animate portrait of null/not joined character.")
	
	var portrait_node = dialogic.current_state_info['portraits'][character.resource_path].node
	
	if dialogic.current_state_info['portraits'][character.resource_path].get('animation_node', null):
		if is_instance_valid(dialogic.current_state_info['portraits'][character.resource_path].animation_node):
			dialogic.current_state_info['portraits'][character.resource_path].animation_node.queue_free()
	var anim_script = load(animation_path)
	var anim_node = Node.new()
	anim_node.set_script(anim_script)
	anim_node = (anim_node as DialogicAnimation)
	anim_node.node = portrait_node
	anim_node.orig_pos = portrait_node.position
	anim_node.end_position = portrait_node.position
	anim_node.time = length
	anim_node.repeats = repeats
	add_child(anim_node)
	anim_node.animate()
	dialogic.current_state_info['portraits'][character.resource_path]['animation_node'] = anim_node
	return anim_node

func move_portrait(character:DialogicCharacter, position_idx:int, tween:bool= false, time:float = 1):
	if not character or not is_character_joined(character):
		assert(false, "[Dialogic] Cannot move portrait of null/not joined character.")
	
	var portrait_node = dialogic.current_state_info.portraits[character.resource_path].node
	
	for node in get_tree().get_nodes_in_group('dialogic_portrait_position'):
		if node.position_index == position_idx:
			if not tween:
				portrait_node.global_position = node.global_position
	
	dialogic.current_state_info.portraits[character.resource_path].position_index = position_idx

func set_portrait_z_index(portrait_node, z_index):
	pass

func remove_portrait(character:DialogicCharacter) -> void:
	print("removing character ",character.name)
	dialogic.current_state_info['portraits'][character.resource_path].node.queue_free()
	dialogic.current_state_info['portraits'].erase(character.resource_path)


####################################################################################################
##					HELPERS
####################################################################################################

func is_character_joined(character:DialogicCharacter) -> bool:
	return character.resource_path in dialogic.current_state_info['portraits']

func get_joined_characters() -> Array:
	var chars = []
	for char_path in dialogic.current_state_info.get('portraits', {}).keys():
		chars.append(load(char_path))
	return chars
