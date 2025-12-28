class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  factory CategoryModel.fromMap(Map<String, dynamic> map) => 
      CategoryModel(id: map['id'], name: map['name']);
}
