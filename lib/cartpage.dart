import 'dart:convert';
import 'package:boookbytes/models/cart.dart';
import 'package:boookbytes/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared/myserverconfig.dart';

class CartPage extends StatefulWidget {
  final User user;

  const CartPage({Key? key, required this.user}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Cart> cartList = [];
  double total = 0.0;
  List<List<Cart>> _groupedCartItems = [];

  @override
  void initState() {
    super.initState();
    loadUserCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart),
            SizedBox(width: 10),
            Text("C A R T"),
          ],
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 252, 174, 200), // Set background color to pink
        child: cartList.isEmpty
          ? const Center(child: Text("No Data"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _groupedCartItems.length,
                    itemBuilder: (context, sellerIndex) {
                      final sellerCart = _groupedCartItems[sellerIndex];
                      final seller = sellerCart.first.sellerId!;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              " $seller",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sellerCart.length,
                            itemBuilder: (context, index) {
                              final cartItem = sellerCart[index];
                              return Dismissible(
                                key: Key(cartItem.bookId.toString()),
                                background: Container(
                                  color: Colors.red,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.delete),
                                    ],
                                  ),
                                ),
                                onDismissed: (direction) => _deleteCartItem(cartItem),
                                child: buildCartItemCard(cartItem),
                              );
                            },
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                "Total Book Items:",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              const Spacer(),
                              Text(
                                "${calculateTotalItems()}",
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 16,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                "Cart SubTotal:",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              const Spacer(),
                              Text(
                                "RM ${calculateSubtotal().toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 16,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                "Delivery Charge:",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              const Spacer(),
                              Text(
                                "RM ${(recalculateTotal() - calculateSubtotal()).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 16,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Cart Total: RM ${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                    onPressed: () {
                      // Implement checkout logic here
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 196, 26, 131),
                      onPrimary: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Place Order",
                      style: TextStyle(
                        fontSize: 18, // Adjust the font size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ],
                ),
              ),
              ],
            ),
      )
    );
  }

  Widget buildCartItemCard(Cart cartItem) {
    return Card(
      child: ListTile(
        leading: Image.network(
          "${MyServerConfig.server}/bookbytes/assets/books/${cartItem.bookId}.jpg",
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        ),
        title: Text(cartItem.bookTitle.toString()),
        subtitle: Text("RM ${cartItem.bookPrice.toString()}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _decrementQuantity(cartItem),
              icon: const Icon(Icons.remove),
            ),
            Text(cartItem.cartQty.toString()),
            IconButton(
              onPressed: () => _incrementQuantity(cartItem),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  loadUserCart() async {
    try {
      String userid = widget.user.userid.toString();
      final response = await http.get(
        Uri.parse("${MyServerConfig.server}/bookbytes/php/load_cart.php?userid=$userid"),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          cartList.clear();
          total = 0.0;
          data['data']['carts'].forEach((v) {
            cartList.add(Cart.fromJson(v));
            total += double.parse(v['book_price']) * int.parse(v['cart_qty']);
          });
          _groupCartItems();
          total = recalculateTotal();
          setState(() {});
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      print("Error loading user cart: $error");
    }
  }

  _incrementQuantity(Cart cartItem) async {
    _updateQuantity(cartItem, int.parse(cartItem.cartQty!) + 1);
  }

  _decrementQuantity(Cart cartItem) async {
    int currentQuantity = int.parse(cartItem.cartQty!);
    if (currentQuantity > 1) {
      _updateQuantity(cartItem, currentQuantity - 1);
    } else {
      _showRemoveItemDialog(cartItem);
    }
  }

  void _showRemoveItemDialog(Cart cartItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("Do you want to delete this item from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _deleteCartItem(cartItem);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  _updateQuantity(Cart cartItem, int newqty) async {
    setState(() {
      cartItem.cartQty = newqty.toString();
      total = recalculateTotal();
    });

    await _updateCartQuantity(cartItem.cartId!, cartItem.cartQty!);
  }

  _updateCartQuantity(String cartId, String newqty) async {
    try {
      final response = await http.post(
        Uri.parse("${MyServerConfig.server}/bookbytes/php/update_cart.php"),
        body: {
          "cartid": cartId,
          "newqty": newqty,
        },
      );

      var data = jsonDecode(response.body);
      if (data['status'] == "success") {
        await loadUserCart();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update cart quantity"), backgroundColor: Colors.red,),
        );
      }
    } catch (error) {
      print("Error updating cart quantity: $error");
    }
  }

  _deleteCartItem(Cart cartItem) async {
    try {
      final response = await http.post(
        Uri.parse("${MyServerConfig.server}/bookbytes/php/delete_cart.php"),
        body: {
          "cartid": cartItem.cartId,
        },
      );

      print("Delete Cart Response: ${response.body}"); // Add this line for debugging

      var data = jsonDecode(response.body);
      if (data['status'] == "success") {
        setState(() {
          cartList.remove(cartItem);
          total = recalculateTotal();
        });
        await loadUserCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your Item delete successfully"), backgroundColor: Colors.green,),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete item"), backgroundColor: Colors.red,),
        );
      }
    } catch (error) {
      print("Error deleting cart item: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error"), backgroundColor: Colors.red,),
      );
    }
  }

  double calculateSubtotal() {
    double subtotal = 0.0;

    _groupedCartItems.forEach((sellerCart) {
      sellerCart.forEach((item) {
        subtotal += double.parse(item.bookPrice!) * int.parse(item.cartQty!);
      });
    });

    return subtotal;
  }

  double recalculateTotal() {
    double newTotal = 0.0;

    _groupedCartItems.forEach((sellerCart) {
      double sellerSubtotal = 0.0;

      sellerCart.forEach((item) {
        sellerSubtotal += double.parse(item.bookPrice!) * int.parse(item.cartQty!);
      });
      newTotal += sellerSubtotal + 10.0;
    });

    return newTotal;
  }

  int calculateTotalItems() {
    int totalItems = 0;
    _groupedCartItems.forEach((sellerCart) {
      sellerCart.forEach((item) {
        totalItems += int.parse(item.cartQty!);
      });
    });
    return totalItems;
  }

  void _groupCartItems() {
    _groupedCartItems = [];
    final groupedMap = <String, List<Cart>>{};
    cartList.forEach((item) {
      groupedMap.putIfAbsent(item.sellerId!, () => []).add(item);
    });
    _groupedCartItems = groupedMap.values.toList();
  }
}
