import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/screens/profile_edit_screen.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';
import 'package:page_transition/page_transition.dart';

class ProfileScreen extends StatefulWidget {
  final FirebaseUser user;

  ProfileScreen(this.user);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _imageUrl;
  String _userDisplayName;
  String _userDescription;

  @override
  Widget build(BuildContext context) {
    UnconstrainedBox imageDisplay = UnconstrainedBox(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(80),
          child: StreamBuilder<Event>(
            stream: DatabaseService.profileImageStream(widget.user),
            builder:
                (BuildContext context, AsyncSnapshot<Event> asyncSnapshot) {
              String streamedUrl = "defaultImage";

              if (asyncSnapshot.data != null) {
                streamedUrl = asyncSnapshot.data.snapshot.value;
                _imageUrl = streamedUrl;
              }
              return CachedNetworkImage(
                imageUrl: streamedUrl,
                imageBuilder:
                    (BuildContext context, ImageProvider imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: 160,
                    height: 160,
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: navigationBarTitle("Profile"),
        trailing: navigationBarTextButton("Edit", () {
          CupertinoPageRoute route = CupertinoPageRoute(
              builder: (context) => ProfileEditScreen(
                  _imageUrl, _userDisplayName, _userDescription));
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  child: ProfileEditScreen(
                      _imageUrl, _userDisplayName, _userDescription)));
        }),
      ),
      child: SafeArea(
        top: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              imageDisplay,
              Container(
                color: Colors.pink,
                child: StreamBuilder<Event>(
                  stream: DatabaseService.displayNameStream(widget.user),
                  builder: (BuildContext context,
                      AsyncSnapshot<Event> asyncSnapshot) {
                    String displayName = (asyncSnapshot.data == null)
                        ? "Display Name"
                        : asyncSnapshot.data.snapshot.value.toString();
                    _userDisplayName = displayName;
                    return Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.amberAccent,
                child: StreamBuilder<Event>(
                  stream: DatabaseService.userDescriptionStream(widget.user),
                  builder: (BuildContext context,
                      AsyncSnapshot<Event> asyncSnapshot) {
                    if (asyncSnapshot.data != null) {
                      String description =
                          asyncSnapshot.data.snapshot.value.toString();
                      _userDescription = description;
                      return Text(description);
                    }
                    return Text("");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class ProfileScreen_ extends StatefulWidget {

//   final FirebaseUser user;

//   ProfileScreen(this.user);

//   @override
//   State<StatefulWidget> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         middle: navigationBarTitle("Profile"),
//         trailing: navigationBarTextButton("Edit", () {
//           print("edit yo");
//         }),
//       ),
//       child: Center(
//         child: StreamBuilder<Event>(
//           // stream: DatabaseService.displayNameStream(widget.user),
//           stream: FirebaseDatabase.instance.reference().child('users').child(widget.user.uid).child('name').onValue,
//           builder: (context, AsyncSnapshot<Event> string) {
//             print(string.toString());
//             print(string.data.runtimeType);
//             if(string.data != null) {
//               print(">> " + string.data.toString());
//               // return CupertinoTextField(placeholder: string.data.snapshot.value.toString(),);
//               return Text(string.data.snapshot.value.toString());
//             }
//             return Text("nothing");
//           },
//         ),
//       ),
//     );
//   }
// }
