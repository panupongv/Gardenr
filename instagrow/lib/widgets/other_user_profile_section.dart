import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:instagrow/models/user_profile.dart';
import 'package:instagrow/utils/size_config.dart';
import 'package:instagrow/utils/style.dart';
import 'package:instagrow/widgets/default_images.dart';

import 'circular_cached_image.dart';
import 'description_expandable.dart';

class OtherUserProfileSection extends StatelessWidget {
  final UserProfile _userProfile;

  OtherUserProfileSection(this._userProfile);

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
                  _userProfile.imageUrl,
                  PROFILE_SCREEN_IMAGE_SIZE,
                  progressIndicator(context),
                  defaultPlantImage(context)),
            ),
            Text(_userProfile.name,
                textAlign: TextAlign.left,
                style: Styles.plantProfileName(context)),
          ],
        ),
        DescriptionExpandable(_userProfile.description),
      ],
    );
  }
}
