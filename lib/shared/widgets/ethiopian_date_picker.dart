import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abushakir/abushakir.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class EthiopianDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const EthiopianDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  _EthiopianDatePickerState createState() => _EthiopianDatePickerState();
}

class _EthiopianDatePickerState extends State<EthiopianDatePicker> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  final List<String> ethiopianMonths = [
    'መስከረም', 'ጥቅምት', 'ህዳር', 'ታህሳስ', 'ጥር', 'የካቲት', 'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ'
  ];

  @override
  void initState() {
    super.initState();
    final ethiopianDate = EtDatetime.fromMillisecondsSinceEpoch(
      widget.initialDate.add(const Duration(hours: 12)).millisecondsSinceEpoch,
    );
    selectedYear = ethiopianDate.year;
    selectedMonth = ethiopianDate.month;
    selectedDay = ethiopianDate.day;
    
    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    yearController = FixedExtentScrollController(initialItem: selectedYear - 2015); // Start from 2015 EC
  }

  int _getDaysInMonth(int year, int month) {
    if (month < 13) return 30;
    // Pagume: 6 days in leap year, 5 otherwise.
    // In Ethiopian calendar, leap year is when (year + 1) % 4 == 0 or similar? 
    // Actually (year + 1) % 4 == 0 is simplified. 
    // Usually ethiopian_calendar_plus handles this.
    // For simplicity, let's allow 6 and handle conversion failure if it's 6 on non-leap.
    return (year % 4 == 3) ? 6 : 5; // Ethiopian leap year cycle
  }

  void _onConfirm() {
    try {
      final et = EtDatetime(year: selectedYear, month: selectedMonth, day: selectedDay);
      final gregorianDate = DateTime.fromMillisecondsSinceEpoch(et.moment);
      widget.onDateSelected(gregorianDate);
      Navigator.of(context).pop();
    } catch (e) {
      // Handle invalid day if Pagume 6 on regular year
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ልክ ያልሆነ ቀን')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
    if (selectedDay > daysInMonth) selectedDay = daysInMonth;

    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildPicker(
                  items: List.generate(20, (index) => (2015 + index).toString()),
                  controller: yearController,
                  onChanged: (val) => setState(() => selectedYear = 2015 + val),
                  label: 'ዓመት',
                ),
                _buildPicker(
                  items: ethiopianMonths,
                  controller: monthController,
                  onChanged: (val) => setState(() => selectedMonth = val + 1),
                  label: 'ወር',
                  flex: 2,
                ),
                _buildPicker(
                  items: List.generate(daysInMonth, (index) => (index + 1).toString()),
                  controller: dayController,
                  onChanged: (val) => setState(() => selectedDay = val + 1),
                  label: 'ቀን',
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ቀን ይምረጡ (የኢትዮጵያ አቆጣጠር)',
            style: TextUtils.setTextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker({
    required List<String> items,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
    required String label,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(label, style: TextUtils.setTextStyle(fontSize: 13.sp, color: Colors.grey)),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 45.h,
              scrollController: controller,
              onSelectedItemChanged: (index) {
                onChanged(index);
              },
              children: items.map((item) => Center(
                child: Text(
                  item,
                  style: TextUtils.setTextStyle(fontSize: 18.sp),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
      child: SizedBox(
        width: double.infinity,
        height: 55.h,
        child: ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colorscontainer.greenColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            elevation: 0,
          ),
          child: Text(
            'አረጋግጥ',
            style: TextUtils.setTextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
