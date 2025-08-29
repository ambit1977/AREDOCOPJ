import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('持ち物管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '検索...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'すべて'),
                  Tab(text: '収納場所'),
                  Tab(text: 'カテゴリ'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, child) {
          if (itemProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllItemsTab(itemProvider),
              _buildLocationTab(itemProvider),
              _buildCategoryTab(itemProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddItemScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllItemsTab(ItemProvider itemProvider) {
    final items = _searchQuery.isEmpty
        ? itemProvider.items
        : itemProvider.searchItems(_searchQuery);

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'アイテムがありません\n右下の+ボタンで追加してください',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ItemCard(item: items[index]);
      },
    );
  }

  Widget _buildLocationTab(ItemProvider itemProvider) {
    final locations = itemProvider.locations;

    if (locations.isEmpty) {
      return const Center(
        child: Text(
          '収納場所がありません\nアイテムを追加してください',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        final items = itemProvider.getItemsByLocation(location);
        
        return Card(
          child: ExpansionTile(
            title: Text(
              location,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${items.length}個のアイテム'),
            children: items.map((item) => ItemCard(item: item)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTab(ItemProvider itemProvider) {
    final categories = itemProvider.categories;

    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'カテゴリがありません\nアイテムを追加してください',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final items = itemProvider.getItemsByCategory(category);
        
        return Card(
          child: ExpansionTile(
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${items.length}個のアイテム'),
            children: items.map((item) => ItemCard(item: item)).toList(),
          ),
        );
      },
    );
  }
}
