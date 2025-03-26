import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
        title: Text("Lista de Compras"),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.import_export),
              iconSize: 30.0,
            ),
          ),
        ],
      ),
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
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: ListView(
                  children:
                      groupedProducts.entries.map((entry) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 5.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black, width: 1.0
                            ),
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
                                return ListTile(
                                  leading: Checkbox(
                                    value: product.isChecked,
                                    onChanged:
                                        (value) =>
                                            controller.toggleCheck(index),
                                  ),
                                  title: GestureDetector(
                                    onTap: () {
                                      print("Prueba");
                                    },
                                    child: Text(product.name),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed:
                                        product.canView
                                            ? () => _showProductDetails(
                                              context,
                                              product,
                                            )
                                            : null,
                                    child: Text("Ver"),
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
        onPressed: () => _showAddProductDialog(context),
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

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(
            18.222610,
            -71.124255,
          ), // Centro inicial del mapa
          initialZoom: 20, // Nivel de zoom inicial
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all,
          ), // Habilitar interactividad
        ),
        children: [
          // Capa de mosaicos (tiles) de OpenStreetMap
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName:
                'com.example.app', // Ajuste recomendado para evitar errores
          ),
          // Capa de marcadores
          MarkerLayer(
            markers: _buildMarkers(
              context,
            ), // Se usa una función para generar los marcadores
          ),
        ],
      ),
    );
  }

  // Función para generar los marcadores
  List<Marker> _buildMarkers(BuildContext context) {
    return [
      _createMarker(
        context,
        LatLng(18.222610, -71.124255),
        "Información del Producto",
        "Saco de Arroz Campo, 5 sacos de 20 lbs.",
        Colors.red,
        false,
      ),
      _createMarker(
        context,
        LatLng(18.222081, -71.124362),
        "Información del Producto",
        "Salsa de Tomate #5 latas Pequeñas.",
        Colors.red,
        false,
      ),

      _createMarker(
        context,
        LatLng(18.222005, -71.124201),
        "Información del Producto",
        "Salsa de Tomate #5 latas Pequeñas.",
        Colors.green,
        true,
      ),

      _createMarker(
        context,
        LatLng(18.222336, -71.124163),
        "Información del Producto",
        "Salsa de Tomate #5 latas Pequeñas.",
        Colors.green,
        true,
      ),
    ];
  }

  // Función para crear un marcador con información
  Marker _createMarker(
    BuildContext context,
    LatLng point,
    String title,
    String content,
    Color color,
    bool checkedList,
  ) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent, // Fondo transparente
              elevation: 0,
              margin: const EdgeInsets.only(
                bottom: 650,
                left: 20,
                right: 20,
              ), // Margen personalizado
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 60),
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900], // Color de fondo del snackbar
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar circular con icono
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          Colors.blue[100], // Color del fondo del avatar
                      child: Icon(
                        checkedList
                            ? Icons.check_circle
                            : Icons.info, // Ícono dinámico según estado
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Texto del mensaje
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            content,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Botón de acción
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      child: const Text(
                        "Cerrar",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      child: const Text(
                        "Marcar",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: Icon(
          checkedList
              ? Icons.where_to_vote
              : Icons.where_to_vote, // Ícono dinámico
          color: color,
          size: 40,
        ),
      ),
    );
  }
}
