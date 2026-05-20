import 'dart:convert';

class PostModel {
  final String id;
  final String username;
  final String profileImageUrl;
  final String location;
  final String caption;
  final String imageUrl;
  final int likes;
  final int comments;
  final bool isLiked;
  final String timestamp;
  final bool hideLikes;
  final bool hideViews;
  final bool allowComments;
  final bool postSharing;
  final String allowLikeViewFrom;

  PostModel({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.location,
    required this.caption,
    required this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    required this.timestamp,
    this.hideLikes = false,
    this.hideViews = false,
    this.allowComments = true,
    this.postSharing = true,
    this.allowLikeViewFrom = 'Everyone',
  });

  PostModel copyWith({
    String? id,
    String? username,
    String? profileImageUrl,
    String? location,
    String? caption,
    String? imageUrl,
    int? likes,
    int? comments,
    bool? isLiked,
    String? timestamp,
    bool? hideLikes,
    bool? hideViews,
    bool? allowComments,
    bool? postSharing,
    String? allowLikeViewFrom,
  }) {
    return PostModel(
      id: id ?? this.id,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      location: location ?? this.location,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      timestamp: timestamp ?? this.timestamp,
      hideLikes: hideLikes ?? this.hideLikes,
      hideViews: hideViews ?? this.hideViews,
      allowComments: allowComments ?? this.allowComments,
      postSharing: postSharing ?? this.postSharing,
      allowLikeViewFrom: allowLikeViewFrom ?? this.allowLikeViewFrom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'caption': caption,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked ? 1 : 0, // Store bool as int or bool
      'timestamp': timestamp,
      'hideLikes': hideLikes ? 1 : 0,
      'hideViews': hideViews ? 1 : 0,
      'allowComments': allowComments ? 1 : 0,
      'postSharing': postSharing ? 1 : 0,
      'allowLikeViewFrom': allowLikeViewFrom,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      location: map['location'] ?? '',
      caption: map['caption'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      isLiked: map['isLiked'] == 1 || map['isLiked'] == true,
      timestamp: map['timestamp'] ?? '',
      hideLikes: map['hideLikes'] == 1 || map['hideLikes'] == true,
      hideViews: map['hideViews'] == 1 || map['hideViews'] == true,
      allowComments: map['allowComments'] == 1 || map['allowComments'] == true,
      postSharing: map['postSharing'] == 1 || map['postSharing'] == true,
      allowLikeViewFrom: map['allowLikeViewFrom'] ?? 'Everyone',
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source));
}
