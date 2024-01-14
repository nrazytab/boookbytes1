import 'dart:convert';
import 'dart:developer';
import 'package:boookbytes/cartpage.dart';
import 'package:boookbytes/bookdetails.dart';
import 'package:boookbytes/models/user.dart';
import 'package:boookbytes/models/book.dart';
import 'package:boookbytes/shared/myserverconfig.dart';
import 'package:boookbytes/shared/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  final User user;

  const MainPage({Key? key, required this.user}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Book> bookList = [];
  late double screenWidth, screenHeight;
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;

  var color;
  String title = "";

  @override
  void initState() {
    super.initState();
    loadBooks(title);
  }

  int axiscount = 2;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    axiscount = (screenWidth > 600) ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.yellow),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Book List",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(width: 25),
          ],
        ),
        actions: [
          IconButton(
            onPressed: showSearchDialog,
            icon: const Icon(Icons.search),
          ),
          IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (content) => CartPage(user: widget.user)));
                },
                icon: const Icon(Icons.add_shopping_cart))
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
      ),
      drawer: MyDrawer(
        page: "books",
        user: widget.user,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.yellow],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: (bookList.isEmpty)
              ? const Center(child: Text("No Data"))
              : Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text("Page $curpage/$numofresult"),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: axiscount,
                      children: List.generate(bookList.length, (index) {
                        return Card(
                          child: InkWell(
                            onTap: () async {
                              Book book = Book.fromJson(bookList[index].toJson());
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (content) => BookDetails(
                                    user: widget.user,
                                    book: book,
                                  ),
                                ),
                              );
                              loadBooks(title);
                            },
                            child: Column(
                              children: [
                                Flexible(
                                  flex: 6,
                                  child: Container(
                                    width: screenWidth,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.network(
                                      "${MyServerConfig.server}/bookbytes/assets/books/${bookList[index].bookId}.jpg",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        truncateString(bookList[index].bookTitle.toString()),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text("RM ${bookList[index].bookPrice}"),
                                      Text("Available ${bookList[index].bookQty} unit"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      height: screenHeight * 0.05,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: numofpage,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          color = (curpage - 1 == index) ? Colors.red : Colors.black;
                          return TextButton(
                            onPressed: () {
                              curpage = index + 1;
                              loadBooks(title);
                            },
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(color: color, fontSize: 18),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String truncateString(String str) {
    return (str.length > 20) ? "$str..." : str;
  }

  void loadBooks(String title) {
    http.get(
      Uri.parse("${MyServerConfig.server}/bookbytes/php/load_books.php?title=$title&pageno=$curpage"),
    ).then((response) {
      log(response.body);
      if (response.statusCode == 200) {
        log(response.body);
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          bookList.clear();
          data['data']['books'].forEach((v) {
            bookList.add(Book.fromJson(v));
          });
          numofpage = int.parse(data['numofpage'].toString());
          numofresult = int.parse(data['numberofresult'].toString());
        } else {
          // if no status failed
        }
      }
      setState(() {});
    });
  }

  void showSearchDialog() {
    TextEditingController searchctlr = TextEditingController();
    title = searchctlr.text;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Search Title", style: TextStyle()),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchctlr,
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  loadBooks(searchctlr.text);
                },
                child: const Text("Search"),
              ),
            ],
          ),
        );
      },
    );
  }
}
