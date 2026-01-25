import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../application/scroller/scroller_bloc.dart';
import '../../../application/scroller/scroller_state.dart';
import '../../constants/colors.dart';
import 'fb_list.dart';
import 'instagram_list.dart';
import 'telegram_list.dart';
import 'twitter_list.dart';

class Manminale extends StatefulWidget {
  const Manminale({super.key});

  @override
  State<Manminale> createState() => _ManminaleState();
}

class _ManminaleState extends State<Manminale>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int selectedIdx = 0;
  late List<Widget> widgetLists;

  @override
  void initState() {
    super.initState();
    widgetLists = [
      const TwitterPosts(),
      const FacebookPosts(),
      const Telegram(),
      const InstagramPosts(),
    ];
    _initializeData();
  }

  void _initializeData() {
    if (!mounted) return;
    // Your initialization logic
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: BlocBuilder<ScrollerBloc, ScrollerState>(
            builder: (context, state) {
              return state.displayWidget == true
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIdx = 0;
                            });
                          },
                          child: CircleAvatar(
                              backgroundColor: selectedIdx == 0
                                  ? Colorscontainer.greenColor
                                  : Colors.grey,
                              radius: selectedIdx == 0 ? 22.5.w : 22.0.w,
                              child: CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 21.w,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 42
                                        .w, // Ensures the image fits within the circle
                                    height: 42
                                        .w, // Matching the height to keep it square
                                    child: Image.asset('assets/x.jpg',
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIdx = 1;
                            });
                          },
                          child: CircleAvatar(
                              backgroundColor: selectedIdx == 1
                                  ? Colorscontainer.greenColor
                                  : Colors.grey,
                              radius: selectedIdx == 1 ? 22.5.w : 22.0.w,
                              child: CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 21.w,
                                child: SizedBox(
                                  width: 34.w,
                                  child: Image.asset('assets/facebook.png',
                                      fit: BoxFit.cover),
                                ),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIdx = 2;
                            });
                          },
                          child: CircleAvatar(
                              backgroundColor: selectedIdx == 2
                                  ? Colorscontainer.greenColor
                                  : Colors.grey,
                              radius: 22.5.w,
                              child: CircleAvatar(
                                radius: selectedIdx == 2 ? 21.w : 21.5.w,
                                backgroundColor: Colors.black,
                                child: SizedBox(
                                  width: 34.w,
                                  child: Image.asset('assets/telegram.png'),
                                ),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIdx = 3;
                            });
                          },
                          child: CircleAvatar(
                              backgroundColor: selectedIdx == 3
                                  ? Colorscontainer.greenColor
                                  : Colors.grey,
                              radius: selectedIdx == 3 ? 22.5.w : 22.0.w,
                              child: CircleAvatar(
                                radius: selectedIdx == 3 ? 21.w : 21.5.w,
                                backgroundColor: Colors.black,
                                child: SizedBox(
                                  width: 34.w,
                                  child: Image.asset('assets/insta.png'),
                                ),
                              )),
                        ),
                      ],
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
        const SizedBox(
          height: 5,
        ),

        Row(
          children: [
            Container(
              width: 90.w,
              height: 1,
              color:
                  selectedIdx == 0 ? Colorscontainer.greenColor : Colors.grey,
            ),
            Container(
              width: 90.w,
              height: 1,
              color:
                  selectedIdx == 1 ? Colorscontainer.greenColor : Colors.grey,
            ),
            Container(
              width: 90.w,
              height: 1,
              color:
                  selectedIdx == 2 ? Colorscontainer.greenColor : Colors.grey,
            ),
            Container(
              width: 90.w,
              height: 1,
              color:
                  selectedIdx == 3 ? Colorscontainer.greenColor : Colors.grey,
            )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        // Twitter
        Expanded(child: widgetLists[selectedIdx])
      ],
    );
  }
}
