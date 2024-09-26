
class Message{
  late String id;
  late String sender;
  late String receiver;
  late String text;
  late String sentAt;
  late String readAt;
  late String type;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.sentAt,
    required this.readAt,
    required this.type,
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender = json['sender'];
    receiver = json['receiver'];
    text = json['text'];
    sentAt = json['sentAt'];
    readAt = json['readAt'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['text'] = text;
    data['sentAt'] = sentAt;
    data['readAt'] = readAt;
    data['type'] = type;
    return data;
  }

}