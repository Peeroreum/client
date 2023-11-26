import 'package:get/get.dart';
import 'package:peeroreum_client/model/PeeroreumModel.dart';
import 'package:flutter/services.dart';

class loginController extends GetxController {
  var productList = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void fetchData() async {
    var products = await Services.fetchProducts();
    if (products != null) {
      productList.value = products;
    }
  }
}
