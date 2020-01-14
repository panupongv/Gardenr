import 'package:flutter/cupertino.dart';
import 'package:instagrow/models/user_information.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/widgets/default_images.dart';

import 'circular_cached_image.dart';
import 'description_expandable.dart';

class OtherUserProfileSection extends StatelessWidget {
  final UserInformation _userInformation;

  OtherUserProfileSection(this._userInformation);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularCachedImage(
                  _userInformation.imageUrl,
                  PLANT_PROFILE_IMAGE_SIZE,
                  progressIndicator(context),
                  defaultPlantImage(context)),
            ),
            Text(
              _userInformation.name,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        DescriptionExpandable(_userInformation.description)
      ],
    );
  }
}
