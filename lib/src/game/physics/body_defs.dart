import 'package:flame_forge2d/flame_forge2d.dart';

/// Marks components whose surface characters can stand on. Used for
/// grounded checks without importing concrete component types.
mixin GroundSurface {}

/// Collision categories.
class DwBits {
  static const int terrain = 0x0001;
  static const int player = 0x0002;
  static const int prop = 0x0004;
  static const int enemy = 0x0008;
  static const int bullet = 0x0010;
  static const int sensor = 0x0020;
  static const int heldItem = 0x0040;
}

BodyDef staticBodyDef(double x, double y, {Object? userData}) => BodyDef(
      type: BodyType.static,
      position: Vector2(x, y),
      userData: userData,
    );

BodyDef dynamicBodyDef(
  double x,
  double y, {
  bool fixedRotation = false,
  bool isBullet = false,
  bool enableSleep = true,
  double gravityScale = 1,
  Vector2? linearVelocity,
  Object? userData,
}) =>
    BodyDef(
      type: BodyType.dynamic,
      position: Vector2(x, y),
      fixedRotation: fixedRotation,
      isBullet: isBullet,
      enableSleep: enableSleep,
      gravityScale: gravityScale,
      linearVelocity: linearVelocity,
      linearDamping: 0.05,
      angularDamping: 0.4,
      userData: userData,
    );

BodyDef kinematicBodyDef(double x, double y, {Object? userData}) => BodyDef(
      type: BodyType.kinematic,
      position: Vector2(x, y),
      userData: userData,
    );

ShapeGeometry boxShape(double halfW, double halfH) =>
    Polygon.box(halfW, halfH);

ShapeGeometry offsetBoxShape(double halfW, double halfH, Vector2 center) =>
    Polygon.offsetBox(halfW, halfH, center: center);

ShapeGeometry circleShape(double radius, [Vector2? center]) =>
    Circle(radius: radius, center: center);

/// Sensor and contact events are on by default — every interactive
/// component relies on them.
ShapeDef shapeDef({
  double density = 1,
  double friction = 0.4,
  double restitution = 0,
  bool isSensor = false,
  int category = DwBits.prop,
  int mask = Filter.allCategories,
  Object? userData,
}) =>
    ShapeDef(
      density: density,
      material: SurfaceMaterial(friction: friction, restitution: restitution),
      filter: Filter(categoryBits: category, maskBits: mask),
      isSensor: isSensor,
      userData: userData,
      enableContactEvents: true,
      enableSensorEvents: true,
    );
