import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class Authuser {
  final bool isEmailVerified;
  const Authuser({required this.isEmailVerified});

  factory Authuser.fromFirebase(User user) =>
      Authuser(isEmailVerified: user.emailVerified);
}
