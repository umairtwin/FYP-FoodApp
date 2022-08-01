import 'package:flutter/material.dart';
import 'package:food_delivery/controllers/cart_controller.dart';
import 'package:food_delivery/data/repository/popular_product_repo.dart';
import 'package:food_delivery/models/cart_model.dart';
import 'package:food_delivery/models/products_model.dart';
import 'package:food_delivery/utils/colors.dart';
import 'package:get/get.dart';

class PopularProductController extends GetxController {
  final PopularProductRepo popularProductRepo;
  PopularProductController({required this.popularProductRepo});
  List<dynamic> _popularProductList = [];
  List<dynamic> get popularProductList => _popularProductList;
  late CartController _cart;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItems = 0;
  int get inCartItems => _inCartItems + _quantity;

  Future<void> getPopularProductList() async {
    // print("helo");
    Response response = await popularProductRepo.getPopularProductList();
    print("getPopularProductList");
    if (response.statusCode == 200) {
      print("Got Products");
      _popularProductList = [];
      _popularProductList.addAll(Product.fromJson(response.body).products);
      print(_popularProductList);
      _isLoaded = true;
      update();
    } else {
      print("not get");
    }
  }

  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = checkQuantity(_quantity + 1);
      print("number of items " + _quantity.toString());
    } else {
      _quantity = checkQuantity(_quantity - 1);
      print('decrement' + _quantity.toString());
    }
    update();
  }

// _inCartItems=2
// _quantity=0
// _quantity=-1
  int checkQuantity(int quantity) {
    if ((_inCartItems + quantity) < 0) {
      Get.snackbar("Item count", "You can't reduce more!",
          backgroundColor: AppColors.mainColor, colorText: Colors.white);
      if (_inCartItems > 0) {
        _quantity = -_inCartItems;
        return quantity;
      }
      return 0;
    } else if ((_inCartItems + quantity) > 20) {
      Get.snackbar("Item count", "You can't add more!",
          backgroundColor: AppColors.mainColor, colorText: Colors.white);
      return 20;
    } else {
      return quantity;
    }
  }

  void initProduct(ProductModel product, CartController cart) {
    _quantity = 0;
    _inCartItems = 0;
    _cart = cart;
    var exixt = false;
    exixt = _cart.existInCart(product);
    //if exist
    //get from storage _inCartItems=3
    print('exist or not ' + exixt.toString());
    if (exixt) {
      _inCartItems = _cart.getQuantity(product);
    }
    print('the value in the cart is ' + _inCartItems.toString());
  }

  void addItem(ProductModel product) {
    _cart.addItem(product, _quantity);
    _quantity = 0;
    _inCartItems = _cart.getQuantity(product);
    _cart.items.forEach((key, value) {
      print('the id is ' +
          value.id.toString() +
          ' the quantity is ' +
          value.quantity.toString());
    });
    update();
  }

  int get totalItems {
    return _cart.totalItems;
  }

  List<CartModel> get getItems {
    return _cart.getItems;
  }
}
