extends SceneTree
var game: Node2D
func _initialize():
 call_deferred("run")
func hover(point: Vector2):
 var motion := InputEventMouseMotion.new()
 motion.position = game.get_global_transform_with_canvas() * point
 game._unhandled_input(motion)
func run():
 game = load("res://main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 for action in ["islands", "sound", "retry"]:
  hover(game.ui_buttons()[action].get_center())
  assert(game.hovered_ui == action and game.sound.menu.stream == game.sound.menu_hover)
 game.open_islands()
 game.best.clear()
 hover(game.island_card(1).get_center())
 assert(game.hovered_ui.is_empty(), "Locked island must have no hover")
 hover(game.island_card(0).get_center())
 assert(game.hovered_ui == "island_0" and not game.sound.menu.stream_paused)
 assert(game.ui_at(Vector2(750,119)).is_empty(), "Modal blocks toolbar")
 game.activate_ui("island_0")
 assert(not game.selecting_island and game.sound.menu.stream == game.sound.menu_press)
 game.toggle_pause(false)
 for action in ["continue", "retry"]:
  hover(game.ui_buttons()[action].get_center())
  assert(game.hovered_ui == action)
 game.activate_ui("continue")
 assert(not game.paused)
 game.won = true
 game.collected = 3
 assert(not game.ui_buttons().has("retry"))
 hover(game.ui_buttons()["next"].get_center())
 assert(game.hovered_ui == "next")
 game.activate_ui("next")
 assert(game.level == 1 and not game.won)
 game.level = 19
 game.won = true
 hover(game.ui_buttons()["islands"].get_center())
 assert(game.hovered_ui == "islands")
 game.activate_ui("islands")
 assert(game.selecting_island)
 print("PASS toolbar, cards, locked items, modal blocking, pause and victory UI feedback")
 await game.sound.shutdown()
 quit()
