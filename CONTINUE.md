# Continuation guide

How to pick up this project with Claude Code (or by hand) on a local machine.
`CLAUDE.md` has the short auto-loaded context; this file is the fuller playbook.

Branch for all work: **`claude/generate-3d-models-QLen9`**.

---

## 1. Get the code locally

```bash
git clone https://github.com/juliankrispel/0xmarkmaking.git
cd 0xmarkmaking
git checkout claude/generate-3d-models-QLen9
git pull origin claude/generate-3d-models-QLen9
claude            # starts Claude Code; it auto-reads CLAUDE.md
```

---

## 2. What's in the repo

Two related deliverables for a low-poly, Settlers-style village game.

```
public/village-models.html   # self-contained Three.js model gallery (the web viewer)
pages/index.js               # Next.js homepage: embeds the gallery in an iframe
game/                        # Godot 4.x game prototype (the playable loop)
CLAUDE.md                    # short context, auto-loaded by Claude Code
CONTINUE.md                  # this file
```

### A. Web 3D viewer — `public/village-models.html`
- Interactive gallery: buildings, terrain tiles, carryable goods, a 9-unit roster,
  a village diorama, with a global **animation mode** selector
  (Idle/Walk/Carry/Build/Chop/Fight) and stylized post-processing.
- **Deliberate tech choice:** Three.js **r137 global build via classic `<script>`
  tags** (no ES modules / import-map). This makes it render through proxy/preview
  services. Don't "modernize" it back to modules unless you also drop those.
- Everything (model builders, units, post shader, camera) lives in the inline
  `<script>` block in that one file.
- **Edit & preview locally:**
  - Open the file directly in a browser, or `npm install && npm run dev` then
    visit http://localhost:3000 (the homepage iframes it).
  - Quick JS syntax check without a browser:
    ```bash
    node -e 'const fs=require("fs");const h=fs.readFileSync("public/village-models.html","utf8");const m=[...h.matchAll(/<script>([\s\S]*?)<\/script>/g)];m.forEach((x,i)=>fs.writeFileSync("/tmp/s"+i+".js",x[1]))'
    for f in /tmp/s*.js; do node --check "$f" && echo "OK $f"; done
    ```
  - Share-on-mobile pattern (no hosting): push, then open
    `https://raw.githack.com/juliankrispel/0xmarkmaking/<COMMIT_SHA>/public/village-models.html`
    (use a commit SHA; the branch name has slashes that break githack).

### B. Godot game — `game/`
- **Godot 4.x**, GDScript. Open the `game/` folder as a project, press Play.
  Main scene: `res://Title.tscn`.
- Authored **in code** (no editor `.tscn` scenes beyond thin roots) because it was
  written without the editor. Converting buildings/units to real scenes is a fine
  future refactor.
- File map:
  | File | Role |
  |------|------|
  | `scripts/game_state.gd` | Autoload `GameState`: wood / population / housing / goal + signals |
  | `scripts/main.gd` | World, isometric ortho camera, HUD, build menu, click-to-place, pause wiring |
  | `scripts/worker.gd` | Lumberjack AI state machine (SEEK/TO_TREE/CHOP/RETURN/DELIVER) + procedural rig |
  | `scripts/tree_resource.gd` | Harvestable tree (depletes, regrows) |
  | `scripts/building.gd` | Building defs (`TYPES`) + House/Hut meshes |
  | `scripts/build_lib.gd` | Static low-poly mesh helpers |
  | `scripts/ui.gd` | Shared palette-matched `Theme` + widget/settings helpers |
  | `scripts/title.gd`, `scripts/pause.gd` | Title screen, pause overlay + settings |

- **The loop:** Town Hall (base housing 5, central wood stockpile). Lumberjacks
  walk to nearest tree -> chop -> carry log home -> wood +1. Spend wood:
  **House** (8 wood, +4 housing) or **Lumberjack Hut** (12 wood, +1 worker, needs
  free housing). **Goal:** grow to 12 villagers -> "thriving" banner. Camera:
  WASD/right-drag pan, wheel zoom, Q/E rotate. Esc = pause.

---

## 3. First job locally: verify the Godot project

It was written **without a running Godot**, so it is **unverified at runtime**.
Open it in Godot 4.x and work through this checklist:

- [ ] Project opens with no script parse errors (check the Errors/Debugger panel).
- [ ] Title screen shows New Game / Settings / Quit; New Game loads the world.
- [ ] World renders: ground, Town Hall, scattered trees, 2 starting lumberjacks.
- [ ] Workers walk to trees, play the chop motion, carry a log back, wood counter rises.
- [ ] Build menu cards enable/disable by affordability; clicking enters placement.
- [ ] Ghost footprint follows cursor, snaps, turns red on invalid; left-click places, right-click cancels.
- [ ] Placing a House raises housing; placing a Hut spawns a worker and uses housing.
- [ ] Reaching 12 population shows the banner.
- [ ] Esc pauses (game freezes, modal menu); Resume/Settings/Quit work; volume + fullscreen work.

**Most likely fix spots** (call these out to Claude if something's off):
- HUD auto-layout (the top bar / bottom build bar anchors and centering).
- The placement raycast (`_ground_point()` in `main.gd`) and grid snapping.
- Mesh/offset positions in `building.gd` / `worker.gd` (cosmetic, may float/clip).

---

## 4. Backlog (suggested order)

1. **Verify + fix** the Godot project (above).
2. **Juice:** wood-delivery number pop + sound, build/place SFX, subtle camera feedback.
3. **Production chain + 2nd resource:** Quarry -> Stone, Sawmill (Log -> Plank),
   buildings that need combos; routes/decisions deepen.
4. **Build cards polish:** richer icon cards instead of text buttons.
5. **Save/load** of the village; simple win/continue flow.
6. **Asset upgrade:** replace primitive meshes with nicer models (or export the web
   viewer's builders to `.glb`).

---

## 5. Ready-to-paste prompts for the local Claude session

- "Open the Godot project in `game/`, run it, and fix any runtime/parse errors so
  the core loop and menus work. Start by listing errors from a headless run
  (`godot --headless --quit` after import), then fix the HUD layout and placement
  raycast if needed."
- "Add juice to the Godot loop: a floating '+1 wood' label and a pop sound when a
  lumberjack delivers, plus a soft click when a building is placed."
- "Add a Quarry building and a Stone resource to the Godot game, then a Sawmill
  that turns Logs into Planks, and make the House cost wood + stone."
- "In `public/village-models.html`, tune the unit animation poses for Build and
  Fight and add a 'Gather' mode. Keep the r137 classic-script setup."

---

## 6. Conventions

- Work only on `claude/generate-3d-models-QLen9` (don't push elsewhere without asking).
- **GDScript indents with tabs.**
- Keep the web viewer on Three.js r137 + classic `<script>` tags.
- No PR opened yet — open one when ready to review/merge.
