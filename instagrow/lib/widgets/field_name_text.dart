import 'package:flutter/cupertino.dart';
import 'package:instagrow/utils/style.dart';

Widget fieldNameText(BuildContext context, String content) {
  return Padding(
    padding: EdgeInsets.only(left: 8, bottom: 4),
    child: Text(
      content,
      style: Styles.editFieldText(context),
    ),
  );
}
