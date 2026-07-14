class Category {
  final int id;
  final String name;
  final String color;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#1D8763',
      icon: json['icon'] ?? 'ti-cash',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
        'icon': icon,
      };
}
