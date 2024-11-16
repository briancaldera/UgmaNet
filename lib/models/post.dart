class Post {
  final String id;
  final String authorID;
  final String content;
  final List<String> images;
  final int likesCount;
  final DateTime createdAt;
  final bool isLikedByUser;

  Post(this.authorID, this.content, this.images, this.likesCount,
      this.createdAt, this.id, this.isLikedByUser);
}
