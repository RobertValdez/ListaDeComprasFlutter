import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lista_de_compras/screens/maint_products/maint_product_add.dart';
import 'package:lista_de_compras/screens/maint_products/maint_product_edit.dart';
import 'package:lista_de_compras/screens/maps_show/map_screen_show.dart';

class Product {
  String name;
  String category;
  bool isChecked;
  bool canView;

  Product({
    required this.name,
    required this.category,
    this.isChecked = false,
    this.canView = true,
  });
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

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [ShoppingListScreen(), MapScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Lista"),
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

// ignore: use_key_in_widget_constructors
class ShoppingListScreen extends StatelessWidget {
  final ShoppingListController controller = Get.put(ShoppingListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de compras",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.5,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.import_export),
              iconSize: 30.0,
              color: Colors.black,
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 107, 196, 110),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar producto...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),
          Expanded(
            child: Obx(() {
              var filteredProducts =
                  controller.products.where((product) {
                    return product.name.toLowerCase().contains(
                      controller.searchQuery.value.toLowerCase(),
                    );
                  }).toList();

              var groupedProducts = <String, List<Product>>{};
              for (var product in filteredProducts) {
                if (!groupedProducts.containsKey(product.category)) {
                  groupedProducts[product.category] = [];
                }
                groupedProducts[product.category]!.add(product);
              }

              return Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 8.0,
                ),
                child: ListView(
                  children:
                      groupedProducts.entries.map((entry) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 5.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...entry.value.map((product) {
                                int index = controller.products.indexOf(
                                  product,
                                );
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const MaintProductEdit(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 2.0,
                                        bottom: 5.0,
                                      ),
                                      child: ListTile(
                                        leading: Checkbox(
                                          value: product.isChecked,
                                          onChanged:
                                              (value) =>
                                                  controller.toggleCheck(index),
                                          activeColor: Colors.green,
                                        ),
                                        title: Text(product.name),
                                        trailing: ElevatedButton(
                                          onPressed:
                                              product.canView
                                                  ? () => _showProductDetails(
                                                    context,
                                                    product,
                                                  )
                                                  : null,
                                          child: Icon(Icons.remove_red_eye),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaintProductAdd(),
                ),
              ),
            },
        child: Icon(Icons.add),
      ),
    );
  }

  /// Método para mostrar detalles del producto
  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
  // ignore: unused_element
  void _showAddProductDialog(BuildContext context) {
    TextEditingController productController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Agregar Producto"),
            content: Column(
              //mainAxisSize sirve para especificar el tamaño total del Widget
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: productController,
                    decoration: InputDecoration(
                      hintText: "Nombre del producto",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      hintText: "Categoría",
                      border: OutlineInputBorder(),
                    ),
                  ),
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
                  if (productController.text.isNotEmpty &&
                      categoryController.text.isNotEmpty) {
                    controller.addProduct(
                      productController.text,
                      categoryController.text,
                    );
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
