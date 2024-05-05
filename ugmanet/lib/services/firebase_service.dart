import "package:cloud_firestore/cloud_firestore.dart";
import 'package:UgmaNet/visual/Screens/feed.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getUsuarios() async {
  List usuarios = [];
  CollectionReference collectionReferenceUsuarios = db.collection("Usuarios");

  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.get();

  for (var doc in queryUsuarios.docs) {
    usuarios.add(doc.data());
  }

  return usuarios;
}

Future<String> askUsuario(int expediente) async {
  CollectionReference collectionReferenceUsuarios = db.collection("Usuarios");
  QuerySnapshot querySnapshot = await collectionReferenceUsuarios
      .where("Expediente", isEqualTo: expediente)
      .get();

  if (querySnapshot.size > 0) {
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    return documentSnapshot.get("Contraseña");
  } else {
    return "notfound";
  }
}

Future<List<FeedItem>> getRecentPosts() async {
  List<FeedItem> posts = [];
  CollectionReference collectionReferencePosts = db.collection("Posts");

  QuerySnapshot querySnapshot = await collectionReferencePosts
      .orderBy("date", descending: true)
      .limit(10)
      .get();

  for (var doc in querySnapshot.docs) {
    Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
    User author = await getUserByExpediente(
        postData["author"]); // assume getUserByExpediente function exists
    FeedItem post = FeedItem(
      content: postData["content"],
      imageUrl: postData["imageUrl"],
      user: author,
      commentsCount: postData["commentsCount"] ?? 0,
      likesCount: postData["likesCount"] ?? 0,
      retweetsCount: postData["retweetsCount"] ?? 0,
      postId: doc.id,
    );
    posts.add(post);
  }

  return posts;
}

Future<String> addPost(
    String title, String content, int authorExpediente) async {
  CollectionReference collectionReferencePosts = db.collection("Posts");
  String postId = collectionReferencePosts.doc().id;
  DateTime now = DateTime.now();

  await collectionReferencePosts.doc(postId).set({
    "id": postId,
    "title": title,
    "content": content,
    "author": authorExpediente,
    "date": now,
  });

  return postId; // return the post ID
}

Future<FeedItem?> getPostById(String postId) async {
  CollectionReference collectionReferencePosts = db.collection("Posts");
  DocumentSnapshot documentSnapshot =
      await collectionReferencePosts.doc(postId).get();

  if (documentSnapshot.exists) {
    Map<String, dynamic> postData =
        documentSnapshot.data()! as Map<String, dynamic>;
    User author = await getUserByExpediente(
        postData["author"]); // assume getUserByExpediente function exists
    return FeedItem(
      content: postData["content"],
      imageUrl: postData["imageUrl"],
      user: author,
      commentsCount: postData["commentsCount"] as int? ?? 0,
      likesCount: postData["likesCount"] as int? ?? 0,
      retweetsCount: postData["retweetsCount"] as int? ?? 0,
      postId: postId,
    );
  } else {
    return null;
  }
}

Future<User> getUserByExpediente(int expediente) async {
  CollectionReference collectionReferenceUsuarios = db.collection("Usuarios");
  QuerySnapshot querySnapshot = await collectionReferenceUsuarios
      .where("Expediente", isEqualTo: expediente)
      .get();

  if (querySnapshot.size > 0) {
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    return User(
      fullName: documentSnapshot.get("Nombre"),
      imageUrl: documentSnapshot.get("Imagen"),
      userName: documentSnapshot.get("Usuario"),
    );
  } else {
    return User(fullName: "", imageUrl: "", userName: "");
  }
}

class User {
  final String fullName;
  final String imageUrl;
  final String userName;

  User(
      {required this.fullName, required this.imageUrl, required this.userName});
}
