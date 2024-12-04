import 'dart:async';
import 'dart:io';
import 'package:UgmaNet/models/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

typedef UserStatus = ({User? user, Profile? profile});

abstract class UserService {
  /// Usuario actual.
  User? get user;

  /// Perfil del usuario actual.
  Profile? get profile;

  /// Stream para observar cambios de autenticación.
  Stream<UserStatus> authChanges();

  /// Devuelve el perfil del usuario con el [id] indicado.
  Future<Profile?> getProfile(String id);

  /// Crea un nuevo perfil
  Future<Profile?> createProfile(Map<String, String> data);

  /// Actualiza la foto de perfil del usuario
  Future<void> updateProfilePicture(XFile? file);
}

class UserServiceImpl implements UserService {

  final StreamController<UserStatus> _streamController = StreamController<UserStatus>.broadcast(
    onListen: () {}
  );

  static const String profileTable = 'profiles';

  static UserService? _instance;

  static UserService get instance {
    _instance ??= UserServiceImpl();
    return _instance!;
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final _auth = FirebaseAuth.instance;
  @override
  User? get user => _auth.currentUser;
  // backed field
  Profile? _profile;
  @override
  Profile? get profile => _profile;

  @override
  Stream<UserStatus> authChanges() {
    return _streamController.stream;
  }

  @override
  Future<Profile?> getProfile(String id) async {
    final profileColl = _db.collection(profileTable);

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
    final user = this.user;

    final userID = user?.uid;

    if (userID == null) throw Exception("Usuario debe estar logueado");

    CollectionReference collectionReferencePosts = _db.collection(profileTable);

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

    final event = (user: user, profile: profile);

    _streamController.add(event);

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

        final fileID = const Uuid().v4();
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

        final querySnapshot = await _db.collection(profileTable).where('userID', isEqualTo: currentUser.uid).get();
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

  Future<void> _observeAuthChanges(User? user) async {
    Profile? profile;

    if (user == null) {
      profile = null;
    } else {
      profile = await getProfile(user.uid);
    }

    _profile = profile;
    UserStatus event = (user: user, profile: profile);
    _streamController.add(event);
  }

  UserServiceImpl() {
    FirebaseAuth.instance.authStateChanges().listen(_observeAuthChanges);
  }
}
