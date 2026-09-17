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

class _GameScreenState extends State<GameScreen> {
  late DartworksGame _game;
  late KeyboardInputMapper _mapper;
  final _focus = FocusNode();

  bool _paused = false;
  bool _dead = false;
  NoteInfo? _note;
  LevelResult? _result;
  int _generation = 0;

  bool get _touchMode =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_generation == 0) _buildGame();
  }

  void _buildGame() {
    final data = levelDataFor(widget.levelId)!;
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
    _mapper = KeyboardInputMapper(_game.input);
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
    if (_game.input.pauseEdge) {
      _game.input.pauseEdge = false;
      setState(() {
        _paused = !_paused;
        _game.paused = _paused;
      });
    }
    return KeyEventResult.handled;
  }

  /// Mouse position -> world aim direction.
  void _aimFromPointer(Offset local, Size size) {
    if (!_game.isLoaded) return;
    final vf = _game.camera.viewfinder;
    final ppu = _game.metersToPixels * vf.zoom;
    final worldMouse = vf.position +
        Vector2(
          (local.dx - size.width / 2) / ppu,
          (local.dy - size.height / 2) / ppu,
        );
    final p = _game.player.body.position;
    final dir = worldMouse - p;
    if (dir.length2 > 0.01) {
      _mapper.setAim(dir.x, dir.y);
    }
  }

  @override
  void dispose() {
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
                if (e.kind != PointerDeviceKind.mouse) return;
                if (e.buttons & kPrimaryMouseButton != 0) {
                  _mapper.setFire(true);
                }
                if (e.buttons & kSecondaryMouseButton != 0) {
                  _game.input.grab = true;
                }
              },
              onPointerUp: (e) {
                if (e.kind == PointerDeviceKind.mouse) {
                  _mapper.setFire(false);
                  _game.input.grab = false;
                }
              },
              child: Stack(
                children: [
                  GameWidget(key: ValueKey(_generation), game: _game),
                  HudOverlay(hud: _game.hud),
                  if (_touchMode) TouchControls(input: _game.input),
                  MonomatPanel(
                    hud: _game.hud,
                    onBuy: _game.buyFromMonomat,
                  ),
                  if (_note != null)
                    NotePopup(
                      note: _note!,
                      onClose: () => setState(() => _note = null),
                    ),
                  if (_paused && !_dead && _result == null)
                    PauseMenu(
                      onResume: () => setState(() {
                        _paused = false;
                        _game.paused = false;
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
