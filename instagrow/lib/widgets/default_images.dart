import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/utils/style.dart';

Widget defaultUserImage(BuildContext context) {
  return grayBackground(
      context, AssetImage('assets/images/defaultprofile.png'));
}

Widget defaultPlantImage(BuildContext context) {
  return grayBackground(context, AssetImage('assets/images/defaultplant.png'));
}

Widget progressIndicator(BuildContext context) {
  return Container(
    color: Styles.dynamicGray(context),
    child: CircularProgressIndicator(),
  );
}

Widget grayBackground(BuildContext context, ImageProvider image) {
  return Container(
    decoration: BoxDecoration(
      color: Styles.dynamicGray(context),
      image: DecorationImage(image: image),
    ),
  );
}
