# RE2 Studio Framework

Framework de Godot 4 para construir juegos tipo *survival horror* con vista de diorama, basado en el template de inmersión en primera persona [COGITO](https://github.com/Phazorknight/Cogito). Añade una capa de servicios (`core/`), sistemas de gameplay (`gameplay/`), UI y herramientas de editor propias, listas para usar.

> [!NOTE]
> Este archivo reemplaza el README original del template COGITO. La documentación completa de COGITO sigue disponible en [su web](https://cogito.readthedocs.io/en/latest/index.html).

---

## ¿Qué es?

`RE2 Studio Framework` es la base sobre la que se construyen los juegos del equipo. En lugar de empezar de cero cada proyecto, el equipo parte de este framework que ya incluye:

- **Servicios globales (autoloads)** de pausa, escenas, guardado, audio, ajustes e input.
- **Sistemas de gameplay** reutilizables: controlador de personaje, diálogos, interacción, inventario y misiones.
- **Sistema de cámara de diorama** con rotación direccional y paredes que se ocultan dinámicamente.
- **Scenas demo** de referencia para ver cómo se usa cada pieza.

Todo el núcleo está comentado en español para que el equipo pueda entenderlo sin fricción.

---

## Requisitos

- **Godot 4.7.1** (o compatible con la rama 4.x que uses).
- Motor de físicas: **Jolt Physics** (configurado en `project.godot`).
- No se requiere ningún paquete adicional: los addons ya vienen incluidos en `addons/`.

---

## Estructura del proyecto

```
core/            # Servicios globales del framework (autoloads y utilidades)
  audio/         #   AudioManager: música y SFX
  camera/        #   CameraRig + TruckWall: cámara de diorama
  events/        #   EventBus: señales globales desacopladas
  game/          #   GameService: pausa y recolección de datos de guardado
  input/         #   InputManager: detección de método de entrada
  save/          #   SaveManager + SaveableComponent: guardado/carga
  scene_manager/ #   SceneManager: cambio y recarga de escenas
  settings/      #   SettingsManager: ajustes persistentes

gameplay/        # Sistemas de juego reutilizables
  character_controller/  #   Controlador de personaje 2D
  dialogue/              #   Datos y reproductor de diálogos
  interaction/           #   Componente interactuable
  inventory/             #   Inventario, items y base de datos de items
  quests/                #   Datos de misiones

ui/              # Interfaces de usuario
  dialogue_ui/   #   Vista de diálogo
  inventory_ui/  #   Vista de inventario
  menus/         #   Menú base
  transitions/   #   Capa de transiciones

editor/          # Herramientas del editor
  custom_inspectors/   #   Inspectores personalizados
  debug_tools/         #   Utilidades de depuración
  generators/          #   Generadores de recursos

data/            # Recursos de datos
  levels/        #   LevelData (define niveles)

demos/           # Scenas de ejemplo / pruebas
  camera_prototype/    #   Prototipo de cámara de diorama
  cogito_levels/       #   Niveles basados en COGITO
  framework_demo.tscn  #   Demo general del framework
  scene_manager_level_a/b.tscn  #   Demos de cambio de escena

addons/          # Plugins incluidos (COGITO, phantom camera, input helper, etc.)
docs/            # Documentación e imágenes de referencia
```

---

## Servicios globales (autoloads)

Todos están registrados en `project.godot` en la sección `[autoload]` y disponibles desde cualquier script:

| Servicio        | Clase                | Ruta                          | Qué hace |
|-----------------|----------------------|-------------------------------|----------|
| `Game`          | `GameService`        | `core/game/game.gd`           | Pausa del juego y recolección de datos de guardado desde `save_providers`. |
| `EventBus`      | `EventBusService`    | `core/events/event_bus.gd`    | Señales globales (pausa, cambio de escena, guardado, inventario, diálogo, misiones) para desacoplar sistemas. |
| `SaveManager`   | `SaveManagerService` | `core/save/save_manager.gd`   | Guardado/carga en slots (`user://saves/`), con versión y timestamp. |
| `SceneManager`  | `SceneManagerService`| `core/scene_manager/scene_manager.gd` | Cambiar, recargar o volver a la escena anterior. |
| `AudioManager`  | `AudioManagerService`| `core/audio/audio_manager.gd` | Música y SFX con players dedicados y control de volumen master. |
| `SettingsManager`| `SettingsManagerService`| `core/settings/settings_manager.gd` | Ajustes persistentes en `user://settings.cfg`. |
| `InputManager`  | `InputManagerService`| `core/input/input_manager.gd` | Detecta teclado/ratón vs. gamepad y expone helpers de input. |

### Cómo se usa (ejemplo)

```gdscript
# Cambiar de escena
SceneManager.change_scene("res://demos/scene_manager_level_b.tscn")

# Escuchar eventos globales
EventBus.item_collected.connect(_on_item_collected)

# Guardar
SaveManager.save_game("slot_1", Game.collect_save_data())

# Reproducir sonido
AudioManager.play_sfx(my_stream)
```

---

## Sistema de cámara (diorama)

El prototipo está en `demos/camera_prototype/camera_prototype.tscn` y usa dos clases:

- **`CameraRig`** (`core/camera/camera_rig.gd`): cámara **ortográfica** de diorama.
  - `Q` gira la vista **a la derecha (+180°)** y `E` a la **izquierda (−180°)** (rotación direccional fija, dos vistas).
  - **Zoom** con la rueda del ratón.
  - **Tilt** (ángulo cenital) configurable por export.
- **`TruckWall`** (`core/camera/truck_wall.gd`): paredes del "truck" que pueden ocultarse. La pared que queda frente a la cámara se oculta automáticamente para ver el interior; las demás permanecen visibles. Requiere que las paredes estén en el grupo `truck_wall` con su dirección exterior en `outward_normal`.

> Esta es la cámara pensada para una vista tipo "diorama de camión" (habitación/escenario visto desde arriba con paredes recortadas).

---

## Sistemas de gameplay

- **`CharacterController2D`** (`gameplay/character_controller/`): controlador de personaje en 2D.
- **Diálogos** (`gameplay/dialogue/`): datos de diálogo (`DialogueData`, `DialogueEntry`, `DialogueOption`) y reproductor (`DialoguePlayer`), con vista en `ui/dialogue_ui/`.
- **Interacción** (`gameplay/interaction/`): componente `InteractableComponent` para que objetos reaccionen al jugador.
- **Inventario** (`gameplay/inventory/`): inventario por componentes, items (`ItemData`), slots y base de datos de items (`ItemDatabase`), con vista en `ui/inventory_ui/`.
- **Misiones** (`gameplay/quests/`): `QuestData` con señales de inicio/fin (`quest_started`, `quest_completed` en `EventBus`).

---

## Scenas demo

| Escena | Descripción |
|--------|-------------|
| `demos/camera_prototype/camera_prototype.tscn` | Prototipo de la cámara de diorama con rotación Q/E y zoom. |
| `demos/cogito_levels/cogito_level_a.tscn` | Nivel de ejemplo construido sobre COGITO (escena principal del proyecto). |
| `demos/cogito_levels/cogito_level_b.tscn` | Segundo nivel de ejemplo. |
| `demos/framework_demo.tscn` | Demo general del framework. |
| `demos/scene_manager_level_a.tscn` / `_b.tscn` | Demos de cambio de escena con el `SceneManager`. |

La escena principal (`run/main_scene`) es `res://demos/cogito_levels/cogito_level_a.tscn`.

---

## Controles (ejemplo del framework)

Estas son las acciones definidas en `project.godot` (sección `[input]`):

| Acción | Tecla |
|--------|-------|
| Movimiento | `WASD` |
| Saltar | `Espacio` |
| Agacharse | `C` |
| Correr | `Shift` |
| Interactuar | `F` / `E` |
| Menú / Inventario | `Esc` / `Tab` |
| Inventario (usar/soltar/girar) | Clic der. / `G` / `R` |
| Quickslots 1–4 | `1`–`4` |
| Cámara: girar derecha/izquierda | `Q` / `E` (en la cámara de diorama) |
| Cámara: zoom | Rueda del ratón |

---

## Convenciones para el equipo

- **Comentarios en español** en el código del framework.
- Los servicios se acceden por su nombre de autoload (ej. `SceneManager`, `EventBus`), **no** se instancian.
- Los scripts de clase usan `class_name` en la parte superior.
- Todo `var` lleva tipo explícito y las señales están tipadas.
- Los cambios de escena deben pasar por `SceneManager` para notificar al `EventBus`.
- El guardado se centraliza registrando proveedores en `Game.register_save_provider()`.

---

## Addons incluidos

- **COGITO** — template de inmersión en primera persona (interacción, inventario, atributos, NPC, menús, guardado, localización).
- **Phantom Camera** — cámaras cinematográficas.
- **Input Helper** — helpers de input.
- **Quick Audio** — gestión rápida de audio.
- **Sky 3D / Yard** — entorno y cielo.
- **Godot AI / godot_mcp_toolkit / script-ide** — herramientas de desarrollo.
- **project-time-tracker** — seguimiento de tiempo del proyecto.

---

## Cómo empezar

1. Abre el proyecto con **Godot 4.7.1**.
2. Pulsa **F5** (o el botón *Play*) para ejecutar la escena principal.
3. Explora las demos en `demos/` para ver cada sistema en acción.
4. Para crear una nueva mecánica, parte de un sistema existente en `gameplay/` o un servicio en `core/`.

---

## Licencia

Este proyecto parte del template **COGITO**, cuyo código y assets están licenciados por sus autores (ver la [documentación de COGITO](https://cogito.readthedocs.io/en/latest/about.html)). El código propio del framework está bajo la licencia del proyecto (ver `LICENSE`).
