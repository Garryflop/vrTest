extends Node3D

@onready var panel_label: Label3D = $PanelLabel

func _ready() -> void:
	panel_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	panel_label.font_size = 32
	panel_label.outline_size = 8
	panel_label.modulate = Color(1, 1, 1)
	panel_label.text = _build_text()

func _build_text() -> String:
	return """╔══════════════════════════════════╗
║       CRYPTOGRAPHIC KEYS         ║
╠══════════════════════════════════╣
║  PUBLIC KEY    │  PRIVATE KEY    ║
║  🔵 Transparent│  🟡 Solid Gold  ║
║  Share freely  │  Never share    ║
║  = Home address│  = Door key     ║
║  For receiving │  For signing    ║
╠══════════════════════════════════╣
║  TRY IT:                         ║
║  1. Public Key  → DENIED ❌      ║
║  2. Wrong Key   → DENIED ❌      ║
║  3. Your Key    → OPEN!  ✓       ║
╚══════════════════════════════════╝"""
