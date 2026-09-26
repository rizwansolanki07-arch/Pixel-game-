# Chanderi Quest — Game Build

## Direction
Original story and original characters with a female protagonist. The game uses an exploration/dialogue/quest/event architecture inspired by the observable interaction pattern of the reference game, without copying its code, story, characters, or assets.

## Locked visual assets
- Female protagonist sprites from the supplied character sheet.
- Indian village NPC sprites.
- Village, market, temple, inn, house and interior assets.
- Forest, river, mountain, cave and terrain tiles.
- Slime, wolf, skeleton, orc, undead, dragon and boss assets.

## Initial map
CHANDERI_VILLAGE
- Village Entrance
- Bazaar
- Inn Ground Floor
- Inn Upper Floor
- Seth House
- Farmers' Houses
- Mandir
- Godown
- River & Ghats
- Bridge

## Core systems
Player -> Map -> Interaction -> Dialogue -> Choice -> Quest -> World State -> Save/Load

## Vertical slice definition
1. New Game
2. Female protagonist spawns at village entrance
3. Four-direction movement and collision
4. Interact with NPC
5. Dialogue with choices
6. Receive first quest
7. Explore Chanderi Village
8. Collect/inspect quest item
9. Return to NPC
10. Complete quest
11. Persist a world-state consequence
12. Save and load
13. Resume at the correct map, position and quest state

## Architecture rule
Keep story/data separate from the engine. Never overwrite the existing Aether Resonance implementation.

## Asset rule
Only assets supplied by the project owner or assets with an explicitly permitted license should be shipped.
