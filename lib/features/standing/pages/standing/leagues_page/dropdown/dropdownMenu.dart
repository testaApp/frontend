import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/shared/constants/text_utils.dart';

class CustomDropdownButton extends StatelessWidget {
  final List<String> dpMenuItems;
  final int selectedIndex;
  final Function(String?) onChanged;

  const CustomDropdownButton({
    super.key,
    required this.dpMenuItems,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color.fromARGB(255, 47, 45, 45);

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        customButton: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          constraints: BoxConstraints(maxWidth: 200.w),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  dpMenuItems[selectedIndex],
                  maxLines: 1,
                  style: TextUtils.setTextStyle(
                    fontSize: 11.sp,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 17.sp,
                color: textColor.withOpacity(0.7),
              ),
            ],
          ),
        ),
        items: dpMenuItems
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 180.w),
                    child: Text(
                      item,
                      maxLines: 1,
                      style: TextUtils.setTextStyle(
                        fontSize: 11.sp,
                        color: textColor,
                        fontWeight: item == dpMenuItems[selectedIndex]
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ))
            .toList(),
        value: dpMenuItems[selectedIndex],
        onChanged: onChanged,
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200.h,
          padding: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          offset: const Offset(0, -4),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 30.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
        ),
        buttonStyleData: ButtonStyleData(
          height: 30.h,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.grey.withOpacity(0.1);
            }
            return null;
          }),
        ),
      ),
    );
  }
}
