import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ===================================================================
// 1. MODEL DATA
// ===================================================================

/// Kelas untuk merepresentasikan produk
class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

/// Kelas untuk merepresentasikan item di keranjang
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

// ===================================================================
// 2. STATE MANAGEMENT (MENGGUNAKAN PROVIDER)
// ===================================================================

/// Model yang mengelola state keranjang belanja (Cart)
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalCartPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(Product product) {
    var existingItem = _items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      existingItem.quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }
}

// ===================================================================
// 3. DATA DUMMY
// ===================================================================

final List<Product> dummyProducts = [
  Product(
    id: 1,
    name: 'T-Shirt Kasual',
    price: 150000.0,
    imageUrl: 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?q=80&w=1972&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description: 'Kaos katun 100% premium dengan desain minimalis. Nyaman dan adem dipakai sehari-hari.',
  ),
  Product(
    id: 2,
    name: 'Sneakers Putih',
    price: 350000.0,
    imageUrl: 'https://images.unsplash.com/photo-1549298828-44431f4a9b4d?q=80&w=2000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description: 'Sepatu sneakers klasik berwarna putih. Cocok untuk segala acara. Sol anti-slip.',
  ),
  Product(
    id: 3,
    name: 'Jam Tangan Digital',
    price: 225000.0,
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1999&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description: 'Jam tangan digital anti air dengan fitur stopwatch dan alarm. Desain sporty.',
  ),
  Product(
    id: 4,
    name: 'Tas Ransel Laptop',
    price: 400000.0,
    imageUrl: 'https://images.unsplash.com/photo-1550008892-d66827011d67?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    description: 'Tas ransel berkapasitas besar dengan kompartemen khusus laptop 15 inci. Bahan kuat dan tahan lama.',
  ),
];

// ===================================================================
// 4. MAIN APP DAN NAVIGASI
// ===================================================================

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Flutter',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/cart': (context) => CartScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}

/// Halaman Utama dengan Bottom Navigation Bar
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Toko',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ===================================================================
// 5. HALAMAN UTAMA (SCREENS)
// ===================================================================

/// Halaman Daftar Produk
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Produk Pilihan'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.items.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: dummyProducts.length,
        itemBuilder: (context, index) {
          final product = dummyProducts[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}

/// Widget untuk tampilan setiap produk dengan Hero Animation
class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: product);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                // Hero Widget untuk transisi gambar
                child: Hero(
                  tag: 'product-${product.id}', // Tag unik untuk Hero
                  child: Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.indigo, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Halaman Detail Produk dengan Hero Animation
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Widget untuk transisi gambar
            Hero(
              tag: 'product-${product.id}', // Tag harus sama dengan di ProductCard
              child: Image.network(
                product.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 300, color: Colors.grey[200], child: Center(child: Icon(Icons.broken_image, size: 80))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 24, color: Colors.indigo),
                  ),
                  Divider(height: 30),
                  Text(
                    'Deskripsi Produk',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add_shopping_cart),
                      label: Text('Tambah ke Keranjang', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        cart.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} ditambahkan ke keranjang!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Halaman Keranjang Belanja
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Keranjang Belanja'),
          ),
          body: cart.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
                      SizedBox(height: 10),
                      Text('Keranjang Anda kosong.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.items.length,
                        // Menambahkan FadeTransition untuk setiap item keranjang
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return _AnimatedCartItemTile(item: item, cart: cart);
                        },
                      ),
                    ),
                    _CheckoutBar(cart: cart),
                  ],
                ),
        );
      },
    );
  }
}

/// Widget untuk item di keranjang dengan Fade Transition
class _AnimatedCartItemTile extends StatefulWidget {
  final CartItem item;
  final CartModel cart;

  _AnimatedCartItemTile({required this.item, required this.cart});

  @override
  __AnimatedCartItemTileState createState() => __AnimatedCartItemTileState();
}

class __AnimatedCartItemTileState extends State<_AnimatedCartItemTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    _controller.forward(); // Mulai animasi fade-in
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ListTile(
        leading: Image.network(widget.item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(widget.item.product.name),
        subtitle: Text('Rp ${widget.item.product.price.toStringAsFixed(0)} x ${widget.item.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () => widget.cart.decreaseQuantity(widget.item),
            ),
            Text('${widget.item.quantity}', style: TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => widget.cart.increaseQuantity(widget.item),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => widget.cart.removeFromCart(widget.item),
            ),
          ],
        ),
      ),
    );
  }
}


/// Widget bar untuk total dan tombol checkout
class _CheckoutBar extends StatelessWidget {
  final CartModel cart;

  _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                'Rp ${cart.totalCartPrice.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (cart.items.isNotEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Checkout berhasil! Total: Rp ${cart.totalCartPrice.toStringAsFixed(0)}')),
                  );
                  // Di sini Anda bisa menambahkan logika untuk mengosongkan keranjang setelah checkout
                  // cart.clearCart(); // Jika Anda menambahkan method ini di CartModel
                }
              },
              child: Text(
                'Lanjutkan ke Pembayaran',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Halaman Akun (hanya placeholder)
class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akun Saya'),
      ),
      body: Center(
        child: Text('Halaman Akun. Fitur lain akan ditambahkan di sini.', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
