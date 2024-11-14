import 'package:firebase_auth/firebase_auth.dart';

abstract class UserService {
  Future<User?> getUser(String id);
  Future<User?> getCurrentUser();
}

class UserServiceImpl implements UserService {
  static UserService? _instance = null;

  static UserService get instance {
    _instance ??= UserServiceImpl();

    return _instance!;
  }

  final _auth = FirebaseAuth.instance;

  @override
  Future<User?> getCurrentUser() async => _auth.currentUser;

  @override
  Future<User?> getUser(String id) {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  UserServiceImpl();
}