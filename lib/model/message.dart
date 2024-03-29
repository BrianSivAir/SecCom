class Message {
  String content;
  int duration;
  bool isMine;

  Message({
    required this.content,
    required this.duration,
    this.isMine = false,
  });

  Map toJson() => {
    'content': content,
    'duration': duration,
    'isMine': isMine,
  };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      duration: json['duration'] as int,
      isMine: json['isMine'] as bool,
    );
  }
}
