import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';

class ExitModalDialog extends StatelessWidget {
  const ExitModalDialog({super.key});

  static Future<bool?> show({required BuildContext context}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ExitModalDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlert(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 15.0),
            Text(
              Strings.appName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 25.0),
            const Text(
              'Are you sure you want to quit?',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                  width: 130.0,
                  child: TextButton(
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: context.theme.colorScheme.secondary,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(
                  height: 40.0,
                  width: 130.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: context.theme.colorScheme.secondary,
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => exit(0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
