
@tool
extends EditorScript

const PHYSICS_LAYER := 0
const ALPHA_THRESHOLD := 0.1
const POLYGON_EPSILON := 0.0
const OUTPUT_PATH := "res://generated_alpha_tileset.tres"


func _run() -> void:
	# Find the selected TileMapLayer.
	var selected = EditorInterface.get_selection().get_selected_nodes()
	var layer: TileMapLayer = null

	for node in selected:
		if node is TileMapLayer:
			layer = node
			break

	if layer == null:
		push_error("Select a TileMapLayer first.")
		return

	if layer.tile_set == null:
		push_error("The selected TileMapLayer has no TileSet.")
		return

	if layer.tile_set.get_physics_layers_count() <= PHYSICS_LAYER:
		push_error("Physics layer 0 does not exist.")
		return

	# Work on a copy so the original TileSet stays untouched.
	var tileset := layer.tile_set.duplicate(true) as TileSet

	var total := 0

	for source_index in tileset.get_source_count():
		var source_id = tileset.get_source_id(source_index)
		var source = tileset.get_source(source_id)

		if not source is TileSetAtlasSource:
			continue

		var atlas := source as TileSetAtlasSource

		if atlas.texture == null:
			continue

		var image := atlas.texture.get_image()

		if image == null:
			push_error("Could not read atlas texture.")
			return

		if image.is_compressed():
			image.decompress()

		var tile_size := atlas.texture_region_size
		var half_size := Vector2(tile_size) / 2.0

		for tile_index in atlas.get_tiles_count():
			var coords := atlas.get_tile_id(tile_index)

			# Find this tile's pixels in the PNG.
			var region_position := Vector2i(
				atlas.margins.x + coords.x * (tile_size.x + atlas.separation.x),
				atlas.margins.y + coords.y * (tile_size.y + atlas.separation.y)
			)

			var tile_image := image.get_region(
				Rect2i(region_position, tile_size)
			)

			# Turn alpha into a bitmap.
			var bitmap := BitMap.new()
			bitmap.create_from_image_alpha(
				tile_image,
				ALPHA_THRESHOLD
			)

			# Trace the opaque pixels.
			var polygons := bitmap.opaque_to_polygons(
				Rect2(Vector2.ZERO, Vector2(tile_size)),
				POLYGON_EPSILON
			)

			# Apply collision to every alternative of this tile.
			for alt_index in atlas.get_alternative_tiles_count(coords):
				var alt_id := atlas.get_alternative_tile_id(
					coords, alt_index
				)

				var data := atlas.get_tile_data(coords, alt_id)

				data.set_collision_polygons_count(
					PHYSICS_LAYER,
					polygons.size()
				)

				for polygon_index in polygons.size():
					var centered := PackedVector2Array()

					for point in polygons[polygon_index]:
						centered.append(point - half_size)

					data.set_collision_polygon_points(
						PHYSICS_LAYER,
						polygon_index,
						centered
					)

			total += 1

	# Save the generated TileSet separately.
	var error := ResourceSaver.save(tileset, OUTPUT_PATH)

	if error != OK:
		push_error("Could not save TileSet: " + error_string(error))
		return

	# Use the generated TileSet on this TileMapLayer.
	layer.tile_set = tileset

	print("Generated collision for ", total, " atlas tiles!")
	print("Saved to: ", OUTPUT_PATH)
