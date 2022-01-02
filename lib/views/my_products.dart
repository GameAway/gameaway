import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gameaway/services/db.dart';
import 'package:gameaway/services/util.dart';
import 'package:gameaway/views/product_preview.dart';
import 'package:provider/provider.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({Key? key}) : super(key: key);

  @override
  _MyProductsState createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  Future<List<Product>> getProducts() async {
    DBService db = DBService();
    var sellerRef =
        DBService.userCollection.doc(Provider.of<User?>(context)!.uid);
    var productsDocs =
        (await db.productCollection.where("seller", isEqualTo: sellerRef).get())
            .docs;
    List<Product> productsList = <Product>[];
    for (var i = 0; i < productsDocs.length; i++) {
      var currentProductDoc = productsDocs[i];
      DocumentReference sellerRef = currentProductDoc.get("seller");
      String sellerName = (await sellerRef.get()).get("name");
      var currentProduct = Product(
          pid: currentProductDoc.id,
          stocks: currentProductDoc.get("stocks"),
          url: currentProductDoc.get("picture"),
          productName: currentProductDoc.get("name"),
          rating: Util.avg(currentProductDoc.get("rating")),
          price: currentProductDoc.get("price"),
          seller: sellerName,
          category: currentProductDoc.get("category"),
          tag: currentProductDoc.get("tag"));
      productsList.add(currentProduct);
    }
    return productsList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProducts(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Text("Loading...");
          } else if (snapshot.data.isEmpty) {
            return const Center(
                child:
                    Text("You are not selling any products. Try adding some!"));
          }
          List<Product> productsList = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: .6,
                crossAxisCount: 2,
                children: List.generate(
                    productsList.length,
                    (index) => ProductPreview(
                        editable: true, product: productsList[index]))),
          );
        });
  }
}
