import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../data/catalog.dart';
import '../../data/levels/levels.dart';
import '../../data/notes.dart';
import '../../game/dartworks_game.dart';
import '../../game/game_events.dart';
import '../../game/keyboard_input.dart';
import '../../theme.dart';
import '../game/game_panels.dart';
import '../game/hud_overlay.dart';
import '../game/touch_controls.dart';
import '../widgets/void_backdrop.dart';

/// Hosts a running level: Forge2D stage plus HUD, popups and controls.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});

  final String levelId;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver {
  DartworksGame? _game;
  late KeyboardInputMapper _mapper;
  final _focus = FocusNode();

  bool _paused = false;
  bool _dead = false;
  bool _mouseFire = false;
  bool _mouseGrab = false;
  NoteInfo? _note;
  LevelResult? _result;
  int _generation = 0;

  bool get _touchMode =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  DartworksGame get game => _game!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_generation == 0) _buildGame();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _game?.input.clearEdges();
      _mapper.clear();
    }
  }

  void _buildGame() {
    final data = levelDataFor(widget.levelId);
    if (data == null) return;
    _game = DartworksGame(
      level: data,
      store: AppScope.progressOf(context),
      events: GameEvents(
        onComplete: (r) => setState(() => _result = r),
        onDeath: () => setState(() => _dead = true),
        onNote: (n) => setState(() => _note = n),
        onUnlock: (_) {},
      ),
    );
    _mapper = KeyboardInputMapper(game.input);
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      _game?.paused = _paused;
    });
  }

  void _retry() {
    setState(() {
      _generation++;
      _dead = false;
      _result = null;
      _note = null;
      _paused = false;
      _buildGame();
    });
  }

  void _quit() => Navigator.of(context).pop();

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    _mapper.handleKey(event);
    if (_game?.input.pauseEdge ?? false) {
      game.input.pauseEdge = false;
      _togglePause();
    }
    return KeyEventResult.handled;
  }

  /// Mouse position -> world aim direction.
  void _aimFromPointer(Offset local, Size size) {
    if (_game == null || !game.isLoaded) return;
    final vf = game.camera.viewfinder;
    final ppu = game.metersToPixels * vf.zoom;
    final worldMouse = vf.position +
        Vector2(
          (local.dx - size.width / 2) / ppu,
          (local.dy - size.height / 2) / ppu,
        );
    final p = game.player.body.position;
    final dir = worldMouse - p;
    if (dir.length2 > 0.01) {
      _mapper.setAim(dir.x, dir.y);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = levelById(widget.levelId);
    if (levelDataFor(widget.levelId) == null) {
      return Scaffold(
        body: VoidBackdrop(
          child: Center(
            child: Text('UNKNOWN SECTOR', style: DwText.h1),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DwColors.voidBlack,
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size =
                Size(constraints.maxWidth, constraints.maxHeight);
            return Listener(
              onPointerHover: (e) =>
                  e.kind == PointerDeviceKind.mouse
                      ? _aimFromPointer(e.localPosition, size)
                      : null,
              onPointerDown: (e) {
                if (e.kind != PointerDeviceKind.mouse || _game == null) {
                  return;
                }
                if (e.buttons & kPrimaryMouseButton != 0) {
                  _mouseFire = true;
                  _mapper.setFire(true);
                }
                if (e.buttons & kSecondaryMouseButton != 0) {
                  _mouseGrab = true;
                  game.input.grab = true;
                }
              },
              onPointerUp: (e) {
                if (e.kind != PointerDeviceKind.mouse || _game == null) {
                  return;
                }
                if (_mouseFire) {
                  _mouseFire = false;
                  _mapper.setFire(false);
                }
                if (_mouseGrab) {
                  _mouseGrab = false;
                  game.input.grab = false;
                }
              },
              child: Stack(
                children: [
                  if (_game != null)
                    GameWidget(key: ValueKey(_generation), game: game),
                  if (_game != null) ...[
                    HudOverlay(hud: game.hud),
                    if (_touchMode)
                      TouchControls(
                          input: game.input, onPause: _togglePause),
                    MonomatPanel(
                      hud: game.hud,
                      onBuy: game.buyFromMonomat,
                    ),
                  ],
                  if (_note != null)
                    NotePopup(
                      note: _note!,
                      onClose: () => setState(() => _note = null),
                    ),
                  if (_paused && !_dead && _result == null)
                    PauseMenu(
                      onResume: () => setState(() {
                        _paused = false;
                        _game?.paused = false;
                      }),
                      onQuit: _quit,
                    ),
                  if (_dead)
                    DeathScreen(onRetry: _retry, onQuit: _quit),
                  if (_result != null)
                    CompleteScreen(
                      result: _result!,
                      onDone: _quit,
                    ),
                  Positioned(
                    top: 8,
                    left: 14,
                    child: SafeArea(
                      child: Text(
                        info?.title.toUpperCase() ?? '',
                        style: DwText.caption
                            .copyWith(color: DwColors.textFaint),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
