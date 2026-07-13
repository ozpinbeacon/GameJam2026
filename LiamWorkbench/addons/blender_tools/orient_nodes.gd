@tool
extends EditorScenePostImport

func _post_import(scene):
	var scene_name = scene.name + " Rig"
	recursive_settings(scene)
	return scene

func recursive_settings(node):
	if node is Skeleton3D:
		node.rotate_y(deg_to_rad(-180.0))
	
	for child in node.get_children():
		recursive_settings(child)
