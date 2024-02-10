// ignore_for_file: avoid_print
import 'package:boookbytes/cartpage.dart';
import 'package:boookbytes/communitypage.dart';
import 'package:boookbytes/orderpage.dart';
import 'package:boookbytes/profilepage.dart';
import 'package:flutter/material.dart'; 
import '../models/user.dart';
import '../mainpage.dart';
import 'EnterExitRoute.dart';
import 'package:boookbytes/shared/myserverconfig.dart';
import 'package:cached_network_image/cached_network_image.dart'; 

class MyDrawer extends StatefulWidget {
  final String page;
  final User user;
  
  const MyDrawer({Key? key, required this.page, required this.user})
      : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.pink,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                "${MyServerConfig.server}/bookbytes/assets/books/userid.jpg",
              ),
              backgroundColor: Colors.white,
            ),
            accountName: Text(widget.user.username.toString()),
            accountEmail: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.user.useremail.toString()),
                  const Text("azGroup")
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Books'),
            onTap: () {
              Navigator.pop(context);
              print(widget.page.toString());
              if (widget.page.toString() == "books") {
                return;
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                EnterExitRoute(
                  exitPage: MainPage(
                    user: widget.user,
                  ),
                  enterPage: MainPage(user: widget.user)
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sell),
            title: const Text('Orders and Sales'),
            onTap: () {
              Navigator.pop(context);
              print(widget.page.toString());
              if (widget.page.toString() == "seller") {
                return;
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                EnterExitRoute(
                  exitPage: OrderPage(
                    userdata: widget.user,
                  ),
                  enterPage: OrderPage(
                    userdata: widget.user,
                  )
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Community'),
            onTap: () {
              print(widget.page.toString());
              Navigator.pop(context);
              if (widget.page.toString() == "community") {
                return;
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                EnterExitRoute(
                  exitPage: CommunityPage(userdata: widget.user),
                  enterPage: CommunityPage(userdata: widget.user)
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              print(widget.page.toString());
              Navigator.pop(context);
              if (widget.page.toString() == "cart") {
                return;
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                EnterExitRoute(
                  exitPage: CartPage(user: widget.user),
                  enterPage: CartPage(user: widget.user)
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('My Profile'),
            onTap: () {
              print(widget.page.toString());
              Navigator.pop(context);
              if (widget.page.toString() == "account") {
                return;
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                EnterExitRoute(
                  exitPage: ProfilePage(userdata: widget.user),
                  enterPage: ProfilePage(userdata: widget.user)
                )
              );
            },
          ),
          const Divider(
            color: Colors.blueGrey,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
