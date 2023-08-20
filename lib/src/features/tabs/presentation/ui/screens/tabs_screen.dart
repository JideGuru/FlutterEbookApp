import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch providers so they don't get disposed
    ref.watch(homeFeedNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        return await ExitModalDialog.show(context: context) ?? false;
      },
      child: const ResponsiveWidget(
        smallScreen: TabsScreenSmall(),
        largeScreen: TabsScreenLarge(),
      ),
    );
  }
}
