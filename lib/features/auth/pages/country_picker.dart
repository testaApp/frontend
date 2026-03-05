import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class CountryPicker extends StatefulWidget {
  CountryPicker(
      {super.key,
      this.callBackFunction,
      this.headerText,
      this.headerBackgroundColor,
      this.headerTextColor,
      required this.countryList,
      required this.selectedCountryData});

  // changed lines
  List<CountryModel> countryList;
  CountryModel? selectedCountryData;

  // changedLines
  final Function? callBackFunction;
  final String? headerText;
  final Color? headerBackgroundColor;
  final Color? headerTextColor;
  bool isInit = true;

  @override
  _CountryPickerState createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 75.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryModel>(
          value: widget.selectedCountryData,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colorscontainer.greenColor,
            size: 20.sp,
          ),
          isExpanded: true,
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          items: widget.countryList.map<DropdownMenuItem<CountryModel>>(
            (country) {
              return DropdownMenuItem<CountryModel>(
                value: country,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      country.flag!,
                      style: TextUtils.setTextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      country.dialCode!,
                      style: TextUtils.setTextStyle(
                        fontSize: 14.sp,
                        color: Colorscontainer.greenColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList(),
          onChanged: (newValue) {
            setState(() {
              widget.selectedCountryData = newValue!;
            });
            widget.callBackFunction?.call(
              newValue!.name,
              newValue.dialCode,
              newValue.flag,
            );
          },
        ),
      ),
    );
  }
}

class CountryModel {
  const CountryModel({
    @required this.name,
    @required this.dialCode,
    @required this.code,
    @required this.flag,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final flag = CountryModel.getEmojiFlag(json['code'] as String);
    return CountryModel(
      name: json['name'] as String,
      dialCode: json['dial_code'] as String,
      code: json['code'] as String,
      flag: flag,
    );
  }

  final String? name, dialCode, code, flag;

  static String getEmojiFlag(String emojiString) {
    const flagOffset = 0x1F1E6;
    const asciiOffset = 0x41;

    final firstChar = emojiString.codeUnitAt(0) - asciiOffset + flagOffset;
    final secondChar = emojiString.codeUnitAt(1) - asciiOffset + flagOffset;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }
}
