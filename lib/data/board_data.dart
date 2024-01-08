class BoardData {
  BoardData({
    required this.title,
    required this.dateCreated,
    required this.createdBy,
    required this.id,
    this.priority,
    required this.color,
    this.notify = false
  });

  /// Title of board
  String title;

  /// Date board created
  final String dateCreated;

  /// User (UID) that created the board
  final String createdBy;

  /// Board ID
  final String id;

  /// Board priority used for board ordering
  int? priority;

  /// Board Color used for board title text
  final int? color;

  /// Boolean used to optionally implement board notifications
  final bool notify;

  /// Convert JSON data string to boardData object
  factory BoardData.fromJSON(Map<String, dynamic> data, key, int color) {
    //print(data);
    return BoardData(
      title: data['title'] ?? '',
      dateCreated: data['dateCreated'] ?? '',
      createdBy: data['createdBy'] ?? '',
      id: key,
      priority: data['priority'] as int?,
      color: color,
      notify: data['notify'] ?? false
    );
  }

  /// Convert boardData object to JSON data string
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'title': title,
      'dateCreated': dateCreated,
      'createdBy': createdBy,
      'id': id,
      'priority': priority,
      'color': color,
      'notify': notify
    };
  }
}
