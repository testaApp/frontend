import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../localization/demo_localization.dart';
import '../../constants/text_utils.dart';

class GroupRow extends StatelessWidget {
  const GroupRow({super.key, required this.idx, this.name});
  final int idx;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final displayName = name != null && name!.contains('Group')
        ? name!.replaceAll('Group', DemoLocalizations.group)
        : name ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 0, 0),
      child: Text(
        displayName,
        style: TextUtils.setTextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
