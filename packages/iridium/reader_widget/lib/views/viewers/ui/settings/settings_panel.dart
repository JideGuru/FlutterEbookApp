import 'package:flutter/material.dart';
import 'package:iridium_reader_widget/views/viewers/ui/settings/advanced_settings_panel.dart';
import 'package:iridium_reader_widget/views/viewers/ui/settings/general_settings_panel.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class SettingsPanel extends StatefulWidget {
  final ReaderContext readerContext;
  final ViewerSettingsBloc viewerSettingsBloc;
  final ReaderThemeBloc readerThemeBloc;

  const SettingsPanel({
    super.key,
    required this.readerContext,
    required this.viewerSettingsBloc,
    required this.readerThemeBloc,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 400.0,
        child: Card(
          elevation: 8.0,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: TabBar(
                labelColor: Theme.of(context).colorScheme.onPrimary,
                controller: _tabController,
                tabs: const [
                  Tab(text: "SETTINGS"),
                  Tab(text: "ADVANCED"),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                GeneralSettingsPanel(
                  readerContext: widget.readerContext,
                  viewerSettingsBloc: widget.viewerSettingsBloc,
                  readerThemeBloc: widget.readerThemeBloc,
                ),
                AdvancedSettingsPanel(
                  readerContext: widget.readerContext,
                  readerThemeBloc: widget.readerThemeBloc,
                ),
              ],
            ),
          ),
        ),
      );
}
