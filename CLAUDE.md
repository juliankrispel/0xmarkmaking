# Project handoff / context

This repo holds two related things for a low-poly, Settlers-style village game,
both developed on branch **`claude/generate-3d-models-QLen9`**.

> See **`CONTINUE.md`** for the fuller playbook: local setup, a Godot
> verification checklist, prioritized backlog, and ready-to-paste prompts.

## 1. Web 3D model viewer (Next.js + Three.js)

- **`public/village-models.html`** — a self-contained interactive gallery of the
  low-poly assets (buildings, terrain, carryable goods, a unit roster, a village
  diorama). Uses **Three.js r137 via CDN with classic `<script>` tags** (NOT ES
  modules / import-maps — that choice is deliberate so it renders through proxy
  services). All model builders and the post-processing (edge blur, bloom,
  warm/cool grade, vignette, grain) live in the inline `<script>` in that file.
  - Units are config-driven (`UNITS`) with role hats/props, smooth spheres for
    heads/hands, and a global animation mode (`MODE`): Idle/Walk/Carry/Build/Chop/Fight.
- **`pages/index.js`** embeds that file in an iframe, so the deployed site shows
  the gallery.
- View it: open the file directly in a browser, or run `npm install && npm run dev`
  then visit http://localhost:3000. (It also renders via raw.githack.com when
  pointed at the raw file by commit SHA.)

## 2. Godot game prototype (`game/`)

- **Godot 4.x**, GDScript. Open the `game/` folder as a project and press Play.
  Main scene is `res://Title.tscn`.
- Built **in code** (not editor `.tscn` scenes) on purpose, since it was authored
  without the editor — easy to convert to scenes later.
- **Core loop (Settlers-style auto-economy):** Town Hall hub gives base housing;
  lumberjacks walk to trees, chop, carry logs home, wood ticks up. Spend wood in
  the build menu: **House** (+4 housing) or **Lumberjack Hut** (+1 worker, needs
  free housing). Goal: grow to 12 villagers.
- Files:
  - `scripts/game_state.gd` — autoload `GameState`: wood/population/housing/goal + signals.
  - `scripts/main.gd` — world, isometric ortho camera, HUD, build menu, click-to-place, pause.
  - `scripts/worker.gd` — unit AI state machine + procedural rig (ports the web viewer's animateUnit).
  - `scripts/building.gd`, `tree_resource.gd`, `build_lib.gd` — buildings, resources, mesh helpers.
  - `scripts/ui.gd` — shared palette-matched Theme + widgets; `title.gd`, `pause.gd` — menus.
- **IMPORTANT: the Godot project is unverified at runtime** — it was written in an
  environment without Godot. First task locally: open it in Godot 4.x, fix any
  errors, and confirm the loop/menus work. Most likely tweak spots: HUD auto-layout
  and the placement raycast.

## Conventions

- All work goes on `claude/generate-3d-models-QLen9` (do not push elsewhere without asking).
- Indent GDScript with **tabs**.
- No PR has been opened yet.

## Suggested next steps

- Verify/fix the Godot project in the editor.
- Juice: delivery pop + sound, number tweens, build/place SFX.
- A second resource + production chain (Sawmill -> Plank), richer build cards.
