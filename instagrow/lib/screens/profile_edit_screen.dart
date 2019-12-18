import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/dimension_config.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

class ProfileEditScreen extends StatefulWidget {
  final ImageProvider profileImage;
  final String currentDisplayName, currentDescription;

  ProfileEditScreen(
      this.profileImage, this.currentDisplayName, this.currentDescription);

  @override
  State<StatefulWidget> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool _imageChanged, _displayNameChanged, _descriptionChanged;
  File selectedImage;
  ImageProvider profileImage;
  String currentDisplayName, currentDescription;
  TextEditingController displayNameController, descriptionController;

  @override
  void initState() {
    selectedImage = null;
    _imageChanged = _displayNameChanged = _descriptionChanged = false;
    profileImage =
        widget.profileImage ?? AssetImage('assets/defaultprofile.png');

    displayNameController = TextEditingController();
    descriptionController = TextEditingController();

    displayNameController.text = currentDisplayName = widget.currentDisplayName;
    descriptionController.text = currentDescription = widget.currentDescription;
    super.initState();
  }

  bool _allowSave() {
    return (_imageChanged || _displayNameChanged || _descriptionChanged) &&
        displayNameController.text != '';
  }

  Future<void> _getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    if (croppedImage == null) {
      return;
    }
    selectedImage = croppedImage;
    setState(() {
      _imageChanged = true;
      profileImage = AssetImage(croppedImage.path);
    });
  }

  Future<void> _applyChanges() async {
    if (_allowSave()) {
      if (_imageChanged) {
        DatabaseService.updateProfileImage(selectedImage);
        setState(() {
          _imageChanged = false;
        });
      }
      if (_displayNameChanged) {
        String newName = displayNameController.text;
        DatabaseService.updateDisplayName(newName);
        setState(() {
          currentDisplayName = newName;
          _displayNameChanged = false;
        });
      }
      if (_descriptionChanged) {
        String newDescription = descriptionController.text;
        DatabaseService.updateDescription(newDescription);
        setState(() {
          currentDescription = newDescription;
          _descriptionChanged = false;
        });
      }
      Navigator.of(context).pop();
    } else {
      print("NO changes");
    }
  }

  @override
  Widget build(BuildContext context) {
    Image currentImageDisplay = Image(
      image: profileImage,
      width: PROFILE_IMAGE_SIZE,
      height: PROFILE_IMAGE_SIZE,
      fit: BoxFit.cover,
    );

    UnconstrainedBox imageButton = UnconstrainedBox(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: GestureDetector(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PROFILE_IMAGE_SIZE / 2),
            child: currentImageDisplay,
          ),
          onTap: _getImage,
        ),
      ),
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Align(
          widthFactor: 1.0,
          alignment: Alignment.center,
          child: navigationBarTextButton("Cancel", () {
            Navigator.of(context).pop();
          }),
        ),
        trailing: GestureDetector(
          child: Text(
            "Save",
            style: TextStyle(
              color: _allowSave()
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.inactiveGray,
            ),
          ),
          onTap: _applyChanges,
        ),
      ),
      child: SafeArea(
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            imageButton,
            Text(
              "Display Name",
              textAlign: TextAlign.left,
            ),
            CupertinoTextField(
              controller: displayNameController,
              onChanged: (displayNameText) {
                setState(() {
                  _displayNameChanged = currentDisplayName != displayNameText;
                });
              },
            ),
            Text(
              "Description",
              textAlign: TextAlign.left,
            ),
            CupertinoTextField(
              controller: descriptionController,
              onChanged: (descriptionText) {
                setState(() {
                  _descriptionChanged = currentDescription != descriptionText;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
