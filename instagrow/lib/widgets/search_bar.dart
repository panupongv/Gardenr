import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:instagrow/utils/style.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    @required this.controller,
    @required this.focusNode,
    this.onUpdate
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onUpdate;

  @override
  Widget build(BuildContext context) {
    if (onUpdate != null) {
      controller.addListener(onUpdate);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Styles.searchBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.search,
              color: Styles.searchIconColor,
            ),
            Expanded(
              child: CupertinoTextField(
                autofocus: true,
                decoration: BoxDecoration(color: Styles.searchBackground),
                controller: controller,
                focusNode: focusNode,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
            ),
            GestureDetector(
              onTap: controller.clear,
              child: const Icon(
                CupertinoIcons.clear_thick_circled,
                color: Styles.searchIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}