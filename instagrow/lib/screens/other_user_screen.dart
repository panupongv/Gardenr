import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/dashboard.dart';

class OtherUserScreen extends StatefulWidget {
  final UserProfile userProfile;

  OtherUserScreen(this.userProfile);

  @override
  _OtherUserScreenState createState() => _OtherUserScreenState();
}

class _OtherUserScreenState extends State<OtherUserScreen> {
  UserProfile _userProfile;

  List<Plant> _plants;

  @override
  void initState() {
    _userProfile = widget.userProfile;
    _plants = [];
    _onRefresh();
    super.initState();
  }

  Future<void> _onRefresh() async {
    DateTime refreshedTime = DateTime.now().toUtc();

    UserProfile updateProfile =
        await DatabaseService.getOtherUserProfile(_userProfile.id);
    List<Plant> updatedPlants = await DatabaseService.getOtherUserPlants(
        _userProfile.id, refreshedTime);
    setState(() {
      if (updateProfile != null) {
        _userProfile = updateProfile;
      }
      if (updatedPlants != null) {
        _plants = updatedPlants;
      }
    });
  }

  Future<void> _onItemPressed(int index) async {
    Route plantProfileScreen = CupertinoPageRoute(
      builder: (context) {
        return PlantProfileScreen(_plants[index], false, null);
      },
    );
    Navigator.of(context).push(plantProfileScreen);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text("Profile", style: Styles.navigationBarTitle(context)),),
      child: SafeArea(
        child: DashBoard(_plants, List.generate(_plants.length, (_) => true),
            _onRefresh, _onItemPressed, _userProfile),
      ),
    );
  }
}
