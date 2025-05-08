import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const FashionShopApp(),
    ),
  );
}

class FashionShopApp extends StatelessWidget {
  const FashionShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fashion Shop',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const ShopHomePage(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> sizes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sizes,
  });
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final String size;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.size,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalAmount => _items.values
      .fold(0.0, (sum, item) => sum + item.price * item.quantity);

  void addItem(String id, String name, double price, String imageUrl, String size) {
    final key = '$id-$size';
    if (_items.containsKey(key)) {
      _items.update(
        key,
            (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
          size: existing.size,
        ),
      );
    } else {
      _items[key] = CartItem(
        id: key,
        name: name,
        price: price,
        quantity: 1,
        imageUrl: imageUrl,
        size: size,
      );
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}


final List<Product> sampleProducts = [
  Product(
    id: 'p1',
    name: 'Boho Top',
    description: 'Perfect for beach vibes.',
    price: 39.99,
    imageUrl: 'https://img.ltwebstatic.com/images3_pi/2024/10/31/d2/173035565219a036416cf152fbf7d487424e1ed8e9_thumbnail_405x.webp',
    sizes: ['S', 'M', 'L'],
  ),
  Product(
    id: 'p2',
    name: 'Cargo Pants',
    description: 'Utility wear with style.',
    price: 59.99,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Cargo_pant%2C_female.JPG/640px-Cargo_pant%2C_female.JPG',
    sizes: ['M', 'L', 'XL'],
  ),
  Product(
    id: 'p3',
    name: 'Denim Jacket',
    description: 'Classic denim for any season.',
    price: 89.99,
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPB4OaVH35tjW9w5o0NWomlGFOUpvlfWUejsgNFoZH2x57ljessVhbYR0&s',
    sizes: ['S', 'M', 'L', 'XL'],
  ),
  Product(
    id: 'p4',
    name: 'Summer Dress',
    description: 'Light and breezy for sunny days.',
    price: 49.99,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Christian_Dior_Dress_indianapolis.jpg/640px-Christian_Dior_Dress_indianapolis.jpg',
    sizes: ['S', 'M', 'L'],
  ),
];

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  Product? selectedProduct;
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Boutique'),
        backgroundColor: Colors.pink,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCartSheet(context, cart),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.black,
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: selectedProduct == null
          ? ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleProducts.length,
        itemBuilder: (_, i) => ProductCard(
          product: sampleProducts[i],
          onTap: (product) {
            setState(() {
              selectedProduct = product;
              selectedSize = product.sizes.first;
            });
          },
        ),
      )
          : ProductDetailView(
        product: selectedProduct!,
        selectedSize: selectedSize,
        onSizeSelected: (size) => setState(() => selectedSize = size),
        onAddToCart: () {
          if (selectedSize != null) {
            cart.addItem(
              selectedProduct!.id,
              selectedProduct!.name,
              selectedProduct!.price,
              selectedProduct!.imageUrl,
              selectedSize!,
            );
          }
        },
        onBack: () => setState(() => selectedProduct = null),
      ),
    );
  }

  void _showCartSheet(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ...cart.items.values.map((item) => ListTile(
              leading: Image.network(
                item.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40),
              ),
              title: Text(item.name),
              subtitle: Text('Size: ${item.size} x${item.quantity}'),
              trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
            )),
            const Divider(),
            Text('Total: \$${cart.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    cart.clearCart();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cart cleared!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: const Text('Clear Cart'),
                ),
                ElevatedButton(
                  onPressed: cart.itemCount == 0
                      ? null
                      : () {
                    cart.clearCart();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order Placed successful!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final void Function(Product) onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onTap(product),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                width: 120,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 120),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailView extends StatelessWidget {
  final Product product;
  final String? selectedSize;
  final void Function(String) onSizeSelected;
  final VoidCallback onAddToCart;
  final VoidCallback onBack;

  const ProductDetailView({
    super.key,
    required this.product,
    required this.selectedSize,
    required this.onSizeSelected,
    required this.onAddToCart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {

    final isWeb = kIsWeb;
    final maxImageWidth = isWeb ? 400.0 : double.infinity;
    final imageHeight = isWeb ? 450.0 : 420.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxImageWidth,
                  maxHeight: 600,
                ),
                child: Image.network(
                  product.imageUrl,
                  width: maxImageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(product.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: product.sizes.map((size) {
              final selected = size == selectedSize;
              return ChoiceChip(
                label: Text(size),
                selected: selected,
                onSelected: (_) => onSizeSelected(size),
                selectedColor: Colors.pink,
                backgroundColor: Colors.grey[300],
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onAddToCart,
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
