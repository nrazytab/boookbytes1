import 'dart:convert';
import 'dart:developer';
//import 'dart:developer';
import 'package:intl/intl.dart';
//import 'package:boookbytes/cartpage.dart';
import 'package:boookbytes/models/book.dart';
import 'package:boookbytes/models/user.dart';
import 'package:boookbytes/shared/myserverconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookDetails extends StatefulWidget {
  final User user;
  final Book book;

  const BookDetails({Key? key, required this.user, required this.book})
      : super(key: key);

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late double screenWidth, screenHeight;
  final f = DateFormat('dd-MM-yyyy hh:mm a');
  bool bookowner = false;

  @override
  Widget build(BuildContext context) {
    if (widget.user.userid == widget.book.userId) {
      bookowner = true;
    } else {
      bookowner = false;
    }
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.bookTitle.toString()),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.yellow,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.4,
                width: screenWidth,
                child: Image.network(
                  fit: BoxFit.fill,
                  "${MyServerConfig.server}/bookbytes/assets/books/${widget.book.bookId}.jpg",
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey, 
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.book.bookTitle.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    Text(
                      widget.book.bookAuthor.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Date Available ${f.format(DateTime.parse(widget.book.bookDate.toString()))}",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "ISBN ${widget.book.bookIsbn}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.book.bookDesc.toString(),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "RM ${widget.book.bookPrice}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 121, 10),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Quantity Available ${widget.book.bookQty}",
                      textAlign: TextAlign.center),
                    Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        insertCartDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 31, 6, 14), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0), 
                        ),
                      ),
                      child: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
                    ),
                  )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   void insertCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Insert to cart?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                final bookQty = widget.book.bookQty;
                final qtyAsInt = bookQty != null ? int.tryParse(bookQty) : null;

                if (qtyAsInt != null && qtyAsInt > 0) {
                  insertCart();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Out Of Stock!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void insertCart() {
    http.post(
        Uri.parse("${MyServerConfig.server}/bookbytes/php/insert_cart.php"),
        body: {
          "buyer_id": widget.user.userid.toString(),
          "seller_id": widget.book.userId.toString(),
          "book_id": widget.book.bookId.toString(),
        }).then((response) {
      log(response.body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success"),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}

