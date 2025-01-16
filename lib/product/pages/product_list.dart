
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit_product.dart';
import '../models/Category.dart';
import '../models/Product.dart';
import 'Detail_product.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late final ProductCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProductCubit>();
    _cubit.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget buildList(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Productv5'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onSubmitted: (query) {
                      _cubit.setSkip(0);
                      _cubit.searchProducts(query); // Gọi hàm tìm kiếm từ Cubit
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _cubit.setSkip(0);
                    _searchController.clear();
                    _cubit.resetSearch(); // Reset tìm kiếm khi xóa
                  },
                ),
                DropdownButton<String>(
                  value: _cubit.state['dropdownValue'],
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    print('testtttttttttttt ${newValue}');
                    if (newValue != null) {
                      _cubit.setSkip(0);
                      _cubit.setDropdownValue(newValue);
                      _cubit.fetchProducts(); // Gọi hàm lấy sản phẩm theo danh mục
                    } else {
                      _cubit.resetDropdown(); // Reset danh mục
                    }
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text("Category"),
                    ),
                    ..._cubit.state['categories']
                        .map<DropdownMenuItem<String>>((Categorytt category) {
                      return DropdownMenuItem<String>(
                        value: category.slug,
                        child: Text(category.name),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  _cubit.loadMoreProducts(); // Gọi hàm tải thêm sản phẩm từ Cubit
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _cubit.state['products'].length,
                itemBuilder: (context, index) {
                  final product = _cubit.state['products'][index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '${product.thumbnail}',
                              fit: BoxFit.contain,
                              height: 80,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 80,
                                  width: 80,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${product.title}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '\$${product.price} USD',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${product.stock} units in stock',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${product.discountPercentage} discountPercentage',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _cubit.setIsDetailProduct(true);
                              _cubit.setIdDetailProduct(product.id!);
                            },
                            child: const Text("Detail"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, Map<String, dynamic>>(
      builder: (context, state) {
        final isDetailProduct = state['isDetailProduct'] ?? false;
        if (!isDetailProduct) {
          return buildList(context);
        } else {
          return DetailsProduct();
        }
      },
    );
  }
}
