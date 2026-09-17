# DARTWORKS

> **WARNING: This project is a fan-made demake and is NOT ever to go into production.
> It exists for educational and entertainment purposes only.**

A 2D physics-based demake of [BONEWORKS](https://boneworks.fandom.com/wiki/BONEWORKS_Wiki)
(Stress Level Zero, 2019) written in Flutter. Where the original used VR inverse
kinematics, this version uses a fully simulated 2D rigid body world powered by
Forge2D (Box2D): every prop, weapon, enemy and the player body itself is a real
physics object.

## Features

- **Full campaign** - all 12 story levels recreated in 2D: Breakroom, Museum of
  Technical Demonstration, Streets, Runoff, Sewers, Warehouse, Central Station,
  Tower, Time Tower, Dungeon, Arena and Throne Room.
- **Sandbox unlock chain** - Museum Basement, Handgun Range, [REDACTED] Chamber,
  Tuscany, Zombie Warehouse, Blankbox and Fantasy Arena, unlocked by reclaiming
  modules found hidden in the campaign, just like the original.
- **Physics sandbox** - grab, throw and stack props, break Boneboxes, collect
  Gachapons, feed Reclamation Bins and buy gear from Monomats using ammo as
  tender.
- **Lore notes** - readable Clipboard / MonoChat collectibles in every level.
- **The enemy roster** - Nullbodies, Corrupted Nullbodies, NullRats, Crablets,
  Zombish, Omniprojectors, Turrets, Ford Clones and King Ford himself.
- **Slow motion** - the signature BONEWORKS mechanic, bound to a key on desktop
  and a button on touch.

## Platforms

| Platform | Status |
|----------|--------|
| Linux desktop | `flutter run -d linux` / `flutter build linux` |
| Web | `flutter run -d chrome` / `flutter build web` |
| Android | `flutter run -d <device>` / `flutter build apk` |
| Windows / macOS / iOS | project files included, build on the matching OS |

Desktop builds are standard 2D builds - no VR required or supported.

## Controls

### Desktop / web

| Input | Action |
|-------|--------|
| `A` / `D` or arrows | Move |
| `W` / `Space` | Jump |
| `S` | Crouch |
| Mouse | Aim |
| Left click | Fire / swing held weapon |
| `E` or right click | Grab / throw physics objects |
| `Q` | Slow motion |
| `1` / `2` | Inventory slots |
| `F` | Interact |
| `Esc` | Pause |

### Touch

Virtual joystick on the left, action cluster on the right. Drag anywhere on the
right half to aim.

## Development

```bash
flutter pub get
flutter test            # unit, widget and golden tests
flutter test --coverage # coverage report
```

Golden images live in `test/goldens/`. Regenerate with
`flutter test --update-goldens`.

## Legal

DARTWORKS is an unofficial fan project. It is not affiliated with, endorsed by,
or connected to Stress Level Zero. BONEWORKS and all related names belong to
their respective owners. Level, item and lore information was researched from
the [BONEWORKS Wiki](https://boneworks.fandom.com) (CC-BY-SA); all code and
visuals here are original recreations.

Licensed under the [GNU AGPL v3](LICENSE).
