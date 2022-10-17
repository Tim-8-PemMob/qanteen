class OrderModel {
  String id;
  String namaMenu;
  int totalPesan;
  int hargaMenu;
  String userUid;
  String namaPemesan;
  String status;

  OrderModel({required this.id, required this.namaMenu, required this.totalPesan, required this.hargaMenu, required this.userUid, required this.namaPemesan, required this.status});

}