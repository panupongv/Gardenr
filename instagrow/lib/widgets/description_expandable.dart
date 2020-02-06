import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/utils/style.dart';

class DescriptionExpandable extends StatefulWidget {
  final String _description;

  static const int MAX_LINES_FIXED_BOX = 5, MAX_LINES_SCROLLABLE = 10;

  DescriptionExpandable(this._description);

  @override
  _DescriptionExpandableState createState() => _DescriptionExpandableState();
}

class _DescriptionExpandableState extends State<DescriptionExpandable> {
  bool showingMore;

  @override
  void initState() {
    showingMore = false;
    super.initState();
  }

  Widget _showLessOrMoreButton() {
    return GestureDetector(
      child: Text(
        showingMore ? "\nshow less" : "\n... more",
        textAlign: TextAlign.left,
        style: Styles.moreLessButton(context),
      ),
      onTap: () {
        setState(() {
          showingMore = !showingMore;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        TextSpan span = TextSpan(text: widget._description);
        TextPainter needsShowMoreIndicator = TextPainter(
            text: span,
            maxLines: DescriptionExpandable.MAX_LINES_FIXED_BOX,
            textDirection: TextDirection.ltr);
        needsShowMoreIndicator.layout(maxWidth: constraints.maxWidth);

        Widget descriptionBox;
        if (needsShowMoreIndicator.didExceedMaxLines) {
          descriptionBox = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              showingMore
                  ? Text(
                      widget._description,
                      style: Styles.descriptionExpandableText(context),
                    )
                  : Text(
                      widget._description,
                      maxLines: DescriptionExpandable.MAX_LINES_FIXED_BOX,
                      style: Styles.descriptionExpandableText(context),
                    ),
              _showLessOrMoreButton(),
            ],
          );
        } else {
          descriptionBox = Text(widget._description,
              style: Styles.descriptionExpandableText(context));
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: descriptionBox,
        );
      },
    );
  }
}
