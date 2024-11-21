// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(const BuburAyamApp());

class BuburAyamApp extends StatelessWidget {
  const BuburAyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<String> cart = []; // Menyimpan cart di HomeScreen

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _clearCart() {
    setState(() {
      cart.clear(); // Hapus semua item di keranjang
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MenuScreen(onAddToCart: (item) {
        setState(() {
          cart.add(item); // Menambah item ke cart global
        });
        Fluttertoast.showToast(msg: "$item ditambahkan ke keranjang");
      }),
      CartScreen(cart: cart, onClearCart: _clearCart), // Tambahkan callback
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mang Ayi App'),
        actions: [
          DropdownButton<String>(
            onChanged: (String? newValue) {
              Fluttertoast.showToast(msg: "Menu dipilih: $newValue");
            },
            items: <String>['Profil', 'Pengaturan', 'Bantuan']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MenuScreen extends StatefulWidget {
  final Function(String) onAddToCart;

  const MenuScreen({super.key, required this.onAddToCart});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    List<String> menuItems = [
      'Bubur Ayam Original',
      'Bubur Ayam Spesial',
      'Bubur Ayam Legendaris'
    ];

    return Column(
      children: [
        // Tombol untuk toggle antara ListView dan GridView
        SwitchListTile(
          title: Text(_isGridView ? 'Tampilan Grid' : 'Tampilan List'),
          value: _isGridView,
          onChanged: (value) {
            setState(() {
              _isGridView = value;
            });
          },
        ),
        Expanded(
          child: _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return MenuItem(
                      name: menuItems[index],
                      onAddToCart: widget.onAddToCart,
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return MenuItem(
                      name: menuItems[index],
                      onAddToCart: widget.onAddToCart,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class MenuItem extends StatelessWidget {
  final String name;
  final Function(String) onAddToCart;

  const MenuItem({super.key, required this.name, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, textAlign: TextAlign.center),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () => onAddToCart(name),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<String> cart;
  final VoidCallback onClearCart; // Callback untuk menghapus data

  const CartScreen({super.key, required this.cart, required this.onClearCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Anda'),
      ),
      body: cart.isEmpty
          ? const Center(child: Text('Keranjang Anda kosong'))
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cart[index]),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              // Tampilkan dialog konfirmasi
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi"),
                  content: const Text(
                      "Apakah Anda yakin ingin mengonfirmasi pesanan?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Tutup dialog
                      },
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        onClearCart(); // Hapus data keranjang
                        Navigator.pop(context); // Tutup dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Pesanan telah dikonfirmasi!')),
                        );
                      },
                      child: const Text("Ya"),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Konfirmasi Pesanan'),
          ),
        ),
      ),
    );
  }
}

// SettingsScreen dengan DatePicker dan TimePicker
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedDate; // Variabel untuk menyimpan tanggal yang dipilih
  String? _selectedTime; // Variabel untuk menyimpan waktu yang dipilih

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (selectedDate != null) {
                setState(() {
                  // Format tanggal yang dipilih
                  _selectedDate =
                      "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
                });
              }
            },
            child: const Text("Pilih Tanggal"),
          ),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Tanggal dipilih: $_selectedDate",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 16), // Jarak antara dua tombol
          ElevatedButton(
            onPressed: () async {
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (selectedTime != null) {
                setState(() {
                  // Format waktu yang dipilih
                  _selectedTime = "${selectedTime.hour}:${selectedTime.minute}";
                });
              }
            },
            child: const Text("Pilih Waktu"),
          ),
          if (_selectedTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Waktu dipilih: $_selectedTime",
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
