import 'package:flutter/material.dart';

class BookToolbar extends StatefulWidget {
  const BookToolbar({super.key});

  @override
  State<StatefulWidget> createState() => BookToolbarState();
}

class BookToolbarState extends State<BookToolbar> {
  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.secondary,
      );
}
