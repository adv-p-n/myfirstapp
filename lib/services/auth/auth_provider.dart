import 'package:myfirstapp/services/auth/auth_user.dart';

abstract class AuthProvider {
  Authuser? get currentUser;
  Future<Authuser> createUser({
    required String email,
    required String password,
  });
  Future<Authuser> logIn({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
}
