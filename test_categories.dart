import 'package:flutter/material.dart';
import 'package:spotnav/common/app_constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Categories Test',
      home: CategoriesTestPage(),
    );
  }
}

class CategoriesTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories Test'),
      ),
      body: ListView.builder(
        itemCount: AppConstants.categories.length,
        itemBuilder: (context, index) {
          final category = AppConstants.categories[index];
          return ListTile(
            title: Text(category),
            subtitle: Text('Category ${index + 1}'),
            onTap: () {
              print('Tapped category: $category');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: $category')),
              );
            },
          );
        },
      ),
    );
  }
} 