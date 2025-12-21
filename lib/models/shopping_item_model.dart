class ShoppingItem {
  final String id;
  final String name;
  final bool isBought;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isBought = false,
  });
}
