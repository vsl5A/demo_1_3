
import 'dart:async';




import 'package:flutter_bloc/flutter_bloc.dart';



import 'package:testtwo/product/models/Category.dart';

import '../models/Product.dart';
import 'api_service.dart';






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
