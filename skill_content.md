# Godot Engine 4.7 Documentation Skill

Use this skill whenever the user asks about Godot Engine 4.x — engine features, scripting, editor usage, 2D/3D development, rendering, physics, animation, UI, networking, import/export, migration, or best practices. The skill provides authoritative reference knowledge extracted from the official Godot Engine 4.7 documentation (English).

---

## Core Engine Concepts (Getting Started)

### Nodes and Scenes
- **Nodes** are the fundamental building blocks of a game: they have a name, editable properties, receive frame callbacks, and can be extended with new properties/functions. They form a tree via parent-child relationships.
- **Scenes** are organized trees of nodes. A saved scene acts like a new node type in the editor — you can instantiate it as a child of any node. Scenes allow modular, reusable game components (characters, weapons, menus, levels).
- **Scene tree** is the global tree of all active scenes/nodes in the running game.
- **Signals** implement the observer pattern: nodes emit signals when events occur, allowing decoupled communication. Connect signals via the editor or in code.

### Scripting Languages
- **GDScript**: Godot's integrated language. Python-inspired syntax, tight editor integration, gradual typing, no garbage collection. Best for beginners and rapid prototyping.
- **C# (.NET 8+)**: Full C# 12.0 support. Good performance/ease-of-use tradeoff. Requires .NET editor build. Supported on desktop; experimental on Android/iOS; not supported on Web in Godot 4.
- **GDExtension (C/C++/Rust)**: Write high-performance code without recompiling the engine.
- Multiple languages can be mixed in one project. Scripts are `.gd` (GDScript) or `.cs` (C#) files attached to nodes to extend their behavior.

### Key Virtual Functions
- `_ready()` — called when node enters the scene tree
- `_process(delta)` — called every frame (delta = time since last frame)
- `_physics_process(delta)` — called at a fixed rate (default 60 FPS), use for physics
- `_input(event)` — receives raw input events
- `_init()` — constructor, called when object is created in memory
- Use `super()` in child class lifecycle functions to call parent implementations (GDScript 4.x)

### Editor Features
- **Workspaces**: 2D, 3D, Script, AssetLib. Switchable via top tabs.
- **Scene dock**: Node tree view, drag to reparent.
- **Inspector dock**: Property editing for selected node.
- **FileSystem dock**: Project file browser.
- **Script editor**: Built-in with syntax highlighting, debugger, code completion.
- **Project Manager**: Create, import, and manage projects.
- **Game embedding**: Run project in-editor with camera override, time scale, pause/frame-advance.
- **Remote inspector**: Inspect running project nodes in real-time.
- **F12 / Cmd+F12**: Toggle UI visibility in scene playback (this project's custom binding).
- Run with F5 (main scene), F6 (current scene), F8 (stop).

### Project Structure
- `project.godot` — project configuration file
- `res://` — root resource path (project directory)
- Scenes saved as `.tscn` (text-based) or `.scn` (binary)
- Scripts saved as `.gd` or `.cs`
- Resources saved as `.tres` (text) or `.res` (binary)
- `addons/` — editor plugin directory
- `Generated Troops` are saved to `res://sence/Fight/生成的兵种/` in this project

---

## Rendering & Graphics

### Renderers (3 renderers in Godot 4)
1. **Forward+** (default desktop): Vulkan/D3D12/Metal, clustered forward rendering, best quality.
2. **Mobile** (default mobile): Vulkan/D3D12/Metal, fewer features, faster on mobile.
3. **Compatibility** (GL/OpenGL): Web/low-end devices, least advanced.

### 2D Graphics
- Nodes: `Node2D` (base), `Sprite2D`, `AnimatedSprite2D`, `Polygon2D`, `Line2D`, `Parallax2D`
- 2D lighting with normal/specular maps, SDF-based GI
- Font rendering: bitmap, rasterized (FreeType), MSDF (multi-channel signed distance fields)
- TTF/OTF/WOFF fonts with variable fonts, OpenType ligatures, outlines
- GPU and CPU particle systems
- TileSet + TileMap for tile-based level design
- `CanvasLayer` for overlay/UI layers with independent depth
- Custom 2D drawing via `_draw()` + `draw_rect()`, `draw_circle()`, etc.

### 3D Graphics
- **PBR**: Disney model, roughness-metallic workflow, normal/parallax mapping, subsurface scattering, screen-space refraction
- **Lights**: Directional, Omni, Spot, Area (rectangular). Clustered forward rendering in Forward+. Per-light shadow blur (PCSS-like), adjustable light size.
- **Shadows**: PSSM for directional (2/4-split), dual paraboloid/cubemap for omni, single texture for spot. Shadow normal offset bias + pancaking.
- **Global Illumination**: LightmapGI (baked, GPU compute), VoxelGI (dynamic lights/occluders), SDFGI (open worlds, no baking), SSIL (screen-space)
- **Reflections**: Voxel/SDF reflections, ReflectionProbe (baked or real-time), SSR
- **Fog**: Exponential depth/height fog, volumetric fog (reacts to lights/shadows, FogVolume nodes)
- **Sky**: Panorama HDRI, procedural sky, custom sky shaders
- **Post-processing**: Tonemapping (Linear/Reinhard/Filmic/ACES/AgX), auto-exposure, DOF (bokeh), SSAO, glow/bloom, color correction (3D LUT), TAA, FSR2
- **Decals**: Albedo/emissive/ORM/normal overlays, clustered rendering, distance fade
- **Particles (3D)**: GPU-based with subemitters, trails, attractors, collision. CPU-based particles.
- **Antialiasing**: TAA, FSR2, MSAA (2D+3D), FXAA, SSAA
- **Texture compression**: BPTC, ASTC, ETC2, S3TC, Basis Universal
- **Nodes**: `Node3D` (base), `MeshInstance3D`, `Camera3D`, `DirectionalLight3D`, `OmniLight3D`, `SpotLight3D`, `WorldEnvironment`
- Coordinate system: metric (1 unit = 1 meter), Y-up, right-handed. X=sides, Y=up/down, Z=front/back.

---

## Physics

### 2D Physics
- Bodies: StaticBody2D, AnimatableBody2D, RigidBody2D, CharacterBody2D
- Joints, Areas (detection zones)
- Built-in collision shapes: Line, Box, Circle, Capsule, WorldBoundary
- Collision polygons (drawn manually or generated from sprite)
- Physics interpolation

### 3D Physics
- Bodies: StaticBody3D, AnimatableBody3D, RigidBody3D, CharacterBody3D, VehicleBody, SoftBody
- Collision shapes: Cuboid, Sphere, Capsule, Cylinder, WorldBoundary
- Generate triangle or convex collision shapes from mesh
- Ragdolls, joints

---

## Input System

- **Input Actions**: Remappable named actions with configurable deadzones — same code works for keyboard + gamepad
- Keyboard (physical key mode for layout independence), Mouse (visible/hidden/captured, raw input), Gamepad (up to 8, LED/sensor support), Pen/Tablet (pressure + tilt)
- Access via `Input` singleton: `Input.is_action_just_pressed("action_name")`, `Input.get_axis()`, `Input.get_vector()`
- Define actions in Project Settings > Input Map

---

## Audio

- Mono, stereo, 5.1, 7.1 output
- Positional 2D/3D audio with optional Doppler
- Re-routable audio buses with dozens of built-in effects
- Polyphony (multiple sounds from one AudioStreamPlayer)
- Random volume/pitch, sequential/random sample selection
- Audio input (microphone), text-to-speech, MIDI input
- Backends: WASAPI (Windows), CoreAudio (macOS), PulseAudio/ALSA (Linux)

---

## Animation

- Animate any property with customizable interpolation
- Method call tracks, audio tracks, Bézier curves
- Direct Kinematics + Inverse Kinematics
- `AnimationPlayer` + `AnimationTree` for state machines/blending
- `Tween` (via Tweeners) for simple programmatic animations
- `AnimatedSprite2D` / `AnimatedSprite3D` for frame-by-frame animation
- 2D cutout animation with `Skeleton2D + Bone2D`

---

## UI System (Control Nodes)

- Built from Control nodes (same system powers the editor UI)
- Common nodes: Button, CheckBox, CheckButton, LineEdit, TextEdit, CodeEdit, Label, RichTextLabel (BBCode), OptionButton, PopupMenu, Tree, ColorPicker, TextureRect, ColorRect
- Containers: HBox/VBox, Grid, Flow, Margin, Center, AspectRatio, Splitter, Section
- Anchors + stretch modes for resolution independence
- Theming: built-in theme editor, StyleBoxFlat (vector/procedural), StyleBoxTexture
- Drag-and-drop support
- Pixel-perfect UI: snap controls to pixels in Project Settings

---

## File Formats & Import

### Supported Import Formats
- **Images**: PNG, JPG, WebP, SVG (with oversampling), Basis Universal
- **Audio**: WAV (QOA/IMA-ADPCM), Ogg Vorbis, MP3
- **3D**: glTF 2.0 (recommended), .blend (via Blender), FBX (via FBX2glTF), Collada, OBJ (static)
- Custom import plugins supported

### Save/Load
- `FileAccess` for text/binary files (optionally compressed/encrypted)
- JSON via `JSON` class
- INI-style config via `ConfigFile`
- XML via `XMLParser`
- Pack game data into PCK files, ZIP archives, or inline in executable
- Additional PCK files for mods/DLC

---

## Networking

- **Low-level**: TCP (StreamPeer, TCPServer), UDP (PacketPeer, UDPServer), HTTP (HTTPClient)
- **High-level HTTP**: HTTPRequest node (HTTPS with bundled certs)
- **Multiplayer**: UDP + ENet with automatic RPC replication (unreliable/reliable/ordered)
- WebSocket client + server, WebRTC client + server
- UPnP for NAT traversal

---

## Navigation

- A* pathfinding in 2D and 3D
- Navigation meshes with dynamic obstacle avoidance
- Generate navmeshes in-editor or at runtime
- NavigationRegion2D / NavigationRegion3D, NavigationAgent2D / NavigationAgent3D

---

## XR (AR/VR)

- OpenXR support out of the box
- Desktop headsets (Valve Index, WMR, Quest via Link)
- Android standalone headsets (Meta Quest, Pico 4, Magic Leap 2, Lynx R1)
- Limited visionOS support (flat plane, no immersive)
- XR plugin structure for other devices

---

## Performance & Optimization

- Visual profiler (CPU + GPU per pipeline stage)
- Performance monitors (custom ones supported)
- Tracy and Perfetto tracer support
- Multi-threading via threads
- GPU particle collision: SDF (2D), box/sphere/baked SDF/heightmap (3D)
- Occlusion culling (raster-based, OccluderInstance3D)
- Level-of-detail: Mesh LOD, HLOD (visibility ranges)
- Variable rate shading (Forward+/Mobile)
- MultiMeshInstance3D for instanced rendering
- Optimize builds: feature profiling → smaller export templates
- Memory management: reference counting (not GC) for GDScript
- GPU-based denoising (JNLM) or OIDN for LightmapGI baking

---

## Migration Paths

### Godot 3 → 4 Key Breaks
- `Spatial` → `Node3D` (all 3D nodes got `3D` suffix)
- `KinematicBody` → `CharacterBody3D`, `KinematicBody2D` → `CharacterBody2D`
- `Viewport` → `SubViewport`, `ViewportContainer` → `SubViewportContainer`
- `VisualServer` → `RenderingServer`
- `instance()` → `instantiate()`
- `File`/`Directory` → `FileAccess`/`DirAccess`
- `OS` time methods → `Time` singleton; screen/window → `DisplayServer`
- `Tool` → `@tool` annotation
- `GDScript` setter/getter syntax changed, signal connection syntax changed
- `_ready()`/`_process()` no longer auto-call parent — use `super()`
- Lifecycle functions start with `_` (e.g., `_process`, `_ready`)
- `Tween` → `Tweener` (also available in Godot 3.5+)
- `randomize()` → auto-called on project load
- `rotation_degrees` → `rotation` (displayed as degrees in inspector)
- `.shader` → `.gdshader` extension
- Shader NDC Z-range changed to [0.0, 1.0] in Forward+/Mobile
- Reverse Z depth buffer (Godot 4.3+)
- `ToolButton` → `Button` with `flat=true`
- `ParticlesMaterial` → `ParticleProcessMaterial`

### Version Upgrade Guides Available
- 4.0 → 4.1, 4.1 → 4.2, 4.2 → 4.3, 4.3 → 4.4, 4.4 → 4.5, 4.5 → 4.6, 4.6 → 4.7

---

## Platform Export

- Desktop: Windows (x86/ARM 64+32), macOS (x86/ARM 64), Linux (x86/ARM 64+32, rv64/ppc/loongarch64)
- Mobile: Android, iOS
- Web: HTML5 (Compatibility renderer)
- Console: via partner program (Godot website)
- Headless server mode: `--headless` CLI flag

---

## This Project Architecture (MineWar2)

The project uses these Godot 4.x patterns:
- **CharacterBody2D** as the base for characters with `camp` (0=player, 1=enemy) and `_tier` (y-axis lane: -1/0/1) properties
- **Equipment slots** system: `equipment_slots: Array[PackedScene]` for weapons/armor/boots/leggings/helmets, `active_slots` for active items (shields/food/crossbow/blocks), `ai_modules: Array[Resource]` for AI behaviors
- **AnimatedSprite2D** upper/lower split for character rendering
- **Area2D** for selection (`SelectArea`) and attack detection (`AttackArea`)
- **PiecesParent** singleton manages multi-select and box selection
- **AI system**: separate `.tres` resources with behavior templates (charge, hit-and-run, gang, shield, follow-shield, eat, dirty-trick)
- **Custom UI**: pixel-art themed windows, item slots, buttons, labels with CRT-style rendering
- **F12**: toggle UI visibility during gameplay
- **F12 + F11**: test window management
- Troops generated at `res://sence/Fight/生成的兵种/`
- Testing buildings at x=350/-350 with 3x scale
- **PiecesParent.box_select(rect)** and **PiecesParent.deselect_all()** for unit selection
- Characters auto-move toward enemy base (`auto_move = 1`)
