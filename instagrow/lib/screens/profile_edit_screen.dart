import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

enum PreviousScreen {
  UserProfile,
  AddMyPlant,
  EditMyPlant,
}

class ProfileEditScreen extends StatefulWidget {
  final ImageProvider profileImage;
  final String currentDisplayName, currentDescription;
  final Plant plant;
  final List<Plant> plantList;
  final PreviousScreen previousScreen;

  ProfileEditScreen(this.profileImage, this.currentDisplayName,
      this.currentDescription, this.previousScreen, this.plant, this.plantList);

  @override
  State<StatefulWidget> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool _imageChanged, _displayNameChanged, _descriptionChanged, _privacyChanged;
  bool _isPublic;
  File _selectedImage;
  ImageProvider _profileImage;
  TextEditingController _displayNameController, _descriptionController;

  static const MAX_DESCRIPTION_LENGTH = 200;

  @override
  void initState() {
    _selectedImage = null;
    _imageChanged =
        _displayNameChanged = _descriptionChanged = _privacyChanged = false;
    _profileImage = widget.profileImage ??
        AssetImage(widget.previousScreen == PreviousScreen.UserProfile
            ? 'assets/defaultprofile.png'
            : 'assets/defaultplant.png');

    _isPublic = widget.previousScreen != PreviousScreen.UserProfile
        ? widget.plant.isPublic
        : false;

    _displayNameController = TextEditingController();
    _descriptionController = TextEditingController();

    _displayNameController.text = widget.currentDisplayName;
    _descriptionController.text = widget.currentDescription;
    super.initState();
  }

  bool _allowSave() {
    return (_imageChanged ||
            _displayNameChanged ||
            _descriptionChanged ||
            _privacyChanged) &&
        _displayNameController.text != '';
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

    _selectedImage = croppedImage;
    setState(() {
      _imageChanged = true;
      _profileImage = AssetImage(croppedImage.path);
    });
  }

  Future<bool> _confirmDuplicatePlantName(String name) async {
    bool confirmed;
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Caution"),
          content: Text(
              "A Plant named $name exists in your collection, would you like to proceed"),
          actions: <Widget>[
            CupertinoButton(
              child: Text("Cancel"),
              onPressed: () {
                confirmed = false;
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(
                "Confirm",
              ),
              onPressed: () {
                confirmed = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return confirmed;
  }

  Future<void> _applyChanges() async {
    PreviousScreen previousScreen = widget.previousScreen;
    if (_allowSave()) {
      if (_displayNameChanged &&
          (previousScreen == PreviousScreen.EditMyPlant ||
              previousScreen == PreviousScreen.AddMyPlant)) {
        String name = _displayNameController.text;
        if (Plant.hasDuplicateName(widget.plant, widget.plantList)) {
          bool confirmed = await _confirmDuplicatePlantName(name);
          if (!confirmed) {
            return;
          }
        }
      }

      if (_imageChanged) {
        if (previousScreen == PreviousScreen.UserProfile) {
          DatabaseService.updateProfileImage(_selectedImage);
        } else if (previousScreen == PreviousScreen.EditMyPlant ||
            previousScreen == PreviousScreen.AddMyPlant) {
          DatabaseService.updatePlantProfileImage(widget.plant, _selectedImage);
        }
      }
      if (_displayNameChanged) {
        String newName = _displayNameController.text;
        if (previousScreen == PreviousScreen.UserProfile) {
          DatabaseService.updateDisplayName(newName);
        } else if (previousScreen == PreviousScreen.EditMyPlant ||
            previousScreen == PreviousScreen.AddMyPlant) {
          DatabaseService.updatePlantName(widget.plant, newName);
        }
      }
      if (_descriptionChanged) {
        String newDescription = _descriptionController.text;
        if (previousScreen == PreviousScreen.UserProfile) {
          DatabaseService.updateDescription(newDescription);
        } else if (previousScreen == PreviousScreen.EditMyPlant ||
            previousScreen == PreviousScreen.AddMyPlant) {
          DatabaseService.updatePlantDescription(widget.plant, newDescription);
        }
      }
      if (_privacyChanged) {
        DatabaseService.updatePlantPrivacy(widget.plant, _isPublic);
      }

      if (previousScreen == PreviousScreen.AddMyPlant) {
        DatabaseService.updateOwnerId(widget.plant);
      }

      Navigator.of(context).pop();
    }
  }

  Widget _togglePublicSwitch() {
    return widget.previousScreen != PreviousScreen.UserProfile
        ? Column(
            children: <Widget>[
              Container(
                height: 30,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.fromARGB(128, 225, 225, 225),
                            width: 1))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8,
                    ),
                    child: Text(
                      "Public Plant",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 8,
                      top: 4,
                      bottom: 4,
                    ),
                    child: CupertinoSwitch(
                      value: _isPublic,
                      dragStartBehavior: DragStartBehavior.down,
                      onChanged: (bool value) {
                        setState(() {
                          _isPublic = value;
                          _privacyChanged = _isPublic != widget.plant.isPublic;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Container(
                height: 1,
                color: Color.fromARGB(128, 225, 225, 225),
              ),
            ],
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    Image currentImageDisplay = Image(
      image: _profileImage,
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
              controller: _displayNameController,
              onChanged: (String displayNameText) {
                setState(() {
                  _displayNameChanged =
                      widget.currentDisplayName != displayNameText;
                });
              },
            ),
            Text(
              "Description",
              textAlign: TextAlign.left,
            ),
            CupertinoTextField(
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              maxLengthEnforced: true,
              maxLength: MAX_DESCRIPTION_LENGTH,
              controller: _descriptionController,
              onChanged: (String descriptionText) {
                setState(() {
                  _descriptionChanged =
                      widget.currentDescription != descriptionText;
                });
              },
            ),
            Text(
              "${_descriptionController.text.length} out of $MAX_DESCRIPTION_LENGTH characters",
              textAlign: TextAlign.right,
            ),
            _togglePublicSwitch(),
          ],
        ),
      ),
    );
  }
}
