import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final List<DrawerItem> drawerItems;
  final Function(int)? onItemTapped;
  final int? currentIndex; // Tambahkan parameter currentIndex

  const AppDrawer({
    super.key, 
    required this.drawerItems,
    this.onItemTapped,
    this.currentIndex, // Optional current index
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ...drawerItems.map((item) => ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            selected: drawerItems.indexOf(item) == currentIndex, // Tambahkan efek selected
            selectedTileColor: Colors.grey.shade200,
            onTap: () {
              // Tutup drawer
              Navigator.of(context).pop();
              
              // Panggil callback navigasi jika disediakan
              if (onItemTapped != null) {
                onItemTapped!(drawerItems.indexOf(item));
              }
            },
          )),
        ],
      ),
    );
  }
}

class DrawerItem {
  final String title;
  final IconData icon;

  const DrawerItem({
    required this.title,
    required this.icon,
  });
}