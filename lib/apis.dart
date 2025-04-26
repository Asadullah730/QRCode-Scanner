import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'dart:async';

/// request a product from the OpenFoodFacts database
Future<Product?> getProduct(String code) async {
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'MyFlutterApp',
    url: 'https://myflutterapp.com',
  );

  final ProductQueryConfiguration configuration = ProductQueryConfiguration(
    code,
    language: OpenFoodFactsLanguage.ENGLISH, // use English for broader data
    fields: [ProductField.ALL],
    version: ProductQueryVersion.v3,
  );

  try {
    final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
      configuration,
    );
    if (kDebugMode) {
      print("RESULT: ${result.toString()}");
      print("RESULT STATUS: ${result.status}");
      print("RESULT PRODUCT: ${result.product?.abbreviatedName}");
      print("RESULT PRODUCT: ${result.product?.abbreviatedNameInLanguages}");
      print("RESULT PRODUCT: ${result.product?.packaging}");
    }

    if (result.status == ProductResultV3.statusSuccess) {
      if (kDebugMode) {
        print("PRODUCT FOUND: ${result.product?.abbreviatedName}");
        print("PRODUCT FOUND: ${result.product?.abbreviatedNameInLanguages}");
      }
      return result.product;
    } else {
      if (kDebugMode) {
        print("PRODUCT NOT FOUND: ${result.status} ${result.toString()}");
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print("ERROR FETCHING PRODUCT: $e");
    }
    return null;
  }
}
