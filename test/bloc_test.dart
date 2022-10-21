import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_testing/apis/login_api.dart';
import 'package:bloc_testing/apis/notes_api.dart';
import 'package:bloc_testing/bloc/actions.dart';
import 'package:bloc_testing/bloc/app_bloc.dart';
import 'package:bloc_testing/bloc/app_state.dart';
import 'package:bloc_testing/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const Iterable<Note> mockNotes = [
  Note(title: 'Note 1'),
  Note(title: 'Note 2'),
  Note(title: 'Note 3'),
];

@immutable
class DummyNotesApi implements NotesApiProtocol {
  final LoginHandle acceptedLoginHandle;
  final Iterable<Note>? notesToReturnForAcceptedLoginHandle;

  const DummyNotesApi({
    required this.acceptedLoginHandle,
    required this.notesToReturnForAcceptedLoginHandle,
  });

  const DummyNotesApi.empty()
      : acceptedLoginHandle = const LoginHandle.fooBar(),
        notesToReturnForAcceptedLoginHandle = null;

  @override
  Future<Iterable<Note>?> getNotes({
    required LoginHandle loginHandle,
  }) async {
    if (loginHandle == acceptedLoginHandle) {
      return notesToReturnForAcceptedLoginHandle;
    } else {
      return null;
    }
  }
}

@immutable
class DummyLoginApi implements LoginApiProtocol {
  final String acceptedEmail;
  final String acceptedPassword;
  final LoginHandle loginHandle;

  const DummyLoginApi({
    required this.acceptedEmail,
    required this.acceptedPassword,
    required this.loginHandle,
  });

  @override
  Future<LoginHandle?> login({
    required String email,
    required String password,
  }) async {
    if (email == acceptedEmail && password == acceptedPassword) {
      return loginHandle;
    } else {
      return null;
    }
  }

  const DummyLoginApi.empty()
      : acceptedEmail = '',
        acceptedPassword = '',
        loginHandle = const LoginHandle.fooBar();
}

const acceptedLoginHandle = LoginHandle(token: 'ABC');

void main() {
  blocTest<AppBloc, AppState>(
    'Initial state of the bloc should be Appstate.empty()',
    build: () => AppBloc(
      loginApi: const DummyLoginApi.empty(),
      notesApi: const DummyNotesApi.empty(),
      acceptedLoginHandle: acceptedLoginHandle,
    ),
    verify: (appState) => expect(
      appState.state,
      const AppState.empty(),
    ),
  );
  blocTest<AppBloc, AppState>(
    'Can we log in with correct credentials?',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'bar@bz.com',
        acceptedPassword: 'foobar',
        loginHandle: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi.empty(),
      acceptedLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) => appBloc.add(
      const LoginAction(
        email: 'bar@bz.com',
        password: 'foobar',
      ),
    ),
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
    ],
  );
  blocTest<AppBloc, AppState>(
    'We should not log in with wrong credentials?',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'bar@bz.com',
        acceptedPassword: 'bar',
        loginHandle: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi.empty(),
      acceptedLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) => appBloc.add(
      const LoginAction(
        email: 'bar@bz.com',
        password: 'foo',
      ),
    ),
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: LoginErrors.invalidHandle,
        loginHandle: null,
        fetchedNotes: null,
      ),
    ],
  );
  blocTest<AppBloc, AppState>(
    'Load some notes with valid user',
    build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: 'bar@bz.com',
        acceptedPassword: 'foobar',
        loginHandle: acceptedLoginHandle,
      ),
      notesApi: const DummyNotesApi(
        acceptedLoginHandle: LoginHandle(
          token: 'ABC',
        ),
        notesToReturnForAcceptedLoginHandle: mockNotes,
      ), acceptedLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) {
      appBloc.add(
        const LoginAction(
          email: 'bar@bz.com',
          password: 'foobar',
        ),
      );
      appBloc.add(
        const LoadNotesAction(),
      );
    },
    expect: () => [
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: true,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
      const AppState(
        isLoading: false,
        loginErrors: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: mockNotes,
      ),
    ],
  );
}
