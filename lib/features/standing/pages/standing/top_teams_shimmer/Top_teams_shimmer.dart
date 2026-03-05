import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ScorerShimmerRow extends StatelessWidget {
  const ScorerShimmerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          height: 15.sp,
          width: 150.w,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5.w),
          ),
        ),
        const Expanded(child: SizedBox()),
        Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Container(
            width: 15.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5.w),
            ),
          ),
        ),
      ],
    );
  }
}

class ShimmerScorerList extends StatelessWidget {
  const ShimmerScorerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Shimmer.fromColors(
        baseColor: const Color.fromARGB(255, 100, 97, 97),
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(
              3,
              (index) => Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 3.h, horizontal: 10.w),
                    child: const ScorerShimmerRow(),
                  )),
        ),
      ),
    );
  }
}
