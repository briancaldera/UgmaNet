import 'package:UgmaNet/models/post.dart';
import 'package:UgmaNet/models/profile.dart';
import 'package:UgmaNet/services/post_service.dart';
import 'package:UgmaNet/services/user_service.dart';
import 'package:UgmaNet/visual/Screens/post.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NewsFeedTab extends StatefulWidget {
  const NewsFeedTab({
    super.key,
  });

  @override
  State createState() => _NewsFeedTabState();
}

class _NewsFeedTabState extends State<NewsFeedTab> {
  List<Post> _feedItems = List<Post>.empty();
  final PostService _postService = PostServiceImpl.instance;
  final UserService _userService = UserServiceImpl.instance;

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: RefreshIndicator(
      onRefresh: _refreshFeed,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute<CreatePostScreen>(
                          builder: (context) => const CreatePostScreen()))
                  .then((_) => setState(() {}));
            }),
        body: ListView.builder(
          itemCount: _feedItems.length,
          semanticChildCount: _feedItems.length,
          itemBuilder: (BuildContext context, index) {
            return NewsFeedItem(_feedItems[index]);
          },
        ),
      ),
    ));
  }

  Future<void> _refreshFeed() async {
    final user = _userService.user;
    final posts = await _postService.getPosts(userID: user?.uid);

    setState(() {
      _feedItems = posts;
    });
  }
}

class NewsFeedItem extends StatefulWidget {
  final Post post;

  const NewsFeedItem(this.post, {super.key});

  @override
  State createState() => _NewsFeedItemState();
}

class _NewsFeedItemState extends State<NewsFeedItem> {
  late Post _post;
  final UserService _userService = UserServiceImpl.instance;
  final PostService _postService = PostServiceImpl.instance;
  bool _isLikedByUser = false;
  int _likesCount = 0;

  Profile? _profile;

  @override
  void initState() {
    super.initState();

    _post = widget.post;
    _isLikedByUser = _post.isLikedByUser;
    _likesCount = _post.likesCount;

    _userService.getProfile(_post.authorID).then((profile) => setState(() {
          _profile = profile;
        }));
  }

  @override
  Widget build(BuildContext context) {

    final profile = _profile;

    dynamic bgImage = profile?.pictureUrl != null ? NetworkImage(profile!.pictureUrl!) : const AssetImage(
      'assets/images/user-placeholder.jpg');

    final userPicture = CircleAvatar(
      radius: 24,
      backgroundImage: bgImage,
    );

    final header = Row(
      textBaseline: TextBaseline.alphabetic,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(
            overflow: TextOverflow.ellipsis,
            _profile != null
                ? '${_profile?.firstName} ${_profile?.lastName}'
                : 'FirstName LastName',
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '@${_profile?.username}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
              maxLines: 1,
            ),
          ),
        ),
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
                GetTimeAgo.parse(_post.createdAt, locale: 'es'),
                maxLines: 1,
              ),
            ))
      ],
    );
    final textContent = Text(_post.content);

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, textContent],
    );

    var main = Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userPicture,
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: text,
          ))
        ],
      ),
    );

    var actions = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(
              _likesCount.toString(),
              style: const TextStyle(fontSize: 10),
            ),
            IconButton(
                onPressed: () async {
                  final user = _userService.user;
                  if (user != null) {
                    if (_isLikedByUser) {
                      final res = _postService.unlikePost(_post.id, user.uid);
                      if (await res) {
                        setState(() {
                          _isLikedByUser = false;
                          --_likesCount;
                        });
                      }
                    } else {
                      final res = _postService.likePost(_post.id, user.uid);
                      if (await res) {
                        setState(() {
                          _isLikedByUser = true;
                          ++_likesCount;
                        });
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Debe iniciar sesión')));
                  }
                },
                icon: _isLikedByUser
                    ? const Icon(
                        Icons.favorite_rounded,
                        color: Colors.pink,
                      )
                    : const Icon(
                        Icons.favorite_outline_outlined,
                      ))
          ],
        )
      ],
    );

    final imageSection = ImagePreview(widget.post.images);

    final children = [main,  imageSection, actions];
    // if (widget.post.images.isNotEmpty) children.add(Expanded(flex: 1, child: ));

    return Skeletonizer(
        enabled: _profile == null,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 10),
          child: Column(
            children: children,
          ),
        ));
  }

  _NewsFeedItemState();
}

class ImagePreview extends StatelessWidget {
  final List<String> _imagesUrl;

  const ImagePreview(this._imagesUrl, {super.key});

  @override
  Widget build(BuildContext context) {

    final children = _imagesUrl.map((url) => Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: Image.network(url)
    ));

    return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: _imagesUrl.length > 1 ? 2 : 1,
        children: children.toList()
    );
  }
}
