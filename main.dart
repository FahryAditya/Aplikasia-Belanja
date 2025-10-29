
// FILE: lib/main.dart // Modern UI + animations: Grid view, Hero transition, animated add-to-cart badge, Lottie checkout success

import 'package:flutter/material.dart'; import 'package:provider/provider.dart'; import 'package:lottie/lottie.dart';

void main() { runApp(const MyApp()); }

class MyApp extends StatelessWidget { const MyApp({super.key});

@override Widget build(BuildContext context) { return ChangeNotifierProvider( create: (_) => CartModel(), child: MaterialApp( debugShowCheckedModeBanner: false, title: 'Belanja Modern', theme: ThemeData( primarySwatch: Colors.teal, useMaterial3: true, cardTheme: CardTheme( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 6, ), ), home: const ProductGridPage(), ), ); } }

// --- Models class Product { final String id; final String name; final String subtitle; final double price; final String imageUrl;

Product({required this.id, required this.name, required this.subtitle, required this.price, required this.imageUrl}); }

final sampleProducts = List<Product>.generate( 8, (i) => Product( id: 'p$i', name: ['Kopi Luwak','Tas Anyaman','Sandal Tradisional','Album Foto','Speaker Mini','Lampu Hias','Topi Kanvas','Notebook'][i % 8], subtitle: 'Deskripsi singkat produk nomor $i', price: 35000.0 + i * 25000, imageUrl: 'https://picsum.photos/seed/product$i/600/400', ), );

class CartItem { final Product product; int qty; CartItem({required this.product, this.qty = 1}); }

class CartModel extends ChangeNotifier { final Map<String, CartItem> _items = {};

List<CartItem> get items => _items.values.toList(); int get totalItems => _items.values.fold(0, (s, e) => s + e.qty); double get totalPrice => _items.values.fold(0.0, (s, e) => s + e.qty * e.product.price);

void add(Product p) { if (_items.containsKey(p.id)) { _items[p.id]!.qty += 1; } else { _items[p.id] = CartItem(product: p, qty: 1); } notifyListeners(); }

void remove(Product p) { if (!_items.containsKey(p.id)) return; if (_items[p.id]!.qty > 1) { _items[p.id]!.qty -= 1; } else { _items.remove(p.id); } notifyListeners(); }

void clear() { _items.clear(); notifyListeners(); } }

// --- Pages class ProductGridPage extends StatefulWidget { const ProductGridPage({super.key});

@override State<ProductGridPage> createState() => _ProductGridPageState(); }

class _ProductGridPageState extends State<ProductGridPage> with SingleTickerProviderStateMixin { late final AnimationController _controller;

@override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800)); _controller.forward(); }

@override void dispose() { _controller.dispose(); super.dispose(); }

@override Widget build(BuildContext context) { final cart = context.watch<CartModel>();

return Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: const Text('Belanja Modern', style: TextStyle(fontWeight: FontWeight.bold)),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage())),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 28),
              Positioned(
                right: 0,
                top: 6,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: cart.totalItems > 0
                      ? _Badge(count: cart.totalItems, key: ValueKey(cart.totalItems))
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      )
    ],
  ),
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFF8FBFF), Color(0xFFE8FFF6)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            const Text('Produk Pilihan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.77,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: sampleProducts.length,
                itemBuilder: (context, index) {
                  final product = sampleProducts[index];
                  final animation = CurvedAnimation(parent: _controller, curve: Interval((index / sampleProducts.length), 1.0, curve: Curves.easeOut));
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: ProductCardModern(product: product),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    ),
  ),
);

} }

class _Badge extends StatelessWidget { final int count; const _Badge({required this.count, super.key});

@override Widget build(BuildContext context) { return Material( elevation: 2, shape: const CircleBorder(), color: Colors.red, child: Padding( padding: const EdgeInsets.all(6.0), child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), ), ); } }

class ProductCardModern extends StatelessWidget { final Product product; const ProductCardModern({required this.product, super.key});

@override Widget build(BuildContext context) { final cart = context.read<CartModel>();

return GestureDetector(
  onTap: () => Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, a, b) => ProductDetailPage(product: product), transitionsBuilder: (context, anim, sec, child) {
    return FadeTransition(opacity: anim, child: child);
  })),
  child: Card(
    clipBehavior: Clip.hardEdge,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'product_image_${product.id}',
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(product.imageUrl, fit: BoxFit.cover, loadingBuilder: (c, w, p) => p == null ? w : const Center(child: CircularProgressIndicator())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(product.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rp ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () {
                      cart.add(product);
                      // show subtle animation: a SnackBar + effect
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} ditambahkan')));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: const LinearGradient(colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)])),
                      child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    ),
  ),
);

} }

class ProductDetailPage extends StatelessWidget { final Product product; const ProductDetailPage({required this.product, super.key});

@override Widget build(BuildContext context) { final cart = context.watch<CartModel>();

return Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black87),
    surfaceTintColor: Colors.transparent,
  ),
  body: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Hero(
          tag: 'product_image_${product.id}',
          child: Image.network(product.imageUrl, height: 300, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Rp ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.teal)),
              const SizedBox(height: 12),
              Text(product.subtitle, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        cart.add(product);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ditambahkan ke keranjang')));
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Tambah ke Keranjang'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              const Text('Informasi Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text('• Bahan: Berkualitas

• Garansi: 30 hari • Berat: 250g', style: TextStyle(height: 1.6)), const SizedBox(height: 40), ], ), ) ], ), ), floatingActionButton: AnimatedSwitcher( duration: const Duration(milliseconds: 400), transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child), child: cart.totalItems > 0 ? FloatingActionButton.extended( key: ValueKey(cart.totalItems), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage())), label: Text('Keranjang (${cart.totalItems})'), icon: const Icon(Icons.shopping_cart), ) : FloatingActionButton( key: const ValueKey('fav'), onPressed: () {}, child: const Icon(Icons.favorite), ), ), ); } }

class CartPage extends StatefulWidget { const CartPage({super.key});

@override State<CartPage> createState() => _CartPageState(); }

class _CartPageState extends State<CartPage> { bool _showSuccess = false;

@override Widget build(BuildContext context) { final cart = context.watch<CartModel>();

return Scaffold(
  appBar: AppBar(title: const Text('Keranjang')),
  body: cart.items.isEmpty
      ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 160, child: Lottie.network('https://assets8.lottiefiles.com/packages/lf20_kq5m3z2j.json')),
              const Text('Keranjang kosong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        )
      : Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(item.product.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
                      title: Text(item.product.name),
                      subtitle: Text('Rp ${item.product.price.toStringAsFixed(0)} x ${item.qty}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(onPressed: () => cart.remove(item.product), icon: const Icon(Icons.remove_circle_outline)),
                        Text(item.qty.toString()),
                        IconButton(onPressed: () => cart.add(item.product), icon: const Icon(Icons.add_circle_outline)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Total: Rp ${cart.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // simulate checkout flow
                      setState(() => _showSuccess = true);
                      await Future.delayed(const Duration(milliseconds: 800));
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: SizedBox(height: 200, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            SizedBox(height: 120, child: Lottie.network('https://assets8.lottiefiles.com/packages/lf20_jbrw3hcz.json', repeat: false)),
                            const SizedBox(height: 8),
                            const Text('Pembayaran Berhasil!', style: TextStyle(fontWeight: FontWeight.bold)),
                          ])),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                        ),
                      );

                      cart.clear();
                      setState(() => _showSuccess = false);
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Checkout Sekarang'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => cart.clear(), child: const Text('Kosongkan Keranjang')),
                ],
              ),
            )
          ],
        ),
);

} }

// End of file
