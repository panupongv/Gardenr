import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/enums.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';
import 'package:instagrow/utils/auth_service.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/content_segment_controller.dart';
import 'package:instagrow/widgets/dashboard.dart';
import 'package:instagrow/widgets/other_user_profile_section.dart';

class OtherUserScreen extends StatefulWidget {
  final UserProfile userProfile;
  final List<Plant> followingPlants;

  OtherUserScreen(this.userProfile, this.followingPlants);

  @override
  _OtherUserScreenState createState() => _OtherUserScreenState();
}

class _OtherUserScreenState extends State<OtherUserScreen> {
  UserProfile _userProfile;
  DashBoardContentType _contentType;

  List<Plant> _plants, _inGardenPlants, _otherUserFollowingPlants;
  List<bool> _areMyPlants;

  _OtherUserScreenState();

  @override
  void initState() {
    _plants = [];
    _areMyPlants = [];
    _inGardenPlants = [];
    _otherUserFollowingPlants = [];

    _userProfile = widget.userProfile;

    _contentType = DashBoardContentType.Garden;

    DateTime refreshedTime = DateTime.now().toUtc();

    _updateGardenPlants(refreshedTime).then((_) {
      setState(() {
        _plants = _inGardenPlants;
      });
    });

    _updateOtherUserFollowingPlants(refreshedTime);

    super.initState();
  }

  Future<void> _onRefresh() async {
    UserProfile updateProfile =
        await DatabaseService.getOtherUserProfile(_userProfile.id);
    setState(() {
      if (updateProfile != null) {
        _userProfile = updateProfile;
      }
    });

    DateTime refreshedTime = DateTime.now().toUtc();

    if (_contentType == DashBoardContentType.Garden) {
      _updateGardenPlants(refreshedTime).then((_) {
        if (_inGardenPlants != null) {
          setState(() {
            _plants = _inGardenPlants;
          });
        }
      });
    } else if (_contentType == DashBoardContentType.Following) {
      _updateOtherUserFollowingPlants(refreshedTime).then((_) {
        if (_otherUserFollowingPlants != null) {
          setState(() {
            _plants = _otherUserFollowingPlants;
          });
        }
      });
    }
  }

  Future<void> _updateGardenPlants(refreshedTime) async {
    List<String> otherUserGardenPlantIds =
        await DatabaseService.getOtherUserPlantIds(_userProfile.id);
    List<Plant> results =
        await _updatePlantsHelper(otherUserGardenPlantIds, refreshedTime);

    if (results != null) {
      setState(() {
        _inGardenPlants = results;
      });
    }
  }

  Future<void> _updateOtherUserFollowingPlants(DateTime refreshedTime) async {
    List<String> usersFollowingPlantIds =
        await DatabaseService.getOtherUserFollowingPlantIds(_userProfile.id);
    FirebaseUser myUser = await AuthService.getUser();
    List<Plant> results =
        await _updatePlantsHelper(usersFollowingPlantIds, refreshedTime);
    if (results != null) {
      String myUid = myUser.uid;
      setState(() {
        _otherUserFollowingPlants = results;
      });
      _updateMyPlantMarkers(results, myUid);
    }
  }

  void _updateMyPlantMarkers(List<Plant> plants, String userId) {
    _areMyPlants =
        plants.map((Plant plant) => plant.ownerId == userId).toList();
  }

  Future<List<Plant>> _updatePlantsHelper(
      List<String> plantIds, DateTime refreshedTime) async {
    List<String> myPlantIds = await DatabaseService.getMyPlantIds(),
        myFollowingPlantIds = await DatabaseService.getMyFollowingIds();
    List<Plant> tempPlants = List();
    List<Future> futures = List();
    plantIds.forEach((String plantId) async {
      if (myPlantIds.contains(plantId) ||
          myFollowingPlantIds.contains(plantId)) {
        futures.add(() async {
          Plant directFromDb =
              await DatabaseService.getPlantById(plantId, refreshedTime);
          if (directFromDb != null) {
            tempPlants.add(directFromDb);
          }
        }());
      } else {
        futures.add(() async {
          Plant nonPrivatePlant =
              await DatabaseService.getPublicPlantById(plantId, refreshedTime);
          if (nonPrivatePlant != null) {
            tempPlants.add(nonPrivatePlant);
          }
        }());
      }
    });

    await Future.wait(futures);
    return tempPlants;
  }

  Future<void> _onItemPressed(int index) async {
    Route plantProfileScreen = CupertinoPageRoute(
      builder: (context) {
        bool isMyPlant = _contentType == DashBoardContentType.Garden
            ? false
            : _areMyPlants[index];
        return PlantProfileScreen(
            _plants[index], isMyPlant, widget.followingPlants);
      },
    );
    Navigator.of(context).push(plantProfileScreen);
  }

  void _switchContent(DashBoardContentType contentType) {
    setState(() {
      _contentType = contentType;
      _plants = _contentType == DashBoardContentType.Garden
          ? _inGardenPlants
          : _otherUserFollowingPlants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Profile", style: Styles.navigationBarTitle(context)),
      ),
      child: SafeArea(
        child: DashBoard(
          _plants,
          List.generate(_plants.length, (_) => true),
          _onRefresh,
          _onItemPressed,
          [
            OtherUserProfileSection(_userProfile),
            ContentSegmentController(_switchContent),
          ],
        ),
      ),
    );
  }
}
