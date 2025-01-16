import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../models/Category.dart';
import '../models/Product.dart';


class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  static Future<List<Product>> fetchProducts(int skip, int limit) async {
    final url = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json; charset=UTF-16',
    });

    if (response.statusCode == 200) {
      return _parseProducts(response.bodyBytes);
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> searchProducts(String query, int size, int skip) async {
    final url = Uri.parse('$_baseUrl/products/search?q=$query&limit=$size&skip=$skip');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json; charset=UTF-16',
    });

    if (response.statusCode == 200) {
      return _parseProducts(response.bodyBytes);
    } else {
      throw Exception('Failed to search products');
    }
  }

  static Future<List<Categorytt>> fetchCategories() async {
    final url = Uri.parse('$_baseUrl/products/categories');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json; charset=UTF-16',
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((category) =>
          Categorytt(slug: category['slug'], name: category['name'], url: category['url']))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Product>> fetchProductsByCategory(String category, int limit,int skip) async {
    final url = Uri.parse('$_baseUrl/products/category/$category?limit=$limit&skip=$skip');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json; charset=UTF-16',
    });

    if (response.statusCode == 200) {
      return _parseProducts(response.bodyBytes);
    } else {
      throw Exception('Failed to fetch products by category');
    }
  }

  static List<Product> _parseProducts(Uint8List response) {
    final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response));
    final List<dynamic> content = jsonResponse["products"];
    for (var item in content) {
      if (item is Map<String, dynamic>) {
        if (!item.containsKey("Qty") || item["Qty"] == null) {
          item["Qty"] = 1;
        }
      }
    }
    return content.map<Product>((json) => Product.fromJson(json)).toList();
  }
  static Future<Product> fetchProduct(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Product.fromJson(jsonData);
    } else {
      throw Exception('Failed to load product');
    }
  }
}
