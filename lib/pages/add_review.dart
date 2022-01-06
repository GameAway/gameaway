import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gameaway/services/db.dart';
import 'package:gameaway/services/order.dart';
import 'package:gameaway/views/action_bar.dart';

class AddReview extends StatefulWidget {
  const AddReview({Key? key, required this.order}) : super(key: key);

  final Order order;

  @override
  State<AddReview> createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  num rating = 1;
  String comment = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ActionBar(title: "Add Review"),
      body: Column(children: [
        RatingBar(
          initialRating: 2.5,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          minRating: 1,
          ratingWidget: RatingWidget(
            full: const Icon(Icons.star),
            half: const Icon(Icons.star_half),
            empty: const Icon(Icons.star_border_outlined),
          ),
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          onRatingUpdate: (value) {
            rating = value;
          },
        ),
        TextField(
          maxLines: null,
          maxLength: 100,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
              hintText: "Comment (Optional)", border: OutlineInputBorder()),
          onChanged: (value) {
            comment = value;
          },
        ),
        OutlinedButton(
            onPressed: () async {
              DBService db = DBService();
              db.addReview(widget.order, rating, comment);
              await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text("Success"),
                        content: const Text(
                            "Review submitted. It will be shown once approved by the seller."),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(_);
                              },
                              child: const Text("Ok"))
                        ],
                      ));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Submit"))
      ]),
    );
  }
}
