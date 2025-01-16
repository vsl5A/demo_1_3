
import 'dart:async';




import 'package:flutter_bloc/flutter_bloc.dart';



import 'package:testtwo/product/models/Category.dart';

import '../models/Product.dart';
import 'api_service.dart';


// class ProductCubit extends Cubit<Map<String, dynamic>> {
//   int indexPage = 0;
//  final pageSize = 5;
//   static const String _baseUrl = 'https://dummyjson.com';
//
//   ProductCubit() : super({'products': <Product>[],
//
//     'isDetailProduct' :false,'idDetailProduct' : 1,
//     'categories' : <Categorytt>[],
//     'dropdownValue' : '',
//     'skip':0,
//
//     });
//
//
//
//
//   Future<void> fetchProducts() async {
//     // final url = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
//     // final response = await http.get(url, headers: {
//     //   'Content-Type': 'application/json; charset=UTF-16',
//     // });
//     //
//     // if (response.statusCode == 200) {
//     //   return _parseProducts(response.bodyBytes);
//     // } else {
//     //   throw Exception('Failed to load products');
//     // }
//     List<Product> updatedList = List.from(state['products']);
//
//
//     ApiService.fetchProducts(state['skip'], pageSize).then((newProducts) {
//       updatedList = newProducts;
//     });
//     emit({...state, 'products': updatedList});
//   }
//    Future<void> searchProducts() async {
//     // final url = Uri.parse('$_baseUrl/products/search?q=$query');
//     // final response = await http.get(url, headers: {
//     //   'Content-Type': 'application/json; charset=UTF-16',
//     // });
//     //
//     // if (response.statusCode == 200) {
//     //   return _parseProducts(response.bodyBytes);
//     // } else {
//     //   throw Exception('Failed to search products');
//     // }
//      List<Product> updatedList = List.from(state['products']);
//      ApiService.searchProducts(state['dropdownValue']).then((result) {
//
//        updatedList = result;
//
//      }).catchError((error) {
//
//      });
//      emit({...state, 'products': updatedList});
//   }
//
//    Future<void> fetchCategories() async {
//     // final url = Uri.parse('$_baseUrl/products/categories');
//     // final response = await http.get(url, headers: {
//     //   'Content-Type': 'application/json; charset=UTF-16',
//     // });
//     //
//     // if (response.statusCode == 200) {
//     //   final List<dynamic> jsonResponse = json.decode(response.body);
//     //   return jsonResponse
//     //       .map((category) =>
//     //       Categorytt(slug: category['slug'], name: category['name'], url: category['url']))
//     //       .toList();
//     // } else {
//     //   throw Exception('Failed to load categories');
//     // }
//      List<Categorytt> updatedList = List.from(state['categories']);
//      ApiService.fetchCategories().then((fetchedCategories) {
//
//        updatedList = fetchedCategories;
//
//
//      });
//      emit({...state, 'categories': updatedList});
//   }
//
//    Future<void> fetchProductsByCategory() async {
//     // final url = Uri.parse('$_baseUrl/products/category/$category?limit=$limit');
//     // final response = await http.get(url, headers: {
//     //   'Content-Type': 'application/json; charset=UTF-16',
//     // });
//     //
//     // if (response.statusCode == 200) {
//     //   return _parseProducts(response.bodyBytes);
//     // } else {
//     //   throw Exception('Failed to fetch products by category');
//     // }
//      List<Product> updatedList = List.from(state['products']);
//      ApiService.fetchProductsByCategory(state['dropdownValue'], pageSize)
//          .then((newProducts) {
//
//
//          updatedList = newProducts;
//          if (updatedList.isNotEmpty) {
//            setSkip(updatedList[updatedList.length - 1].id!);
//
//          }
//          else {
//            setSkip(updatedList[0].id!);
//
//          }
//
//      }).catchError((error) {
// print ('${error}');
//      });
//      emit({...state, 'products': updatedList});
//   }
//
//   void setSkip ( int skip) {
//     List<Product> updatedList = List.from(state['products']);
//
//     emit({...state, 'products': updatedList,
//       'skip':skip});
//   }
//   void setDropdownValue ( String dropdownValue) {
//     List<Product> updatedList = List.from(state['products']);
//
//     emit({...state, 'products': updatedList,
//       'dropdownValue':dropdownValue});
//   }
//
//   void setIsDetailProduct ( bool check) {
//     List<Product> updatedList = List.from(state['products']);
//     emit({...state, 'products': updatedList,
//       'isDetailProduct':check});
//   }
//   void setIdDetailProduct ( int id) {
//     List<Product> updatedList = List.from(state['products']);
//     emit({...state, 'products': updatedList,
//       'idDetailProduct':id});
//   }
//   bool isWordInText(String text, String word) {
//     // Chuyển cả đoạn văn và từ kiểm tra sang chữ thường để so sánh không phân biệt chữ hoa/thường
//     text = text.toLowerCase();
//     word = word.toLowerCase();
//
//     // Tìm từ trong đoạn văn
//     return text.contains(word);
//   }
//
//
//
//
// }



class ProductCubit extends Cubit<Map<String, dynamic>> {
  final int pageSize = 5; // Số lượng sản phẩm mỗi trang

  ProductCubit()
      : super({
    'products': <Product>[],
    'categories': <Categorytt>[],
    'dropdownValue': '',
    'isDetailProduct': false,
    'idDetailProduct': 1,
    'skip': 0,
    'searchQuery': '',
    'detailProduct': null
  });

  /// Khởi tạo dữ liệu ban đầu
  Future<void> initialize() async {
    emit({...state, 'skip': 0});
    await fetchProducts();
    await fetchCategories();
  }

  /// Đặt lại tìm kiếm
  void resetSearch() {
    emit({...state, 'searchQuery': ''});
    fetchProducts(); // Gọi lại API để tải danh sách sản phẩm ban đầu
  }

  /// Đặt lại dropdown về giá trị ban đầu
  void resetDropdown() {
    emit({...state, 'dropdownValue': ''});
    fetchProducts(); // Gọi lại API để tải danh sách sản phẩm ban đầu
  }

  /// Tải thêm sản phẩm khi cuộn xuống
  Future<void> loadMoreProducts() async {
    final int currentSkip = state['skip'];
    emit({...state, 'skip': currentSkip + pageSize});
    await fetchProducts(); // Gọi API để tải thêm sản phẩm
  }


  Future<void> fetchProducts() async {
    final int skip = state['skip'];
    final String query = state['searchQuery'];
    final String category = state['dropdownValue'];

    List<Product> products;

    if (query.isNotEmpty ) {
      if(category.isNotEmpty) {
        final categoryProducts = await ApiService.fetchProductsByCategory(category, pageSize,skip);
        products = categoryProducts.where((product) {
          return product.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
        }).toList();
      } else {
        products = await ApiService.searchProducts(query,pageSize,skip);
      }

    } else if (category.isNotEmpty) {
      products = await ApiService.fetchProductsByCategory(category, pageSize,skip);
    } else {
      products = await ApiService.fetchProducts(skip, pageSize);
    }

    emit({...state, 'products': products});
  }


  Future<void> fetchCategories() async {
    final categories = await ApiService.fetchCategories();
    emit({...state, 'categories': categories});
  }


  Future<void> fetchDetailProduct() async {
    try {
      final Product product = await ApiService.fetchProduct(state['idDetailProduct']); // Gọi API lấy chi tiết sản phẩm
      emit({...state, 'detailProduct': product}); // Cập nhật state
    } catch (error) {
      print("Error fetching product detail: $error");
    }
  }
  void searchProducts(String query) {
    emit({...state, 'searchQuery': query});
    fetchProducts();
  }


  void setDropdownValue(String value) {
    emit({...state, 'dropdownValue': value});
  }


  void setSkip(int skip) {
    emit({...state, 'skip': skip});
  }


  void setIsDetailProduct(bool isDetail) {
    emit({...state, 'isDetailProduct': isDetail});
  }


  void setIdDetailProduct(int id) {
    emit({...state, 'idDetailProduct': id});
  }

  void setDetailProduct(Product product) {
    emit({...state, 'detailProduct': product});
  }
}
