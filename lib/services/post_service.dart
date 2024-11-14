import 'package:UgmaNet/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PostService {
  Future<List<Post>> getPosts();
  Future<Post> savePost(String content, String userID);
}

class PostServiceImpl implements PostService {
  static PostService? _instance = null;

  static PostService get instance {
    _instance ??= PostServiceImpl();

    return _instance!;
  }

  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Future<List<Post>> getPosts() async {
    final CollectionReference collectionReferencePosts = db.collection("posts");

    final QuerySnapshot querySnapshot = await collectionReferencePosts.get();

    final List<Post> postsList = await _processQuerySnapshot(querySnapshot);

    // Reordena posts por fecha de creacion
    postsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return postsList;
  }

  Future<List<Post>> _processQuerySnapshot(QuerySnapshot querySnapshot) async {
    final List<Post> posts = [];

    // Deserialize values
    for (var doc in querySnapshot.docs) {
      final String userID = doc.get("authorID") as String;

      final DateTime createdAt = doc.get("createdAt").toDate();

      final String content = doc.get("content") ?? "";
      final List<String> images = List<String>.from(doc.get("images"));

      final int likesCount = List<String>.from(doc.get("likes")).length;

      final post = Post(userID, content, images, likesCount, createdAt, doc.id);

      posts.add(post);
    }

    return posts;
  }

  @override
  Future<Post> savePost(String content, String userID) async {
    CollectionReference collectionReferencePosts = db.collection("posts");

    // Create a new document in the "Feed" collection with a random ID
    DocumentReference documentReference = await collectionReferencePosts.add({
      "content": content,
      "images": [],
      "authorID": userID,
      "createdAt": Timestamp.now(),
      "likes": [],
    });

    final doc = await documentReference.get();

    final String docAuthorID = doc.get("authorID") as String;

    final DateTime docCreatedAt = doc.get("createdAt").toDate();

    final String docContent = doc.get("content") ?? "";
    final List<String> docImages = List<String>.from(doc.get("images"));

    final int docLikesCount = List<String>.from(doc.get("likes")).length;

    final post = Post(docAuthorID, docContent, docImages, docLikesCount, docCreatedAt, doc.id);

    return post;
  }
}
