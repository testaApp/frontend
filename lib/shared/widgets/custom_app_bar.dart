import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/Homepage.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? tabController;
  final Function(int)? onTabTapped;

  const CustomAppBar({
    super.key,
    this.tabController,
    this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colorscontainer.greenColor.withOpacity(0.98),
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAppBar(context),
          if (tabController != null) _buildTabBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            color: Colorscontainer.greenColor,
            size: 24.sp,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).padding.top - 16.h),
        child: Image.asset(
          'assets/testa_appbar.png',
          height: 22.h,
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
      toolbarHeight: 44.h,
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return ExtendedTabBar(
      controller: tabController!,
      isScrollable: false, // Tabs stretch evenly
      onTap: onTabTapped,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
      labelColor: Colorscontainer.greenColor,
      indicator: RoundedTabIndicator(
        color: Colorscontainer.greenColor,
        radius: 10,
        weight: 2,
      ),
      labelPadding:
          EdgeInsets.zero, // or EdgeInsets.symmetric(horizontal: 20.w)
      tabs: [
        _buildTab(DemoLocalizations.recentNews),
        _buildTab(DemoLocalizations.forYou),
        _buildTab(DemoLocalizations.listen),
      ],
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Container(
        constraints: BoxConstraints(minWidth: 50.w),
        child: Text(
          text,
          style: TextUtils.setTextStyle(
            fontSize: 14.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(tabController != null ? 88.h : 44.h);
}

class RoundedTabIndicator extends Decoration {
  final Color color;
  final double radius;
  final double weight;
  final BoxPainter _painter;

  RoundedTabIndicator({
    required this.color,
    required this.radius,
    required this.weight,
  }) : _painter = _RoundedLinePainter(color, radius, weight);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundedTabIndicator &&
          other.color == color &&
          other.radius == radius &&
          other.weight == weight;

  @override
  int get hashCode => Object.hash(color, radius, weight);
}

class _RoundedLinePainter extends BoxPainter {
  final Paint _paint;
  final double radius;
  final double weight;

  _RoundedLinePainter(Color color, this.radius, this.weight)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final Rect indicatorRect = Rect.fromLTRB(
      rect.left,
      rect.bottom - weight,
      rect.right,
      rect.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(indicatorRect, Radius.circular(radius)),
      _paint,
    );
  }
}
