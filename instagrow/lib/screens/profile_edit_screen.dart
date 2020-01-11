import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/utils/database_service.dart';
import 'package:instagrow/utils/dimension_config.dart';
import 'package:instagrow/widgets/navigation_bar_text.dart';

enum PreviousScreen {
  UserProfile,
  AddMyPlant,
  EditMyPlant,
}

class ProfileEditScreen extends StatefulWidget {
  final ImageProvider profileImage;
  final String currentDisplayName, currentDescription, plantId;
  final List<Plant> plantList; 
  final PreviousScreen previousScreen;

  ProfileEditScreen(
      this.profileImage, this.currentDisplayName, this.currentDescription, this.previousScreen, this.plantId, this.plantList);

  @override
  State<StatefulWidget> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool _imageChanged, _displayNameChanged, _descriptionChanged;
  File _selectedImage;
  ImageProvider _profileImage;
  String _currentDisplayName, _currentDescription;
  TextEditingController _displayNameController, _descriptionController;

  static const MAX_DESCRIPTION_LENGTH = 200;

  @override
  void initState() {
    _selectedImage = null;
    _imageChanged = _displayNameChanged = _descriptionChanged = false;
    _profileImage =
        widget.profileImage ?? AssetImage('assets/defaultprofile.png');

    _displayNameController = TextEditingController();
    _descriptionController = TextEditingController();

    _displayNameController.text = _currentDisplayName = widget.currentDisplayName;
    _descriptionController.text = _currentDescription = widget.currentDescription;
    super.initState();
  }

  bool _allowSave() {
    return (_imageChanged || _displayNameChanged || _descriptionChanged) &&
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
          content: Text("A Plant named $name exists in your collection, would you like to proceed"),
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

      if (_displayNameChanged && (previousScreen == PreviousScreen.EditMyPlant || previousScreen == PreviousScreen.AddMyPlant)) {
        String name = _displayNameController.text;
        if (Plant.hasDuplicateName(widget.plantId, name, widget.plantList)) {
          bool confirmed = await _confirmDuplicatePlantName(name);
          if (!confirmed) {
            return;
          }
        }
      }

      if (_imageChanged) {
        if (previousScreen == PreviousScreen.UserProfile) {
          DatabaseService.updateProfileImage(_selectedImage);
        } else if (previousScreen == PreviousScreen.EditMyPlant || previousScreen == PreviousScreen.AddMyPlant) {
          DatabaseService.updatePlantProfileImage(widget.plantId, _selectedImage);
        }
        setState(() {
          _imageChanged = false;
        });
      }
      if (_displayNameChanged) {
        String newName = _displayNameController.text;
        if (previousScreen == PreviousScreen.UserProfile) {
          DatabaseService.updateDisplayName(newName);
        } else if (previousScreen == PreviousScreen.EditMyPlant || previousScreen == PreviousScreen.AddMyPlant) {
          DatabaseService.updatePlantName(widget.plantId, newName);
        }
        setState(() {
          _currentDisplayName = newName;
          _displayNameChanged = false;
        });
      }
      if (_descriptionChanged) {
        String newDescription = _descriptionController.text;
        if (previousScreen == PreviousScreen.UserProfile) {
          DatabaseService.updateDescription(newDescription);
        } else if (previousScreen == PreviousScreen.EditMyPlant || previousScreen == PreviousScreen.AddMyPlant) {
          DatabaseService.updatePlantDescription(widget.plantId, newDescription);
        }
        setState(() {
          _currentDescription = newDescription;
          _descriptionChanged = false;
        });
      }

      if (previousScreen == PreviousScreen.AddMyPlant) {
        
      }

      Navigator.of(context).pop();
    }
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
                  _displayNameChanged = _currentDisplayName != displayNameText;
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
                  _descriptionChanged = _currentDescription != descriptionText;
                });
              },
            ),
            Text("${_descriptionController.text.length} out of $MAX_DESCRIPTION_LENGTH characters", textAlign: TextAlign.right,),
          ],
        ),
      ),
    );
  }
}
