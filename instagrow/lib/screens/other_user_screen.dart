import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/enums.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/screens/plant_profile_screen.dart';
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
  _OtherUserScreenState createState() => _OtherUserScreenState(followingPlants
      .where((Plant plant) => plant.ownerId == userProfile.id)
      .toList());
}

class _OtherUserScreenState extends State<OtherUserScreen> {
  UserProfile _userProfile;
  DashBoardContentType _contentType;

  List<Plant> _plants, _inGardenPlants, _otherUserFollowingPlants;
  final List<Plant> _myFollowingPlants;

  _OtherUserScreenState(this._myFollowingPlants);

  @override
  void initState() {
    _plants = [];

    _userProfile = widget.userProfile;

    _contentType = DashBoardContentType.MyPlants;

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
    if (_contentType == DashBoardContentType.MyPlants) {
      _updateGardenPlants(refreshedTime);
      setState(() {
        if (_inGardenPlants != null) {
          _plants = _inGardenPlants;
        }
      });
    } else if (_contentType == DashBoardContentType.Following) {
      _updateOtherUserFollowingPlants(refreshedTime);
      setState(() {
        _plants = _otherUserFollowingPlants;
      });
    }
  }

  Future<void> _updateGardenPlants(DateTime refreshedTime) async {
    List<Plant> nonPrivateOtherUserPlants =
        await DatabaseService.getOtherUserPlants(
            _userProfile.id, refreshedTime);
    setState(() {
      _inGardenPlants = _mergeGardenPlantLists(nonPrivateOtherUserPlants);
    });
  }

  Future<void> _updateOtherUserFollowingPlants(DateTime refreshedTime) async {
    List<String> updatedFollowingPlants =
        await DatabaseService.getOtherUserFollowingPlantIds(_userProfile.id);
    _mergeOtherUserFollowingPlant(updatedFollowingPlants, refreshedTime)
        .then((List<Plant> mergeResult) {
      setState(() {
        _otherUserFollowingPlants = mergeResult;
      });
    });
  }

  List<Plant> _mergeGardenPlantLists(List<Plant> nonPrivateOtherUserPlants) {
    List<String> plantIds =
        nonPrivateOtherUserPlants.map((Plant p) => p.id).toList();
    _myFollowingPlants.forEach((Plant plant) {
      if (!plantIds.contains(plant.id)) {
        nonPrivateOtherUserPlants.add(plant);
      }
    });
    return nonPrivateOtherUserPlants;
  }

  Future<List<Plant>> _mergeOtherUserFollowingPlant(
      List<String> plantIds, DateTime refreshedTime) async {
    List<String> myPlantIds = await DatabaseService.getMyPlantIds(),
        alreadyFollowedIds = widget.followingPlants.map((Plant p) => p.id).toList();
    print(alreadyFollowedIds);

    List<Plant> results = List();
    plantIds.forEach((String plantId) async {
      print("FOR EACH: " + plantId);
      Plant publicPlantFromId =
          await DatabaseService.getPublicPlantById(plantId, refreshedTime);

      if (publicPlantFromId != null) {
        print(plantId + " CASE 1");
        results.add(publicPlantFromId);
      } else if (myPlantIds.contains(plantId)) {
        print(plantId + " CASE 2");
        Plant directFromDb =
            await DatabaseService.getPlantById(plantId, refreshedTime);
        if (directFromDb != null) {
          results.add(directFromDb);
        }
      } else if (alreadyFollowedIds.contains(plantId)) {
        print(plantId + " CASE 3");
        results.add(widget.followingPlants[alreadyFollowedIds.indexOf(plantId)]);
      }
    });
    return results;
  }

  Future<void> _onItemPressed(int index) async {
    Route plantProfileScreen = CupertinoPageRoute(
      builder: (context) {
        return PlantProfileScreen(
            _plants[index], false, widget.followingPlants);
      },
    );
    Navigator.of(context).push(plantProfileScreen);
  }

  void _switchContent(DashBoardContentType contentType) {
    setState(() {
      _contentType = contentType;

      _plants = _contentType == DashBoardContentType.MyPlants
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
