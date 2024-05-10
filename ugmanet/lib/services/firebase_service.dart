import "package:cloud_firestore/cloud_firestore.dart";

FirebaseFirestore db = FirebaseFirestore.instance;

//Devuelve en una lista todos los usuarios, dudo que sirva de algo
Future<List> getUsuarios() async {
  List usuarios = [];
  CollectionReference collectionReferenceUsuarios = db.collection("Usuarios");

  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.get();

  for (var doc in queryUsuarios.docs) {
    usuarios.add(doc.data());
  }

  return usuarios;
}

//Devuelve la contraseña asociada al expediente que se le de
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
      tipo: documentSnapshot.get("Tipo"),
    );
  } else {
    return User(fullName: "", imageUrl: "", tipo: "");
  }
}

Future<List<FeedItem>> getFeedItems() async {
  CollectionReference collectionReferenceFeed = db.collection("Feed");
  QuerySnapshot querySnapshot = await collectionReferenceFeed.get();

  List<FeedItem> feedItems = [];

  for (var doc in querySnapshot.docs) {
    User user = await getUserByExpediente(doc.get("User"));
    DateTime postDate = doc.get("PostDate").toDate();
    String? content = doc.get("Content");
    String? imageUrl = doc.get("ImageUrl");

    feedItems.add(FeedItem(
      content: content ?? "", // Use empty string if content is null
      imageUrl: imageUrl ?? "", // Use empty string if imageUrl is null
      user: user,
      commentsCount:
          doc.get("CommentsCount") ?? 0, // Use 0 if commentsCount is null
      likesCount: doc.get("LikesCount") ?? 0, // Use 0 if likesCount is null
      retweetsCount:
          doc.get("RetweetsCount") ?? 0, // Use 0 if retweetsCount is null
      postDate: postDate,
    ));
  }

  feedItems.sort((a, b) => b.postDate.compareTo(a.postDate));

  return feedItems;
}

Future<void> saveNewPost(String? content, String? imageUrl, int userId) async {
  // Get a reference to the "Feed" collection in Firebase Firestore
  CollectionReference collectionReferenceFeed = db.collection("Feed");

  // Create a new document in the "Feed" collection with a random ID
  DocumentReference documentReference = await collectionReferenceFeed.add({
    "Content": content,
    "ImageUrl": imageUrl,
    "User": userId,
    "PostDate": Timestamp.now(),
    "CommentsCount": 0,
    "LikesCount": 0,
    "RetweetsCount": 0,
  });

  // Get the ID of the new document
  String documentId = documentReference.id;

  // Update the document with the generated ID
  await documentReference.update({
    "ID": documentId,
  });
}

class User {
  final String fullName;
  final String imageUrl;
  final String tipo;

  User({required this.fullName, required this.imageUrl, required this.tipo});
}

class FeedItem {
  final String? content;
  final String? imageUrl;
  final User user;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;
  final DateTime postDate;

  FeedItem({
    this.content,
    this.imageUrl,
    required this.user,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.retweetsCount = 0,
    required this.postDate,
  });
}
