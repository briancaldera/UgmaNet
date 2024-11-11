import 'package:UgmaNet/services/firebase_service.dart';
import 'package:UgmaNet/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewsFeedPage1 extends StatefulWidget {
  const NewsFeedPage1({
    super.key,
  });

  @override
  State<NewsFeedPage1> createState() => _NewsFeedPage1State();
}

class _NewsFeedPage1State extends State<NewsFeedPage1> {
  List<FeedItem> _feedItems = [];
  User? user;

  @override
  void initState() {
    super.initState();
    cargarFeed();
  }

  void cargarFeed() async {
    try {
      List<FeedItem> data = [];
      data = await getFeedItems();
      setState(() {
        _feedItems = List.from(data);
      });
    } catch (e) {
      print('Error al Cargar: $e');
    }
  }

  Future<void> _refreshFeed() async {
    cargarFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //------------------------------AppBar----------------------------------//
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network("https://i.postimg.cc/3JN8kNY2/minilogo.png"),
              const SizedBox(width: 16),
              Text(
                'UGMANET',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color.fromARGB(206, 36, 55, 165),
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
            ],
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              color: Colors.grey, // change the color as per your requirement
              height: 1.0,
            ),
          ),
        ),
      ),

      //--------------------------------Appbar----------------------------------//

      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.separated(
            itemCount: _feedItems.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final item = _feedItems[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarImage(item.user.imageUrl),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(children: [
                                  TextSpan(
                                    //------------------Nombre----------------//
                                    text: "${item.user.fullName} - ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                  TextSpan(
                                    //-----------------Tipo-------------------//
                                    text: item.user.tipo,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ]),
                              )),

                              //Agregar el tiempo transcurrido
                              //todo
                              Text('· 5m',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.more_horiz),
                              )
                            ],
                          ),

                          //------------Post Contenido-----------------//
                          if (item.content != null) Text(item.content!),
                          if (item.imageUrl != null || item.imageUrl != '')
                            Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(item.imageUrl!),
                                  )),
                            ),
                          _ActionsRow(item: item)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      //-------------------------------BottomBar------------------------------//
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Oficial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Foro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_rows),
            label: 'Mas',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            // Funcion de añadir
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return const UploadNew();
              },
            );
          }

          if (index == 4) {
            // Show the bottom sheet when the user taps on the profile tab
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return const MoreBottomSheet();
              },
            );
          }
        },
      ),
      //-------------------------------BottomBar------------------------------//
    );
  }
}

//-----------------------------Funciones y clases-----------------------------//

class _AvatarImage extends StatelessWidget {
  final String url;
  const _AvatarImage(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url))),
    );
  }
}

// ------------------------Panel de iconos------------------------------------//

class _ActionsRow extends StatefulWidget {
  final FeedItem item;
  const _ActionsRow({required this.item});

  @override
  State<_ActionsRow> createState() => _ActionsRowState();
}

class _ActionsRowState extends State<_ActionsRow> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.grey, size: 18),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.grey),
          ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mode_comment_outlined),
            label: Text(
                widget.item.commentsCount == 0 ? '' : widget.item.commentsCount.toString()),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.repeat_rounded),
            label: Text(
                widget.item.retweetsCount == 0 ? '' : widget.item.retweetsCount.toString()),
          ),
          likeButton(
            isLiked: _isLiked,
            onTap: () {
              setState((){
                _isLiked = !_isLiked;
              });
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.share_up),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

//----------------------Importacion de la lista de posts----------------------

class likeButton extends StatelessWidget {
  bool isLiked;
  void Function()? onTap;

  likeButton({super.key, required this.isLiked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked? Icons.favorite: Icons.favorite_border,
        color: isLiked? Colors.red : Colors.grey),
    );
  }
}

class MoreBottomSheet extends StatefulWidget {
  const MoreBottomSheet({super.key});

  @override
  State<MoreBottomSheet> createState() => _MoreBottomSheetState();
}

class _MoreBottomSheetState extends State<MoreBottomSheet> {
  User user = User(
      fullName: "Default",
      imageUrl: "https://picsum.photos/id/1062/80/80",
      tipo: "estudiante");

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  void cargarUsuario() async {
    try {
      User usuarioActual = await getUserByExpediente(expedienteGlobal);
      setState(() {
        user = usuarioActual;
      });
    } catch (e) {
      print('Error al Cargar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white30, // Set the background color to gray
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundImage: NetworkImage(user.imageUrl),
              ),
              const SizedBox(width: 16.0),
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(), // Add a Spacer to push the "more" button to the right
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) {
                  return _moreItems
                      .map<PopupMenuEntry<String>>((String option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList();
                },
                onSelected: (String selectedOption) {
                  // Handle the selected option
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _moreItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.more_horiz),
                  title: Text(_moreItems[index]),
                  onTap: () {
                    // Handle item tap
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final List<String> _moreItems = [
  'Configuración',
  'Guardado',
  'Ayuda',
  'Cerrar sesion',
];
/*
class UploadNew extends StatefulWidget {
  const UploadNew({super.key});

  @override
  State<UploadNew> createState() => _UploadNew();
}

class _UploadNew extends State<UploadNew> {
  User user = User(
      fullName: "Default",
      imageUrl: "https://picsum.photos/id/1062/80/80",
      tipo: "estudiante");

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  void cargarUsuario() async {
    try {
      User usuarioActual = await getUserByExpediente(expedienteGlobal);
      setState(() {
        user = usuarioActual;
      });
    } catch (e) {
      print('Error al Cargar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {}
}
*/

class UploadNew extends StatefulWidget {
  const UploadNew({super.key});

  @override
  State<UploadNew> createState() => _UploadNewState();
}

class _UploadNewState extends State<UploadNew> {
  late TextEditingController _contentController;
  String? _imageUrl;
  int userId = expedienteGlobal;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() async {
    String content = _contentController.text.trim();
    if (content.isNotEmpty || _imageUrl != null) {
      await saveNewPost(content, _imageUrl, userId);
      // Clear the form after submission
      setState(() {
        _contentController.clear();
        _imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload a new post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPost,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
