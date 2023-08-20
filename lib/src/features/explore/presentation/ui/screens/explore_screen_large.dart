import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';

class ExploreScreenLarge extends StatefulWidget {
  const ExploreScreenLarge({super.key});

  @override
  State<ExploreScreenLarge> createState() => _ExploreScreenLargeState();
}

class _ExploreScreenLargeState extends State<ExploreScreenLarge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.router.replace(const ExploreRouteSmall());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutoRouter(
      placeholder: (context) => const SizedBox.shrink(),
    );
  }
}
