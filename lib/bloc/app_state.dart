import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show immutable;

@immutable
class AppState {
  final bool isLoading;
  final Uint8List? data;
  final Object? error;

  const AppState({
    required this.isLoading,
    this.data,
    this.error,
  });

  const AppState.empty()
      : isLoading = false,
        data = null,
        error = null;

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading, data: ${data!}, error: $error}';
  }
}
