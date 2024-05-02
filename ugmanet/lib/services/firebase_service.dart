import "package:cloud_firestore/cloud_firestore.dart";

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

Future<List> getRecentPosts() async {
  List posts = [];
  CollectionReference collectionReferencePosts = db.collection("Posts");

  QuerySnapshot querySnapshot = await collectionReferencePosts
      .orderBy("date", descending: true)
      .limit(10)
      .get();

  for (var doc in querySnapshot.docs) {
    posts.add(doc.data());
  }

  return posts;
}

Future<void> addPost(String title, String content, int authorExpediente) async {
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
}
