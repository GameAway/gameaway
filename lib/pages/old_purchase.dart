import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gameaway/services/order.dart';
import 'package:gameaway/utils/colors.dart';
import 'package:gameaway/utils/dimensions.dart';
import 'package:gameaway/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:gameaway/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gameaway/services/db.dart';
import 'package:gameaway/views/action_bar.dart';
import 'package:gameaway/views/action_bar.dart';
import 'package:gameaway/views/product_preview.dart';

class OldPurchase extends StatefulWidget {
  const OldPurchase({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  _OldPurchaseState createState() => _OldPurchaseState();
}

class _OldPurchaseState extends State<OldPurchase> {
  Future<List<Order>> getOrders() async {
    List<Order> orders = <Order>[];
    var buyerRef = DBService.userCollection.doc(widget.uid);
    var o = await DBService.ordersCollection
        .where("buyer", isEqualTo: buyerRef)
        .get();
    for (var element in o.docs) {
      DocumentReference currentProduct = element.get("product");
      String currentProductName = (await currentProduct.get()).get("name");
      num currentProductPrice = (await currentProduct.get()).get("price");
      String currentProductPicture =
          (await currentProduct.get()).get("picture");
      String currentPid = currentProduct.id;
      orders.add(Order(
          url: currentProductPicture,
          productName: currentProductName,
          pid: currentPid,
          price: currentProductPrice,
          purchaseDate: element.get("purchaseDate")));
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ActionBar(title: "Old Purchases"),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        FutureBuilder(
            future: getOrders(),
            builder: (context, AsyncSnapshot asyncSnapshot) {
              if (!asyncSnapshot.hasData) return const Text("Loading...");
              List<Order> orders = asyncSnapshot.data;
              return Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    if (orders != null) {
                      return Padding(
                        padding: Dimen.listPadding,
                        child: Card(
                          color: AppColors.captionColor,
                          child: ListTile(
                            onTap: () {},
                            title: Column(
                              children: [
                                Text(
                                  orders[index].productName,
                                  style: const TextStyle(
                                      color: AppColors.notification,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            leading:
                                Image.network(orders[index].url),
                            trailing:
                                Text('\$ ${orders[index].price}'),
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text("no purchase has been made"));
                    }
                  },
                ),
              );
            }),
      ]),
    );
  }
}