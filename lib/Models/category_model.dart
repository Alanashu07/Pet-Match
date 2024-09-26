class CategoryModel {
  late String? id;
  late String name;
  late String image;
  late String emptyImage;
  late int colorIndex;
  late bool isPet;

  CategoryModel(
      {required this.name,
        this.id,
        required this.image,
        required this.emptyImage,
        required this.colorIndex,
        this.isPet = true});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    image = json['image'] ?? '';
    emptyImage = json['emptyImage'] ?? '';
    colorIndex = json['colorIndex'] ?? 0;
    isPet = json['isPet'] ?? true;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['emptyImage'] = emptyImage;
    data['colorIndex'] = colorIndex;
    data['isPet'] = isPet;
    return data;
  }
}
