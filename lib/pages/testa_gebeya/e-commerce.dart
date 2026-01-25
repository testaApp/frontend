// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shimmer/shimmer.dart';

// import '../../application/product/product_bloc.dart';
// import '../../application/product/product_event.dart';
// import '../../application/product/product_state.dart';
// import '../../domain/product/product.dart';
// import '../../util/baseUrl.dart';
// import '../appbar_pages/news/main_news/news_detail.dart';
// import '../constants/colors.dart';

// class EcommerceHomePage extends StatefulWidget {
//   const EcommerceHomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<EcommerceHomePage> {
//   @override
//   void initState() {
//     super.initState();
//     BlocProvider.of<ProductBloc>(context)
//         .add(FetchProductsEvent()); // Fetch best players
//   }

//   int _currentIndex = 0;

//   Widget _buildBody() {
//     switch (_currentIndex) {
//       case 0:
//         return const HomeContent();
//       case 1:
//         return const ShoesPage();
//       case 2:
//         return const TShirtPage();
//       case 3:
//         return const FlowerPage();
//       default:
//         return Container();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final bottomNavBarProvider = Provider.of<BottomNavBarProvider>(context);
//     // bottomNavBarProvider.updateBottomNavBarVisibility(false);
//     return Scaffold(
//         // backgroundColor: Colorscontainer.greenColor,\
//         backgroundColor: Colors.grey[100],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           type: BottomNavigationBarType.fixed, // Set type to fixed
//           showSelectedLabels: true,
//           items: [
//             BottomNavigationBarItem(
//               icon: const Icon(Icons.home_outlined, color: Colors.black),
//               activeIcon: Icon(Icons.home, color: Colorscontainer.greenColor),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: const Icon(Icons.category_outlined, color: Colors.black),
//               activeIcon:
//                   Icon(Icons.category, color: Colorscontainer.greenColor),
//               label: 'T-Shirt',
//             ),
//             BottomNavigationBarItem(
//               icon:
//                   const Icon(Icons.shopping_bag_outlined, color: Colors.black),
//               activeIcon:
//                   Icon(Icons.shopping_bag, color: Colorscontainer.greenColor),
//               label: 'Shoe',
//             ),
//             BottomNavigationBarItem(
//               icon: const Icon(Icons.favorite_border, color: Colors.black),
//               activeIcon:
//                   Icon(Icons.favorite, color: Colorscontainer.greenColor),
//               label: 'Favorite',
//             ),
//           ],
//           elevation: 8,
//           selectedItemColor: Colorscontainer.greenColor,
//           unselectedItemColor: Colors.grey[600],
//         ),
//         body: Stack(children: [
//           Positioned.fill(child: _buildBody()),
//           const Align(
//               alignment: Alignment.bottomCenter,
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: SizedBox(),
//                   ),
//                   // BlocBuilder<AudioBloc, AudioState>(
//                   //   builder: (context, state) {
//                   //     return state.playing == AudStatus.stopped
//                   //         ? const SizedBox.shrink()
//                   //         : const NowPlaying();
//                   //   },
//                   // )
//                 ],
//               )),
//         ]));
//   }

//   BottomNavigationBarItem _buildNavigationBarItem({
//     required IconData icon,
//     required String label,
//     required bool isSelected,
//   }) {
//     Color iconColor = isSelected ? Colors.black : Colors.grey;
//     Color borderColor = isSelected ? Colors.black : Colors.transparent;

//     return BottomNavigationBarItem(
//       icon: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: borderColor),
//           borderRadius: BorderRadius.circular(10.h),
//         ),
//         padding: EdgeInsets.all(8.h),
//         child: Icon(
//           icon,
//           color: iconColor,
//         ),
//       ),
//       label: '',
//     );
//   }
// }

// class HomeContent extends StatelessWidget {
//   const HomeContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     String baseUrl = BaseUrl().url;
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             floating: true,
//             snap: true,
//             backgroundColor: Colors.green[200],
//             title: const Text('Testa Gebeya',
//                 style: TextStyle(
//                     color: Colors.black, fontWeight: FontWeight.bold)),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search, color: Colors.black),
//                 onPressed: () {
//                   // Implement search functionality
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.shopping_cart, color: Colors.black),
//                 onPressed: () {
//                   // Navigate to cart
//                 },
//               ),
//             ],
//           ),
//           SliverToBoxAdapter(
//             child: _buildPromoBanner(),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 'New Arrivals',
//                 style: TextStyle(
//                     fontSize: 22.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87),
//               ),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             sliver: BlocBuilder<ProductBloc, ProductState>(
//               builder: (context, state) {
//                 if (state.isLoading) {
//                   return SliverToBoxAdapter(child: _buildShimmerEffect());
//                 } else if (state.isSuccess) {
//                   return SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                       (context, index) => _buildProductCard(
//                           context, state.products[index], baseUrl),
//                       childCount: state.products.length,
//                     ),
//                   );
//                 } else if (state.isFailure) {
//                   return SliverToBoxAdapter(
//                     child: Center(
//                         child: Text('Error loading products: ${state.error}')),
//                   );
//                 } else {
//                   return const SliverToBoxAdapter(
//                     child: Center(child: Text('No products available')),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPromoBanner() {
//     return Container(
//       height: 180.h,
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Stack(
//           children: [
//             Image.asset(
//               'assets/shoes.jpg',
//               fit: BoxFit.cover,
//               width: double.infinity,
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'ኦርጅናል የስፖርት ጫማወች በቅናሽ',
//                     style: TextStyle(
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'ብራንድ የሆኑ ምርጥ ምርጥ ጫማወች',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: 5,
//         itemBuilder: (context, index) => Card(
//           elevation: 1.0,
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const SizedBox(height: 100, width: double.infinity),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductCard(
//       BuildContext context, Product product, String baseUrl) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: () => Navigator.push(context,
//             MaterialPageRoute(builder: (context) => const NewsDetailPage())),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: CachedNetworkImage(
//                   imageUrl: '$baseUrl/${product.Images[0]}',
//                   fit: BoxFit.cover,
//                   width: 100.w,
//                   height: 100.h,
//                   placeholder: (context, url) => Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: Container(color: Colors.white),
//                   ),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       product.productName,
//                       style: TextStyle(
//                           fontSize: 16.sp, fontWeight: FontWeight.bold),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '${product.price} ብር',
//                       style: TextStyle(
//                           fontSize: 16.sp,
//                           color: Colorscontainer.greenColor,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.arrow_forward_ios, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ShoesPage extends StatelessWidget {
//   const ShoesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colorscontainer.greenColor,
//       child: Center(
//         child: Text(
//           'Shoes Page',
//           style: TextStyle(fontSize: 24.sp, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// class TShirtPage extends StatelessWidget {
//   const TShirtPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colorscontainer.greenColor,
//       child: Center(
//         child: Text(
//           'T-Shirt Page',
//           style: TextStyle(fontSize: 24.sp, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// class FlowerPage extends StatelessWidget {
//   const FlowerPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colorscontainer.greenColor,
//       child: Center(
//         child: Text(
//           'Flower Page',
//           style: TextStyle(fontSize: 24.sp, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
