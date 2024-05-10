import 'package:expense_manager/master_password/master_password_screen.dart';
import 'package:flutter/material.dart';

import '../../utils/helper.dart';
import '../../utils/my_shared_preferences.dart';


class RestoreDialog {

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.grey,
    Colors.blueGrey,
    Colors.white,
  ];

  Color? isSelectedColor;

  Future<void> showRestoreDialog({required BuildContext context}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              title: const Text(
                'Select restore resource',
                style: TextStyle(fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_to_drive_outlined),
                    title: const Text('Drive'),
                    onTap: () async {
                      // Handle selection
                      String? fileId = await MySharedPreferences.instance.getStringValuesSF("fileId");
                      if (fileId != null) {
                        await MasterPasswordDialog().downloadCsvFileFromDrive(fileId);
                      } else {
                        Helper.showToast('File Id not found upload your file in drive');
                      }
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: const Text('Csv file'),
                    onTap: () {
                      // Handle selection
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.file_open_rounded),
                    title: const Text('Db file'),
                    onTap: () {
                      // Handle selection
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
