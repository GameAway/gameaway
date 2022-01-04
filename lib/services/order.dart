import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  String url;
  String productName;
  String pid;
  num price;
  Timestamp purchaseDate;

  Order(
      {required this.url,
      required this.productName,
      required this.pid,
      required this.price,
      required this.purchaseDate});
}