import 'package:bloc_testing/models.dart';
import 'package:collection/collection.dart';
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

  @override
  bool operator ==(covariant AppState other) {
    final otherPropertiesAreEqual = runtimeType == other.runtimeType &&
        isLoading == other.isLoading &&
        loginErrors == other.loginErrors &&
        loginHandle == other.loginHandle;
    if (fetchedNotes == null && other.fetchedNotes == null) {
      return otherPropertiesAreEqual;
    } else {
      return otherPropertiesAreEqual &&
          (fetchedNotes?.isEqualTo(other.fetchedNotes) ?? false);
    }
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^
      loginErrors.hashCode ^
      loginHandle.hashCode ^
      fetchedNotes.hashCode;
}

extension UnorderedEquality on Object {
  bool isEqualTo(other) =>
      const DeepCollectionEquality.unordered().equals(this, other);
}
