import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class Product {
  String name;
  String category;
  bool isChecked;
  bool canView;
  
  Product({required this.name, required this.category, this.isChecked = false, this.canView = false});
}

class ShoppingListController extends GetxController {
  var products = <Product>[].obs;
  var searchQuery = ''.obs;

  void addProduct(String name, String category) {
    if (!products.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      products.add(Product(name: name, category: category));
    }
  }

  void toggleCheck(int index) {
    products[index].isChecked = !products[index].isChecked;
    products.refresh();
  }

  void enableView(int index) {
    products[index].canView = true;
    products.refresh();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ShoppingListScreen(),
    MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Lista"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class ShoppingListScreen extends StatelessWidget {
  final ShoppingListController controller = Get.put(ShoppingListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Compras")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar producto...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),
          Expanded(
            child: Obx(() {
              var filteredProducts = controller.products.where((product) {
                return product.name.toLowerCase().contains(controller.searchQuery.value.toLowerCase());
              }).toList();

              var groupedProducts = <String, List<Product>>{};
              for (var product in filteredProducts) {
                if (!groupedProducts.containsKey(product.category)) {
                  groupedProducts[product.category] = [];
                }
                groupedProducts[product.category]!.add(product);
              }

              return ListView(
                children: groupedProducts.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.key,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...entry.value.map((product) {
                        int index = controller.products.indexOf(product);
                        return ListTile(
                          leading: Checkbox(
                            value: product.isChecked,
                            onChanged: (value) => controller.toggleCheck(index),
                          ),
                          title: GestureDetector(
                            onTap: () => controller.enableView(index),
                            child: Text(product.name),
                          ),
                          trailing: ElevatedButton(
                            onPressed: product.canView ? () => _showProductDetails(context, product) : null,
                            child: Text("Ver"),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  /// Método para mostrar detalles del producto
  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Categoría: ${product.category}"),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.to(() => MapScreen());
              },
              child: Text("Abrir Mapa"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  /// Método para agregar un producto
  void _showAddProductDialog(BuildContext context) {
    TextEditingController productController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Agregar Producto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: productController,
              decoration: InputDecoration(hintText: "Nombre del producto"),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(hintText: "Categoría"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              if (productController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                controller.addProduct(productController.text, categoryController.text);
                Navigator.pop(context);
              }
            },
            child: Text("Agregar"),
          ),
        ],
      ),
    );
  }
}


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(37.7749, -122.4194),
          zoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
        ],
      ),
    );
  }
}
