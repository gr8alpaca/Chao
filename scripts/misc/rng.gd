@tool
class_name RNG extends Object

static var instance: RandomNumberGenerator = RandomNumberGenerator.new()

static func randomize() -> void:
	instance.randomize()

static func rand_weighted(weights: PackedFloat32Array) -> int:
	return instance.rand_weighted(weights)

static func randi() -> int:
	return instance.randi()
	
static func randi_range(from: int, to: int) -> int:
	return instance.randi_range(from, to)
	
static func randf_range(from: float, to: float) -> float:
	return instance.randf_range(from, to)
	
static func randf() -> float:
	return instance.randf()
	
static func randfn(mean: float = 0.0, deviation: float = 1.0) -> float:
	return instance.randfn(mean, deviation)

static func load(path: String = "res://rng.dat") -> void:
	if not FileAccess.file_exists(path): return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	instance.seed = file.get_64()
	instance.state = file.get_64()
	file.close()

static func save(path: String = "res://rng.dat") -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_64(instance.seed)
	file.store_64(instance.state)
	file.close()
