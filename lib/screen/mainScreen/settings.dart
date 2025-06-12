import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/screen/mainScreen/settings/aboutTab.dart';
import 'package:quirzy/screen/mainScreen/settings/accountTab.dart';
import 'package:quirzy/screen/mainScreen/settings/preferencesTab.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Account'),
            Tab(text: 'Preferences'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AccountTab(),
          PreferencesTab(),
          AboutTab(),
        ],
      ),
    );
  }
}