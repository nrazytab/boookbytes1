import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../shared/myserverconfig.dart';

class NewBookPage extends StatefulWidget {
  final User userdata;

  const NewBookPage({super.key, required this.userdata});

  @override
  State<NewBookPage> createState() => _NewBookPageState();
}

class _NewBookPageState extends State<NewBookPage> {
  late double screenWidth, screenHeight;

  File? _image;
  String dropdownvalue = 'New';
  var types = [
    'New',
    'Used',
    'Digital',
  ];

  TextEditingController isbnCtrl = TextEditingController();
  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descCtrl = TextEditingController();
  TextEditingController authCtrl = TextEditingController();
  TextEditingController priceCtrl = TextEditingController();
  TextEditingController qtyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("New Book")),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: GestureDetector(
                      onTap: () {
                      },
                      child: Container(
                        height: screenHeight * 0.3,
                        width: screenWidth * 0.8,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.scaleDown,
                                image: _image == null
                                    ? const AssetImage(
                                        "assets/images/camera.png")
                                    : FileImage(_image!) as ImageProvider)),
                      ),
                    ),
                  ),
                  const Text(
                    "Add New Book",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      validator: (val) => val!.isEmpty || (val.length != 17)
                          ? "ISBN must be 17"
                          : null,
                      onFieldSubmitted: (v) {},
                      controller: isbnCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'ISBN',
                          labelStyle: const TextStyle(),
                          icon: const Icon(
                            Icons.numbers,
                          ),
                          suffixIcon: IconButton(
                              onPressed: () {}, icon: const Icon(Icons.camera)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      validator: (val) => val!.isEmpty || (val.length < 3)
                          ? "Book title must be longer than 3"
                          : null,
                      onFieldSubmitted: (v) {},
                      controller: titleCtrl,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Book Title',
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.book,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      validator: (val) => val!.isEmpty || (val.length < 10)
                          ? "Book description must be longer than 10"
                          : null,
                      onFieldSubmitted: (v) {},
                      maxLines: 4,
                      controller: descCtrl,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Book Description',
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.description,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  TextFormField(
                      textInputAction: TextInputAction.next,
                      validator: (val) => val!.isEmpty || (val.length < 3)
                          ? "Book author must be longer than 3"
                          : null,
                      onFieldSubmitted: (v) {},
                      controller: authCtrl,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Book Author',
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.person_2,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  val!.isEmpty || (val.length < 3)
                                      ? "Book price must contain value"
                                      : null,
                              onFieldSubmitted: (v) {},
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Book Price',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.money),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  )))),
                      Flexible(
                          flex: 3,
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  val!.isEmpty || !(int.parse(val) > 0)
                                      ? "Product price must contain value"
                                      : null,
                              onFieldSubmitted: (v) {},
                              controller: qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  labelStyle: TextStyle(),
                                  icon: Icon(Icons.add_box),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  )))),
                      Flexible(
                        flex: 3,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Icon(Icons.new_label, color: Colors.grey),
                              Container(
                                  margin: const EdgeInsets.all(8),
                                  height: 50,
                                  width: screenWidth * 0.2,
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0))),
                                  child: DropdownButton(
                                    value: dropdownvalue,
                                    underline: const SizedBox(),
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: types.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      dropdownvalue = newValue!;

                                      setState(() {});
                                    },
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(screenWidth, 40)),
                    child: const Text('Add Book'),
                    onPressed: () {
                      insertBookDialog();
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }

  void insertBookDialog() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill in form!!!"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please take picture!!!"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Insert new book",
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
                insertBook();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Canceled"),
                  backgroundColor: Colors.red,
                ));
              },
            ),
          ],
        );
      },
    );
  }

  void insertBook() {
    String isbn = isbnCtrl.text;
    String title = titleCtrl.text;
    String desc = descCtrl.text;
    String author = authCtrl.text;
    String price = priceCtrl.text;
    String qty = qtyCtrl.text;
    String imagestr = base64Encode(_image!.readAsBytesSync());

    http.post(
        Uri.parse("${MyServerConfig.server}/bookbytes/php/insert_book.php"),
        body: {
          "userid": widget.userdata.userid.toString(),
          "isbn": isbn,
          "title": title,
          "desc": desc,
          "author": author,
          "price": price,
          "qty": qty,
          "status": dropdownvalue,
          "image": imagestr
        }).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Insert Success"),
            backgroundColor: Colors.green,
          ));
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (content) => const LoginPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Insert Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}