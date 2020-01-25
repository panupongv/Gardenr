import 'package:flutter/cupertino.dart';

import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/widgets/other_user_profile_section.dart';

import 'dashboard_item.dart';

class DashBoard extends StatelessWidget {
  final List<Plant> _plants;
  final List<bool> _filteredPlants;
  final Function _parentOnRefresh, _onItemPressed;
  final List<Widget> _headerWidgets;

  DashBoard(this._plants, this._filteredPlants, this._parentOnRefresh,
      this._onItemPressed, this._headerWidgets);

  @override
  Widget build(BuildContext context) {
    bool darkThemed = CupertinoTheme.of(context).brightness == Brightness.dark;

    Widget moistureIcon = Image(
      width: DASHBOARD_ICON_SIZE,
      height: DASHBOARD_ICON_SIZE,
      image: AssetImage(darkThemed
          ? 'assets/moisture_dark.png'
          : 'assets/moisture_light.png'),
    );
    Widget temperatureIcon = Image(
      width: DASHBOARD_ICON_SIZE,
      height: DASHBOARD_ICON_SIZE,
      image: AssetImage(darkThemed
          ? 'assets/temperature_dark.png'
          : 'assets/temperature_light.png'),
    );

    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _parentOnRefresh,
        ),
        SliverSafeArea(
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index < _headerWidgets.length) {
                  return _headerWidgets[index];
                }
                index -= _headerWidgets.length;

                if (!_filteredPlants[index]) {
                  return Container(
                    height: 0,
                  );
                }
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _onItemPressed(index);
                  },
                  child: DashBoardItem(
                      _plants[index], moistureIcon, temperatureIcon),
                );
              },
              childCount: _headerWidgets.length + _plants.length,
            ),
          ),
        ),
      ],
    );
  }
}
