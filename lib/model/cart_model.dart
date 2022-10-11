class CartModel {
  String id;
  String menuId;
  String menuName;
  String standId;
  String standName;
  int total;
  String imageUrl;

  CartModel({required this.id, required this.menuId, required this.menuName, required this.standId, required this.standName, required this.total, required this.imageUrl});
}