import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Creates the Cupertino-style search bar. See the README for an example on how to use.
class IOSSearchBar extends AnimatedWidget {
  /// https://github.com/dnys1/ios_search_bar
  IOSSearchBar({
    Key key,
    @required Animation<double> animation,
    @required this.controller,
    @required this.focusNode,
    this.onCancel,
    this.onClear,
    this.onSubmit,
    this.onUpdate,
    this.onSearch,
    this.autoFocus = true,
  })  : assert(controller != null),
        assert(focusNode != null),
        super(key: key, listenable: animation);

  /// The text editing controller to control the search field
  final TextEditingController controller;

  /// The focus node needed to manually unfocus on clear/cancel
  final FocusNode focusNode;

  /// The function to call when the "Cancel" button is pressed
  final Function onCancel;

  /// The function to call when the "Clear" button is pressed
  final Function onClear;

  /// The function to called when search is started
  final Function onSearch;

  /// The function to call when the text is updated
  final Function(String) onUpdate;

  /// The function to call when the text field is submitted
  final Function(String) onSubmit;

  static final _opacityTween =  Tween(begin: 1.0, end: 0.0);
  static final _paddingTween =  Tween(begin: 0.0, end: 60.0);
  static final _kFontSize = 16.0;
  final bool autoFocus;
  final Key _inputKey =  GlobalKey(debugLabel: 'inputText');
  @override
  Widget build(BuildContext context) {
    // if (!isSearching) {
    //   return GestureDetector(
    //     onTap: onSearch,
    //     child: Padding(
    //       padding: const EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 8.0),
    //       child:  Row(
    //         children: <Widget>[
    //            Expanded(
    //             child:  Container(
    //               padding: const EdgeInsets.symmetric(
    //                   horizontal: 8.0, vertical: 6.0),
    //               decoration:  BoxDecoration(
    //                 color: CupertinoColors.lightBackgroundGray,
    //                 border:  Border.all(
    //                     width: 0.0, color: CupertinoColors.white),
    //                 borderRadius:  BorderRadius.circular(10.0),
    //               ),
    //               child:  Stack(
    //                 alignment: Alignment.centerLeft,
    //                 children: <Widget>[
    //                    Row(
    //                     mainAxisAlignment: MainAxisAlignment.start,
    //                     children: <Widget>[
    //                        Padding(
    //                         padding:
    //                             const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 1.0),
    //                         child:  Icon(
    //                           CupertinoIcons.search,
    //                           color: CupertinoColors.inactiveGray,
    //                           size: _kFontSize + 2.0,
    //                         ),
    //                       ),
    //                        Text(
    //                         'Search',
    //                         style:  TextStyle(
    //                             inherit: false,
    //                             color: CupertinoColors.inactiveGray),
    //                       ),
    //                     ],
    //                   ),
    //                    Row(
    //                     mainAxisAlignment: MainAxisAlignment.end,
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: <Widget>[
    //                        Expanded(
    //                         child:  Padding(
    //                           padding: const EdgeInsets.only(left: 20.0),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    final Animation<double> animation = listenable;
    return  Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
      child:  Row(
        children: <Widget>[
           Expanded(
            child:  Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              decoration:  BoxDecoration(
                color: CupertinoColors.lightBackgroundGray,
                border:
                     Border.all(width: 0.0, color: CupertinoColors.white),
                borderRadius:  BorderRadius.circular(10.0),
              ),
              child:  Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                   Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                       Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 1.0),
                        child:  Icon(
                          CupertinoIcons.search,
                          color: CupertinoColors.inactiveGray,
                          size: _kFontSize + 2.0,
                        ),
                      ),
                       Text(
                        'Search',
                        style: TextStyle(
                          inherit: false,
                          color: CupertinoColors.inactiveGray
                              .withOpacity(_opacityTween.evaluate(animation)),
                          fontSize: _kFontSize,
                        ),
                      ),
                    ],
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                       Expanded(
                        child:  Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child:  EditableText(
                            key: _inputKey,
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: onUpdate,
                            autofocus: autoFocus,
                            onSubmitted: onSubmit,
                            style:  TextStyle(
                              color: CupertinoColors.black,
                              inherit: false,
                              fontSize: _kFontSize,
                            ),
                            cursorColor: CupertinoColors.black,
                            backgroundCursorColor: Colors.grey,
                            // backgroundCursorColor: Colors.grey,
                          ),
                        ),
                      ),
                       CupertinoButton(
                        minSize: 10.0,
                        padding: const EdgeInsets.all(1.0),
                        borderRadius:  BorderRadius.circular(30.0),
                        color: CupertinoColors.inactiveGray.withOpacity(
                          1.0 - _opacityTween.evaluate(animation),
                        ),
                        child:  Icon(
                          Icons.close,
                          size: 8.0,
                          color: CupertinoColors.white,
                        ),
                        onPressed: () {
                          if (animation.isDismissed)
                            return;
                          else
                            onClear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
           SizedBox(
            width: _paddingTween.evaluate(animation),
            child:  CupertinoButton(
              padding: const EdgeInsets.only(left: 8.0),
              onPressed: onCancel,
              child:  Text(
                'Cancel',
                softWrap: false,
                style:  TextStyle(
                  inherit: false,
                  color: CupertinoColors.activeBlue,
                  fontSize: _kFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
