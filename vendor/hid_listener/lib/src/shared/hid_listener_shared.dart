import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:hid_listener/hid_listener.dart';

import 'hid_listener_bindings_shared.dart' as bindings;

MouseEvent? mouseProc(dynamic event) {
  final eventAddr = ffi.Pointer<bindings.MouseEvent>.fromAddress(event);
  MouseEvent? mouseEvent;

  if (eventAddr.ref.eventType == bindings.MouseEventType.LeftButtonDown) {
    mouseEvent = MouseButtonEvent(
        x: eventAddr.ref.x,
        y: eventAddr.ref.y,
        type: MouseButtonEventType.leftButtonDown);
    mouseEvent.windowTitle = eventAddr.ref.windowTitle.toDartString();
  } else if (eventAddr.ref.eventType == bindings.MouseEventType.LeftButtonUp) {
    mouseEvent = MouseButtonEvent(
        x: eventAddr.ref.x,
        y: eventAddr.ref.y,
        type: MouseButtonEventType.leftButtonUp);
    mouseEvent.windowTitle = eventAddr.ref.windowTitle.toDartString();
  } else if (eventAddr.ref.eventType ==
      bindings.MouseEventType.RightButtonDown) {
    mouseEvent = MouseButtonEvent(
        x: eventAddr.ref.x,
        y: eventAddr.ref.y,
        type: MouseButtonEventType.rightButtonDown);
    mouseEvent.windowTitle = eventAddr.ref.windowTitle.toDartString();
  } else if (eventAddr.ref.eventType == bindings.MouseEventType.RightButtonUp) {
    mouseEvent = MouseButtonEvent(
        x: eventAddr.ref.x,
        y: eventAddr.ref.y,
        type: MouseButtonEventType.rightButtonUp);
    mouseEvent.windowTitle = eventAddr.ref.windowTitle.toDartString();
  } else if (eventAddr.ref.eventType == bindings.MouseEventType.MouseMove) {
    mouseEvent = MouseMoveEvent(x: eventAddr.ref.x, y: eventAddr.ref.y);
  } else if (eventAddr.ref.eventType == bindings.MouseEventType.MouseWheel ||
      eventAddr.ref.eventType == bindings.MouseEventType.MouseHorizontalWheel) {
    mouseEvent = MouseWheelEvent(
        x: eventAddr.ref.x,
        y: eventAddr.ref.y,
        wheelDelta: eventAddr.ref.wheelDelta,
        isHorizontal: eventAddr.ref.eventType ==
            bindings.MouseEventType.MouseHorizontalWheel);
    mouseEvent.windowTitle = eventAddr.ref.windowTitle.toDartString();
  }

  return mouseEvent;
}
