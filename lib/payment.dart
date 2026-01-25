import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'components/routenames.dart';
import 'pages/constants/colors.dart';
import 'pages/constants/text_utils.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<Map<String, dynamic>> items = [
    {
      'text': 'በአየር ሰአት',
      'imagePath': 'assets/airt.png',
    },
    {
      'text': 'በቴሌ ብር',
      'imagePath': 'assets/tele.jpg',
    },
    {
      'text': 'በአዋሽ ብር',
      'imagePath': 'assets/Awash.jpg',
    },
    {
      'text': 'በሲቢኢ ብር',
      'imagePath': 'assets/cbe.png',
    },
    {
      'text': 'በአቢሲኒያ ካርድ',
      'imagePath': 'assets/card_boa.png',
    },
    {
      'text': 'በአሞሌ ዋሌት',
      'imagePath': 'assets/amole.png',
    },
    {
      'text': 'በኢ ብር',
      'imagePath': 'assets/ebirr_logo.png',
    },
    {
      'text': 'በፔይፓል',
      'imagePath': 'assets/paypal.png',
    },
    {
      'text': 'በእናት ባንክ',
      'imagePath': 'assets/enat_bank.png',
    },
  ];

  String selectedPayment = 'በሲቢኢ ብር';
  int selectedIndex = 0;
  BuildContext? getRouterContext(BuildContext context) {
    var navigator = Navigator.of(context, rootNavigator: true);
    return navigator.context;
  }

  void selectIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void navigateTohome() {
    context.goNamed(RouteNames.news);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: ScreenUtil().setWidth(25),
          ),
          color: Colorscontainer.greenColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SizedBox(height: 20.h),
              Center(
                child: Text(
                  'testa',
                  style: TextUtils.setTextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: Colorscontainer.greenColor,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 40.h,
                // width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        selectIndex(0);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: selectedIndex == 0
                              ? Colorscontainer.greenColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.sp),
                        ),
                        child: Text(
                          '20 ብር / በወር',
                          overflow: TextOverflow.ellipsis,
                          style: TextUtils.setTextStyle(
                            fontSize: 12.sp,
                            color: selectedIndex == 0
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        selectIndex(1);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: selectedIndex == 1
                              ? Colorscontainer.greenColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.sp),
                        ),
                        child: Text(
                          '50 ብር ለ 3 ወር',
                          style: TextUtils.setTextStyle(
                            fontSize: 14.sp,
                            color: selectedIndex == 1
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        selectIndex(2);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: selectedIndex == 2
                              ? Colorscontainer.greenColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.sp),
                        ),
                        child: Text(
                          '100 ብር ለአመት',
                          style: TextUtils.setTextStyle(
                            fontSize: 14.sp,
                            color: selectedIndex == 2
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),
              Center(
                child: Text(
                  'ስልክ ቁጥርዎን ያስገቡ',
                  style: TextUtils.setTextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: 300.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/ethio.png',
                      width: 30.w,
                    ),
                    const VerticalDivider(
                      color: Color.fromARGB(255, 160, 77, 77),
                      width: 5,
                      thickness: 4,
                    ),
                    Text(
                      ' | ',
                      style: TextUtils.setTextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '09********',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Container(
                  width: 360.h,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.all(24.sp),
                            child: Dialog(
                              elevation: 5.0,
                              shadowColor: Colors.grey,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.sp),
                              ),
                              child: SizedBox(
                                height: 250.h,
                                width: 200.w,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0.w),
                                        child: Text(
                                          'እባክዎ $selectedPayment ማለፊያ ቁጥርዎትን በስልክዎ የሚደርስዎት መጠይቅ ላይ ያስገቡ፡፡ ከዚያም ከታች "ይቀጥሉ" የሚለዉን ይጫኑ፡፡',
                                          textAlign: TextAlign.center,
                                          style: TextUtils.setTextStyle(
                                              fontSize: 18.0.sp,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.0.h),
                                    Container(
                                      width: 190.h,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40.h)),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) => NewsHomePage()));
                                          Navigator.pop(context);
                                          navigateTohome();

                                          // context.pushNamed(RouteNames.news);
                                          // Navigator.pop(context);
                                        },
                                        // onPressed: () {
                                        //   Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(builder: (context) => NewsHomePage()),
                                        //   );
                                        // },

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colorscontainer.greenColor,
                                        ),
                                        child: const Text('ይቀጥሉ'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                      // },
                      //  onPressed: () {
                      //    context.goNamed(RouteNames.news);
                      //   // showDialog(
                      //   //   context: context,
                      //   //   builder: (BuildContext context) {
                      //   //     return Builder(
                      //   //       builder: (BuildContext context) {

                      //   //         return MyPopup(
                      //   //           PaymentType: selectedPayment,
                      //   //           routerContext: context,
                      //   //         );
                      //   //       },
                      //   //     );
                      //   //   },
                      //   // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorscontainer.greenColor,
                    ),
                    child: Text(
                      selectedPayment.isNotEmpty
                          ? '$selectedPayment ይክፈሉ'
                          : 'በአየር ሰአት' ' ይክፈሉ',
                      style: TextUtils.setTextStyle(
                          fontSize: 18.sp, color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20.w,
                    mainAxisSpacing: 20.h,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedPayment = items[index]['text'];
                        });
                      },
                      child: ItemColumn(
                        imagePath: items[index]['imagePath'],
                        text: items[index]['text'],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemColumn extends StatelessWidget {
  final String imagePath;
  final String text;

  const ItemColumn({
    super.key,
    required this.imagePath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 48.r,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 6.h,
          ),
        ),
        Text(
          text,
          style: TextUtils.setTextStyle(fontSize: 10.sp, color: Colors.white),
        ),
      ],
    );
  }
}
