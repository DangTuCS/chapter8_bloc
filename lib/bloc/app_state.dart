import 'package:bloc_testing/models.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class AppState {
  final bool isLoading;
  final LoginErrors? loginErrors;
  final LoginHandle? loginHandle;
  final Iterable<Note>? fetchedNotes;

  const AppState({
    required this.isLoading,
    required this.loginErrors,
    required this.loginHandle,
    required this.fetchedNotes,
  });

  const AppState.empty()
      : isLoading = false,
        loginErrors = null,
        loginHandle = null,
        fetchedNotes = null;

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading, loginErrors: $loginErrors, loginHandle: $loginHandle, fetchedNotes: $fetchedNotes}';
  }

}
