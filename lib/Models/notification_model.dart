class NotificationModel {
  late String id;
  late String senderId;
  late String receiverId;
  late String image;
  late String page;
  late String type;
  late String title;
  late String message;
  late String sendAt;
  late bool isRead;

  NotificationModel(
      {required this.senderId,
      required this.id,
      required this.receiverId,
        required this.title,
        required this.page,
        required this.type,
        required this.image,
      required this.message,
      required this.sendAt,
      this.isRead = false});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    senderId = json['senderId'] ?? '';
    receiverId = json['receiverId'] ?? '';
    page = json['page'] ?? '';
    type = json['type'] ?? '';
    image = json['image'] ?? '';
    title = json['title'] ?? '';
    message = json['message'] ?? '';
    sendAt = json['sendAt'] ?? '';
    isRead = json['isRead'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic> {};
    data['id'] = id;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['page'] = page;
    data['type'] = type;
    data['image'] = image;
    data['title'] = title;
    data['message'] = message;
    data['sendAt'] = sendAt;
    data['isRead'] = isRead;
    return data;
  }
}
