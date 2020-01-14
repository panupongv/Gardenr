import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/user_information.dart';
import 'package:instagrow/widgets/other_user_profile_section.dart';

import 'dashboard_item.dart';

class DashBoard extends StatelessWidget {
  final List<Plant> _plants;
  final Function _parentOnRefresh, _onItemPressed;
  final UserInformation _otherUser;
  final bool _isForOtherUser;

  DashBoard(this._plants, this._parentOnRefresh, this._onItemPressed,
      [this._otherUser])
      : _isForOtherUser = _otherUser != null;

  @override
  Widget build(BuildContext context) {
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
                if (_isForOtherUser) {
                  if (index == 0) {
                    return OtherUserProfileSection(_otherUser);
                  }
                  index--;
                }
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _onItemPressed(index);
                  },
                  child: DashBoardItem(_plants[index]),
                );
              },
              childCount: _plants.length + (_isForOtherUser ? 1 : 0),
            ),
          ),
        ),
      ],
    );
  }
}
