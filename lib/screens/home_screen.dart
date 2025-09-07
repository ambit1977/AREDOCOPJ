import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';
import 'ai_test_screen.dart';

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
  PackageInfo _packageInfo = PackageInfo(
    appName: '持ち物管理',
    packageName: 'unknown',
    version: 'unknown',
    buildNumber: 'unknown',
  );

  @override
  void initState() {
    super.initState();
    debugPrint('HomeScreen: initState開始');
    
    try {
      _tabController = TabController(length: 3, vsync: this);
      debugPrint('HomeScreen: TabController初期化完了');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('HomeScreen: PostFrameCallback実行開始');
        try {
          context.read<ItemProvider>().loadItems();
          debugPrint('HomeScreen: アイテムロード開始');
          _initPackageInfo();
          debugPrint('HomeScreen: パッケージ情報初期化開始');
        } catch (e, stackTrace) {
          debugPrint('HomeScreen PostFrameCallback エラー: $e');
          debugPrint('スタックトレース: $stackTrace');
        }
      });
      
      debugPrint('HomeScreen: initState完了');
    } catch (e, stackTrace) {
      debugPrint('HomeScreen initState エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
    }
  }
  
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AITestScreen(),
                ),
              );
            },
            tooltip: 'AI機能テスト',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showVersionInfo(context),
          ),
        ],
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
  
  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アプリ情報'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('アプリ名', _packageInfo.appName),
            const SizedBox(height: 8),
            _buildInfoRow('バージョン', '${_packageInfo.version}+${_packageInfo.buildNumber}'),
            const SizedBox(height: 8),
            _buildInfoRow('パッケージ名', _packageInfo.packageName),
            const SizedBox(height: 16),
            const Text('© 2025 持ち物管理アプリ', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
