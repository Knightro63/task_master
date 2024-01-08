class UserData {
  UserData({
    required this.uid,
    required this.displayName,
    this.imageUrl,
    this.credentials
  });

  /// UID of the user
  final String uid;

  /// Name of the user to display
  final String displayName;

  /// URL to profile picture of user
  final String? imageUrl;

  /// Used to optionally implement user credentials and authenication
  final String? credentials;

  /// Used to convert JSON data to UserData object
  factory UserData.fromJSON(Map<String, dynamic> data, String uid) {
    return UserData(
      uid: uid,
      displayName: data['displayName'] ?? '',
      imageUrl: data['imageURL'] as String?,
      credentials: data['credentials'] as String?
    );
  }

  /// Used to convert UserData object to JSON data
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'imageUrl': imageUrl,
      'credentials': credentials
    };
  }
}
