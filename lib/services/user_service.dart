import 'dart:io';

import 'package:UgmaNet/models/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

abstract class UserService {
  User? get user;
  Profile? get profile;
  Future<User?> getUser(String id);

  Future<User?> getCurrentUser();

  Future<Profile?> getProfile(String id);

  Future<Profile?> createProfile(Map<String, String> data);

  Future<void> updateProfilePicture(XFile? file);
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
  @override
  User? get user => _auth.currentUser;
  // backed field
  Profile? _profile;
  @override
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
    final pictureUrl = doc.get('pictureUrl');

    return Profile(doc.id, userID, username, firstName, lastName, pictureUrl);
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

    // Chequea que el user no tenga ya creado un perfil
    final res = await collectionReferencePosts.where('userID', isEqualTo: userID).count().get();
    if (res.count! > 0) throw Exception('Usuario ya posee un perfil');

    // Chequea que el username sea unico
    final coll = await collectionReferencePosts.where('username', isEqualTo: data['username']).count().get();
    if (coll.count! > 0) throw {'error': 'El nombre de usuario ya ha sido tomado'};

    final docRef = await collectionReferencePosts.add({
      'userID': userID,
      'firstName': data['firstName'],
      'lastName': data['lastName'],
      'username': data['username'],
      'pictureUrl': null,
    });

    final snapshot = await docRef.get();

    final profile = _snapshotToProfile(snapshot);

    _profile = profile;

    return profile;
  }

  @override
  Future<void> updateProfilePicture(XFile? file) async {
    final currentUser = user;
    if (currentUser == null) throw Exception('Usuario debe estar logueado');

    if (file != null) {
      try {
        final rootFolder = FirebaseStorage.instance.ref();
        final pfpFolder = rootFolder.child('profiles').child(currentUser.uid).child('picture');

        final fileID = Uuid().v4();
        final fileExtension = extension(file.path);
        final fileName = '$fileID$fileExtension';

        SettableMetadata? metadata;

        if (file.mimeType != null) {
          metadata = SettableMetadata(contentType: file.mimeType);
        }

        final fileNode = pfpFolder.child(fileName);
        final res = await fileNode.putFile(File(file.path), metadata);
        final pfpUrl = await res.ref.getDownloadURL();

        await currentUser.updatePhotoURL(pfpUrl);

        final querySnapshot = await db.collection(PROFILE_TABLE).where('userID', isEqualTo: currentUser.uid).get();
        final profileRef = querySnapshot.docs.first.reference;

        profileRef.update({'pictureUrl': pfpUrl});

        _profile = _snapshotToProfile(await profileRef.get());
      } catch (e) {
        rethrow;
      }
    } else {
      // todo: clean user profile here
    }
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
