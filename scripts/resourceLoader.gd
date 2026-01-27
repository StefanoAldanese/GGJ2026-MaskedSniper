# scripts/resourceLoader.gd
extends Node
class_name resourceLoader

# Funzione per caricare tutte le risorse di un tipo specifico da una cartella
func load_resources_from_folder(folder_path: String, resource_type: GDScript) -> Array:
	var resources = []
	
	if not DirAccess.dir_exists_absolute(folder_path):
		push_warning("Cartella non trovata: " + folder_path)
		return resources
	
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource_path = folder_path.path_join(file_name)
				var resource = load(resource_path)
				# Controlla se la risorsa è del tipo corretto
				if resource and resource is resource_type:
					resources.append(resource)
				else:
					print("Risorsa ignorata (tipo sbagliato): ", file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	print("Caricate ", resources.size(), " risorse da: ", folder_path)
	return resources
