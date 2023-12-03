import 'package:myfirstapp/services/auth/auth_exceptions.dart';
import 'package:myfirstapp/services/auth/auth_provider.dart';
import 'package:myfirstapp/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authenticator', () {
    final provider = MockAuthProvider();
    test('Should not be initialized at begining', () {
      expect(provider._isInitialized, false);
    });
    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider._isInitialized, true);
    });
    test('User should be null after initialization', () {
      expect(provider._user, null);
    });
  });
}

class NotInitializedAuthException implements Exception {}

class MockAuthProvider implements AuthProvider {
  Authuser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<Authuser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedAuthException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  Authuser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<Authuser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedAuthException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobaz') throw WrongPasswordAuthException();
    const user = Authuser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedAuthException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedAuthException();
    final user = _user;
    if (user == null) throw UserNotLoggedInAuthException();
    const newUser = Authuser(isEmailVerified: true);
    _user = newUser;
  }
}
