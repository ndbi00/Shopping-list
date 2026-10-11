import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final url = Uri.https(
      'flutter-prep-854b0-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        throw Exception('Failed to load groceries.');
      }

      final List<GroceryItem> loadedItems = [];

      if (response.body != 'null') {
        final Map<String, dynamic> listData =
            json.decode(response.body);

        for (final item in listData.entries) {
          final category = categories.values.firstWhere(
            (category) => category.title == item.value['category'],
          );

          loadedItems.add(
            GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category,
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _groceryItems.clear();
        _groceryItems.addAll(loadedItems);
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Could not load groceries. Please try again later.';
      });
    }
  }

  Future<void> _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (!mounted || newItem == null) return;

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  Future<void> _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'flutter-prep-854b0-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        throw Exception('Failed to delete grocery.');
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        final restoreIndex = index > _groceryItems.length
            ? _groceryItems.length
            : index;

        _groceryItems.insert(restoreIndex, item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete item. It was restored.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet!'),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) {
          final item = _groceryItems[index];

          return Dismissible(
            key: ValueKey(item.id),
            onDismissed: (direction) {
              _removeItem(item);
            },
            child: ListTile(
              title: Text(item.name),
              leading: Container(
                width: 24,
                height: 24,
                color: item.category.color,
              ),
              trailing: Text(item.quantity.toString()),
            ),
          );
        },
      );
    }

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _isLoading || _error != null ? null : _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}