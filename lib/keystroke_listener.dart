import 'package:flutter/services.dart';
import 'dart:async';

class KeystrokeEvent {
  final int vkCode;
  final int scanCode;
  final int flags;
  final String type;

  KeystrokeEvent({
    required this.vkCode,
    required this.scanCode,
    required this.flags,
    required this.type,
  });

  factory KeystrokeEvent.fromMap(Map<dynamic, dynamic> map) {
    return KeystrokeEvent(
      vkCode: map['vkCode'] as int,
      scanCode: map['scanCode'] as int,
      flags: map['flags'] as int,
      type: map['type'] as String,
    );
  }
}

class KeystrokeListener {
  static const EventChannel _channel = EventChannel('strokeviz/keystrokes');
  
  Stream<KeystrokeEvent>? _stream;

  Stream<KeystrokeEvent> get onKeystroke {
    _stream ??= _channel.receiveBroadcastStream().map((dynamic event) {
      return KeystrokeEvent.fromMap(event as Map<dynamic, dynamic>);
    });
    return _stream!;
  }
}
