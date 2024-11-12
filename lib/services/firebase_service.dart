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
  final CollectionReference collectionReferenceFeed = db.collection("Feed");
  final QuerySnapshot querySnapshot = await collectionReferenceFeed.get();

  final List<FeedItem> feedItems = await _processQuerySnapshot(querySnapshot);

  feedItems.sort((a, b) => b.postDate.compareTo(a.postDate));

  return feedItems;
}

Future<List<FeedItem>> _processQuerySnapshot(
    QuerySnapshot querySnapshot) async {
  final List<FeedItem> feedItems = [];

  for (var doc in querySnapshot.docs) {
    final User user = await getUserByExpediente(doc.get("User"));
    final DateTime postDate = doc.get("postDate").toDate();

    final String content =
        doc.get("Content") ?? ""; // Use empty string if content is null
    final String imageUrl =
        doc.get("ImageUrl") ?? ""; // Use empty string if imageUrl is null

    feedItems.add(FeedItem(
      content: content,
      imageUrl: imageUrl,
      user: user,
      commentsCount: doc.get("commentsCount") ?? 0,
      likesCount: doc.get("likesCount") ?? 0,
      retweetsCount: doc.get("retweetsCount") ?? 0,
      postDate: postDate,
    ));
  }

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
    "postDate": Timestamp.now(),
    "commentsCount": 0,
    "likesCount": 0,
    "retweetsCount": 0,
  });

  // Get the ID of the new document
  String documentId = documentReference.id;

  // Update the document with the generated ID
  await documentReference.update({
    "ID": documentId,
  });
}

Future<void> registerUserDB(
  int expediente,
  String nombre,
  String imagen,
  String contrasenia,
  String tipo,
) async {
  try {
    // Create a new user account with Firebase Authentication
    CollectionReference collectionReferenceFeed = db.collection("Usuarios");

    // Add the user's information to Firestore
    DocumentReference documentReference = await collectionReferenceFeed.add({
      'Expediente': expediente,
      'Nombre': nombre,
      'Imagen': imagen,
      'Contraseña': contrasenia,
      'Tipo': tipo,
    });
    String documentId = documentReference.id;
    await documentReference.update({
      "ID": documentId,
    });
  } catch (e) {
    // Handle errors during registration
    print(e);
  }
}

class User {
  final String fullName;
  final String? imageUrl;
  final String tipo;

  User({required this.fullName, this.imageUrl, required this.tipo});
}

class FeedItem {
  final String? content;
  final String? imageUrl;
  final User user;
  final int commentsCount;
  int likesCount;
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
