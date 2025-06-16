
import 'package:flutter/material.dart';

class MaintProductEdit extends StatefulWidget {
  final Function(String, String, String, String, String) onEditProduct;

  const MaintProductEdit({super.key, required this.onEditProduct});

  @override
  State<MaintProductEdit> createState() => _MaintProductEditState();
}

class _MaintProductEditState extends State<MaintProductEdit> {
  //Nombre P
  //Alternativa si no hay
  // Categoria
  //Cantidad
  //Ubicacion
  //´´Para modificar: Nota del Comprador

  String? selectedCategory;
  List<String> categorias = ['Bebidas', 'Snacks', 'Frutas', 'Lácteos'];

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productController = TextEditingController();
  final TextEditingController _altproductController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  void _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final String productName = _productController.text.trim();
    final category = selectedCategory;
    final String altproduct = _altproductController.text.trim();
    final String cantidad = _cantidadController.text.trim();
    final String ubicacion = _ubicacionController.text.trim();

    widget.onEditProduct(
      productName,
      category!,
      altproduct,
      cantidad,
      ubicacion,
    );
    Navigator.pop(context); // Volver a la pantalla anterior

    setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 5));
    setState(() => isLoading = false);
  }

  //Validar en la BD para evitar repeticiones de Productos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agregar Producto")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campo de nombre del producto
              TextFormField(
                controller: _productController,
                decoration: InputDecoration(
                  labelText: "Nombre del producto",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Este campo es obligatorio";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              // Dropdown de categoría
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Categoría",
                  border: OutlineInputBorder(),
                ),
                value: selectedCategory,
                items:
                    categorias.map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? "Selecciona una categoría" : null,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _altproductController,
                decoration: InputDecoration(
                  labelText: "Alternativa (si no hay)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Este campo es obligatorio";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _cantidadController,
                decoration: InputDecoration(
                  labelText: "Cantidad",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Este campo es obligatorio";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _ubicacionController,
                decoration: InputDecoration(
                  labelText: "Ubicación",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),

      /// ✅ Botón fijo en la parte inferior
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          top: 25.0,
          left: 25.0,
          right: 25.0,
          bottom: 35.0,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => isLoading ? null : _submitProduct(),
            child: Text(
              "Guardar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
