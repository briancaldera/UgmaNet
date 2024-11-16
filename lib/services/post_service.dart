import 'package:UgmaNet/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PostService {
  Future<List<Post>> getPosts({String? userID});

  Future<Post> savePost(String content, String userID);

  Future<bool> likePost(String postID, String userID);

  Future<bool> unlikePost(String postID, String userID);

  Future<List<String>> getLikedUserIDList(String postID);
}

class PostServiceImpl implements PostService {
  static const String TABLE_NAME = 'posts';

  static PostService? _instance;

  static PostService get instance {
    _instance ??= PostServiceImpl();

    return _instance!;
  }

  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Future<List<Post>> getPosts({String? userID}) async {
    final CollectionReference collectionReferencePosts =
        db.collection(TABLE_NAME);

    final QuerySnapshot querySnapshot = await collectionReferencePosts.orderBy('createdAt', descending: true).get();

    final List<Post> postsList =
        querySnapshot.docs.map((item) => _snapshotToPost(item, userID: userID)).toList();

    return postsList;
  }

  @override
  Future<Post> savePost(String content, String userID) async {
    CollectionReference collectionReferencePosts = db.collection(TABLE_NAME);

    // Create a new document in the "Feed" collection with a random ID
    DocumentReference documentReference = await collectionReferencePosts.add({
      "content": content,
      "images": [],
      "authorID": userID,
      "createdAt": Timestamp.now(),
      "likes": [],
    });

    final doc = await documentReference.get();

    return _snapshotToPost(doc);
  }

  @override
  Future<bool> likePost(String postID, String userID) async {
    final postRef = db.collection(TABLE_NAME).doc(postID);
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
    final postRef = db.collection(TABLE_NAME).doc(postID);
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
    db.collection(TABLE_NAME);

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

    return Post(authorID, content, images, likesCount, createdAt, doc.id, isLikedByUser);
  }
}
