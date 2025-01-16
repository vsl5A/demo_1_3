import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testtwo/product/cubit/cubit_product.dart';
import 'package:testtwo/product/pages/product_list.dart';










// void main() {
//   runApp(   ProductCard());
// }

// void main() {
//   runApp(
//     BlocProvider(
//       create: (context) => CounterCubit(),
//       child: MaterialApp(
//         home: MyHomePage(),
//       ),
//     ),
//   );
// }
// class ShoppingCartApp extends StatelessWidget {
//   const ShoppingCartApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => CartProvider(),
//       child: const MaterialApp(
//           debugShowCheckedModeBanner: false, home: MyHomePage()),
//     );
//   }
// }
void main() {
  runApp(MaterialApp(
    home: BlocProvider(
      create: (context) => ProductCubit(), // CounterCubit sẽ được sử dụng ở cấp cao nhất của ứng dụng
      child: HomePage(),
    ),
  )
    ,
  );
}

