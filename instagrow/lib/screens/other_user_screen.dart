import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/user_information.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/widgets/dashboard.dart';

class OtherUserScreen extends StatefulWidget {
  final UserInformation userInformation;

  OtherUserScreen(this.userInformation);

  @override
  _OtherUserScreenState createState() => _OtherUserScreenState();
}

class _OtherUserScreenState extends State<OtherUserScreen> {
  UserInformation _userInformation;

  List<Plant> _plants;

  @override
  void initState() {
    _userInformation = widget.userInformation;
    _plants = [];
    _onRefresh();
    super.initState();
  }

  Future<void> _onRefresh() async {
    DateTime refreshedTime = DateTime.now().toUtc();
    List<Plant> updatedPlants =  await DatabaseService.getOtherUserPlants(_userInformation.id, refreshedTime);
    setState(() {
      _plants = updatedPlants;
    });
  }

  Future<void> _onItemPressed(int index) async {
    print("Item pressed");
    return;
  } 

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: SafeArea(
        child: DashBoard(_plants, _onRefresh, _onItemPressed, _userInformation),
      ),
    );
  }
}
