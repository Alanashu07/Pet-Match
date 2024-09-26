
class Accessory {
  String? id;
  late String name;
  late double price;
  late double quantity;
  late String brand;
  late String category;
  late String description;
  late String createdAt;
  late List<String> images;

  Accessory(
      {required this.name,
        required this.price,
        this.id,
        required this.quantity,
        required this.brand,
        required this.category,
        required this.description,
        required this.createdAt,
        required this.images});

  Accessory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
    brand = json['brand'];
    category = json['category'];
    description = json['description'];
    createdAt = json['createdAt'];
    images = List.castFrom(json['images']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic> {};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    data['brand'] = brand;
    data['category'] = category;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['images'] = images;
    return data;
  }
}
