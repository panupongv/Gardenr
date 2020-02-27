import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:instagrow/models/plant.dart';
import 'package:instagrow/utils/size_config.dart';
import 'dashboard_item.dart';

class DashBoard extends StatelessWidget {
  final List<Plant> _plants;
  final List<bool> _filteredPlants;
  final Function _parentOnRefresh, _onItemPressed;
  final List<Widget> _headerWidgets;

  DashBoard(this._plants, this._filteredPlants, this._parentOnRefresh,
      this._onItemPressed, this._headerWidgets);

  Widget _moistureIcon(bool darkThemed) {
    return Image(
      width: DASHBOARD_ICON_SIZE,
      height: DASHBOARD_ICON_SIZE,
      image: AssetImage(
        darkThemed
            ? 'assets/images/moisture_dark.png'
            : 'assets/images/moisture_light.png',
      ),
    );
  }

  Widget _temperatureIcon(bool darkThemed) {
    return Image(
      width: DASHBOARD_ICON_SIZE,
      height: DASHBOARD_ICON_SIZE,
      image: AssetImage(
        darkThemed
            ? 'assets/images/temperature_dark.png'
            : 'assets/images/temperature_light.png',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkThemed = CupertinoTheme.of(context).brightness == Brightness.dark;
    return Scrollbar(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
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
                        _plants[index],
                        _moistureIcon(darkThemed),
                        _temperatureIcon(darkThemed)),
                  );
                },
                childCount: _headerWidgets.length + _plants.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
