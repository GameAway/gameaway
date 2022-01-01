import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gameaway/pages/seller_page.dart';
import 'package:gameaway/services/db.dart';
import 'package:gameaway/utils/dimensions.dart';
import 'package:gameaway/utils/styles.dart';
import 'package:gameaway/views/action_bar.dart';
import 'package:gameaway/views/category_tag_selection.dart';
import 'package:gameaway/views/product_preview.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  DBService db = DBService();
  List<Product>? _products;
  List<Product>? _promotions;
  List<Product>? _recommendations;

  Future<void> getProducts() async {
    var r = await db.productCollection.get();
    var _productsTemp = r.docs
        .map<Product>((doc) => Product(
            price: doc['price'],
            productName: doc['name'],
            category: doc['category'],
            tag: doc['tag'],
            seller: "Unknown Seller",
            url: doc['picture'],
            rating: doc['rating']))
        .toList();
    for (var i = 0; i < r.docs.length; i++) {
      var r2 = await r.docs[i]["seller"].get();
      if (r2.data() != null) _productsTemp[i].seller = r2.data()["name"];
    }
    setState(() {
      _products = _productsTemp;
      _promotions = _products?.where((p) => (p.price < 100)).toList();
      _recommendations = _products?.where((p) => (p.rating >= 4.5)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ActionBar(),
      body: _products == null
          ? const Text("Loading..")
          : SingleChildScrollView(
              child: Column(
                children: [
                  OutlinedButton.icon(
                      onPressed: () {
                        // Navigator.pushNamed(
                        //     context, "homepage/explore");
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SellerPage(
                                sellerID: "ZDgxpoysU8aFPC3y5doCdFXLBwS2")));
                      },
                      icon: const Icon(Icons.search),
                      label: const Text("Explore Products")),
                  Text(
                    "Promotions",
                    style: kHeadingTextStyle,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: Dimen.regularPadding,
                      child: Row(
                        children: List.generate(
                            _promotions!.length,
                            (index) => Row(children: [
                                  productPreview(_promotions![index]),
                                  const SizedBox(width: 8)
                                ])),
                      ),
                    ),
                  ),
                  Text(
                    "Recommendations",
                    style: kHeadingTextStyle,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: Dimen.regularPadding,
                      child: Row(
                        children: List.generate(
                            _recommendations!.length,
                            (index) => Row(children: [
                                  productPreview(_recommendations![index]),
                                  const SizedBox(width: 8)
                                ])),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
