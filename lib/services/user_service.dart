import 'package:UgmaNet/models/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserService {
  Future<User?> getUser(String id);

  Future<User?> getCurrentUser();

  Future<Profile?> getProfile(String id);

  Future<Profile?> createProfile(Map<String, String> data);
}

class UserServiceImpl implements UserService {
  static const String PROFILE_TABLE = 'profiles';

  static UserService? _instance;

  static UserService get instance {
    _instance ??= UserServiceImpl();

    return _instance!;
  }

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;
  // backed field
  Profile? _profile;
  Profile? get profile => _profile;

  @override
  Future<User?> getCurrentUser() async => _auth.currentUser;

  @override
  Future<User?> getUser(String id) {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<Profile?> getProfile(String id) async {
    final profileColl = db.collection(PROFILE_TABLE);

    final querySnapshot =
        await profileColl.where('userID', isEqualTo: id).get();

    return querySnapshot.docs.map(_snapshotToProfile).toList().firstOrNull;
  }

  static Profile _snapshotToProfile(DocumentSnapshot<Object?> doc) {
    final userID = doc.get('userID');
    final firstName = doc.get('firstName');
    final lastName = doc.get('lastName');
    final username = doc.get('username');

    return Profile(doc.id, userID, username, firstName, lastName);
  }

  @override
  Future<Profile?> createProfile(
      [Map<String, String> data = const {
        'firstName': '',
        'lastName': '',
      }]) async {
    final user = await getCurrentUser();

    final userID = user?.uid;

    if (userID == null) throw Exception("Usuario debe estar logueado");

    CollectionReference collectionReferencePosts = db.collection(PROFILE_TABLE);

    final res = await collectionReferencePosts.where('userID', isEqualTo: userID).count().get();

    if (res.count! > 0) throw Exception('Usuario ya posee un perfil');

    final docRef = await collectionReferencePosts.add({
      'userID': userID,
      'firstName': data['firstName'],
      'lastName': data['lastName'],
      'username': data['username'],
    });

    final snapshot = await docRef.get();

    final profile = _snapshotToProfile(snapshot);

    _profile = profile;

    return profile;
  }

  Future<void> _observeUserChanges(User? user) async {
    if (user == null) {
      _profile = null;
    } else {
      _profile = await getProfile(user.uid);
    }
  }

  UserServiceImpl() {
    FirebaseAuth.instance.authStateChanges().listen(_observeUserChanges);
  }
}
