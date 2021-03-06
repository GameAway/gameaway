import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gameaway/services/db.dart';
import 'package:gameaway/services/util.dart';
import 'package:gameaway/utils/colors.dart';
import 'package:gameaway/views/product_grid.dart';
import 'package:gameaway/views/product_preview.dart';

import 'loading_indicator.dart';

class CategoryTagSelection extends StatefulWidget {
  const CategoryTagSelection({Key? key}) : super(key: key);

  @override
  _CategoryTagSelectionState createState() => _CategoryTagSelectionState();
}

class _CategoryTagSelectionState extends State<CategoryTagSelection> {
  //Categories
  static final _categories = Util.categories;
  static int _currentCategory = 0;

  //Sort
  static String _sortType = "name";
  static final _sortTypeItemsString = Util.sortTypes;
  static final _sortTypeItems =
      _sortTypeItemsString.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();
  static bool _ascending = true;

  //DropDown
  static String _dropdownValue = 'All';
  static final _dropdownItemsString = Util.tags;
  static final _dropdownItems = _dropdownItemsString
      .map((e) => e.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList())
      .toList();
  DBService db = DBService();
  List<Product>? _products;
  List<Product>? _resultList;

  Future<void> getProducts() async {
    var r = await DBService.productCollection.get();
    var _productsTemp = r.docs.map<Product>((doc) {
      double productRating = Util.avg(doc['rating']);
      return Product(
          stocks: doc['stocks'],
          pid: doc.id,
          price: doc['price'],
          oldPrice: doc['oldPrice'],
          productName: doc['name'],
          category: doc['category'],
          tag: doc['tag'],
          seller: "Anonymous Seller",
          url: doc['picture'],
          rating: productRating,
          desc: doc["desc"]);
    }).toList();
    for (var i = 0; i < r.docs.length; i++) {
      var r2 = await r.docs[i]["seller"].get();
      if (r2.data() != null) _productsTemp[i].seller = r2.data()["name"];
    }
    setState(() {
      _products = _productsTemp;
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    if (_products == null) return const LoadingIndicator();
    _resultList = _products
        ?.where((p) =>
            p.category == _categories[_currentCategory] &&
            (_dropdownValue == "All" || p.tag == _dropdownValue))
        .toList();
    _resultList!.sort(Util.sortFuncs[_sortType]![_ascending]);
    return Column(
      children: [
        Column(children: [
          OutlinedButton.icon(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: DataSearch(
                      products: _products!,
                    ));
              },
              label: const Text("Search Anything"),
              icon: const Icon(Icons.search)),
        ]),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(_categories.length, (int index) {
              return OutlinedButton(
                style: ButtonStyle(backgroundColor:
                    MaterialStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppColors.background.withOpacity(.5);
                  } else if (_currentCategory == index) {
                    return AppColors.background;
                  } else {
                    return null;
                  }
                }), foregroundColor:
                    MaterialStateProperty.resolveWith<Color?>((states) {
                  return (_currentCategory == index)
                      ? AppColors.DarkTextColor
                      : AppColors.LightTextColor;
                })),
                onPressed: () {
                  setState(() {
                    _currentCategory = index;
                    _dropdownValue = _dropdownItemsString[_currentCategory][0];
                  });
                },
                child: Container(
                  height: 50.0,
                  child: Text(_categories[index]),
                ),
              );
            }),
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.headingColor.withAlpha(50),
                  ),
                  width: 150,
                  child: DropdownButton(
                    isExpanded: true,
                    dropdownColor: AppColors.headingColor.withAlpha(250),
                    items: _dropdownItems[_currentCategory],
                    value: _dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _dropdownValue = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.headingColor.withAlpha(50),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    dropdownColor: AppColors.headingColor.withAlpha(250),
                    items: _sortTypeItems,
                    value: _sortType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _sortType = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    _ascending = !_ascending;
                  });
                },
                icon: _ascending
                    ? const Icon(Icons.arrow_upward)
                    : const Icon(Icons.arrow_downward)),
          ],
        ),
        ProductGrid(list: _resultList!)
      ],
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final List<Product> products;

  DataSearch({required this.products});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, '');
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    String lowerQuery = query.toLowerCase();
    final resultList = products
        .where((p) =>
            p.productName.toLowerCase().contains(lowerQuery) ||
            p.desc.toLowerCase().contains(lowerQuery))
        .toList();
    return SingleChildScrollView(child: ProductGrid(list: resultList));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    String lowerQuery = query.toLowerCase();
    final suggestionList = products
        .where((p) => p.productName.toLowerCase().contains(lowerQuery))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
        },
        title: RichText(
            text: TextSpan(
                text: suggestionList[index]
                    .productName
                    .substring(0, query.length),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                children: [
              TextSpan(
                  text:
                      suggestionList[index].productName.substring(query.length),
                  style: TextStyle(color: Colors.grey))
            ])),
      ),
      itemCount: suggestionList.length,
    );
  }
}
