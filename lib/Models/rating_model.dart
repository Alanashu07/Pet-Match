class RatingModel {
  late double rating;
  late String description;
  late String time;
  late String userId;
  late String? id;

  RatingModel({required this.rating, required this.description, required this.userId, required this.time, this.id});

  RatingModel.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    description = json['description'];
    time = json['time'];
    userId = json['userId'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rating'] = rating;
    data['description'] = description;
    data['time'] = time;
    data['userId'] = userId;
    data['id'] = id;
    return data;
  }
}