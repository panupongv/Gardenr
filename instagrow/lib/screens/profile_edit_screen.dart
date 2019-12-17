import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

class ProfileEditScreen extends StatefulWidget {
  final String imageUrl, userDisplayName, userDescription;

  ProfileEditScreen(this.imageUrl, this.userDisplayName, this.userDescription);

  @override
  State<StatefulWidget> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String imageUrl, userDisplayName, userDescription;

  @override
  void initState() {
    imageUrl = widget.imageUrl;
    userDisplayName = widget.userDisplayName;
    userDescription = widget.userDescription;
    super.initState();
  }

  Future<void> getImage() async {
    print("Exit here?");
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.path);
    // setState(() {
    //   imageUrl = image.uri.toString();
    // });
  }

  @override
  Widget build(BuildContext context) {
    ClipRRect imageButton = ClipRRect(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider),
            ),
          );
        },
      ),
    );
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: navigationBarTitle("Edit Profile"),
      ),
      child: GestureDetector(
        child: imageButton,
        onTap: getImage,
      ),
    );
  }
}
