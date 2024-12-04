import 'dart:io';
import 'package:path/path.dart' show extension;
import 'package:UgmaNet/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

abstract class PostService {
  Future<List<Post>> getPosts({String? userID});

  Future<Post> savePost(String content, String userID, {List<XFile>? images});

  Future<bool> likePost(String postID, String userID);

  Future<bool> unlikePost(String postID, String userID);

  Future<List<String>> getLikedUserIDList(String postID);
}

class PostServiceImpl implements PostService {
  static const String postTable = 'posts';

  static PostService? _instance;

  static PostService get instance {
    _instance ??= PostServiceImpl();

    return _instance!;
  }

  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Future<List<Post>> getPosts({String? userID}) async {
    final CollectionReference collectionReferencePosts =
        db.collection(postTable);

    final QuerySnapshot querySnapshot = await collectionReferencePosts
        .orderBy('createdAt', descending: true)
        .get();

    final List<Post> postsList = querySnapshot.docs
        .map((item) => _snapshotToPost(item, userID: userID))
        .toList();

    return postsList;
  }

  @override
  Future<Post> savePost(String content, String userID,
      {List<XFile>? images}) async {
    CollectionReference collectionReferencePosts = db.collection(postTable);

    // Create a new document in the "Feed" collection with a random ID
    DocumentReference documentReference = await collectionReferencePosts.add({
      "content": content,
      "images": [],
      "authorID": userID,
      "createdAt": Timestamp.now(),
      "likes": [],
    });

    if (images != null) {
      try {
        final postFolder = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child(documentReference.id);

        const idGen = Uuid();

        final imagesUrl = <String>[];
        for (var file in images) {

          final mimeType = file.mimeType;

          SettableMetadata? metadata;

          if (mimeType != null) {
            metadata = SettableMetadata(
              contentType: mimeType,
            );
          }

          final fileExtension = extension(file.path);
          final fileName = '${idGen.v4()}$fileExtension';

          final fileNode = postFolder.child(fileName);

          final res = await fileNode.putFile(File(file.path), metadata);

          final imageUrl = await res.ref.getDownloadURL();

          imagesUrl.add(imageUrl);
        }

        await documentReference.update({'images': imagesUrl});
      } catch (e) {
        documentReference.delete();
        rethrow;
      }
    }

    final doc = await documentReference.get();

    return _snapshotToPost(doc);
  }

  @override
  Future<bool> likePost(String postID, String userID) async {
    final postRef = db.collection(postTable).doc(postID);
    final postDoc = await postRef.get();

    final likes = List<String>.from(postDoc.get('likes'));

    if (!likes.contains(userID)) {
      likes.add(userID);
      postRef.update({'likes': likes});
      return true;
    }
    return false;
  }

  @override
  Future<bool> unlikePost(String postID, String userID) async {
    final postRef = db.collection(postTable).doc(postID);
    final postDoc = await postRef.get();

    final likes = List<String>.from(postDoc.get('likes'));

    if (likes.remove(userID)) {
      postRef.update({'likes': likes});
      return true;
    }
    return false;
  }

  @override
  Future<List<String>> getLikedUserIDList(String postID) async {
    final CollectionReference collectionReferencePosts =
        db.collection(postTable);

    final snapshot = await collectionReferencePosts.doc(postID).get();

    final userIDlist = List<String>.from(snapshot.get('likes'));

    return userIDlist;
  }

  static Post _snapshotToPost(DocumentSnapshot<Object?> doc, {String? userID}) {
    final String authorID = doc.get("authorID") as String;
    final DateTime createdAt = doc.get("createdAt").toDate();
    final String content = doc.get("content") ?? "";
    final List<String> images = List<String>.from(doc.get("images"));
    final likes = List<String>.from(doc.get("likes"));

    final likesCount = likes.length;

    bool isLikedByUser = false;

    if (userID != null) {
      isLikedByUser = likes.contains(userID);
    }

    return Post(authorID, content, images, likesCount, createdAt, doc.id,
        isLikedByUser);
  }
}
