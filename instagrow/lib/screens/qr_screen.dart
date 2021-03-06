import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/services/database_service.dart';
import 'package:instagrow/utils/style.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class QRScreen extends StatefulWidget {
  final Plant _plant;

  const QRScreen(this._plant);

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String _displayedCode;

  @override
  void initState() {
    _displayedCode = "";

    DatabaseService.getCurrentQrCode(widget._plant).then((String code) {
      if (code != null) {
        setState(() {
          _displayedCode = code;
        });
      }
    });

    super.initState();
  }

  Widget _qrSection() {
    if (_displayedCode == "") {
      double size = MediaQuery.of(context).size.width;
      return Container(
        width: size,
        height: size,
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(32),
        child: QrImage(
          data: _displayedCode,
          foregroundColor: CupertinoColors.black,
          backgroundColor: CupertinoColors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: Styles.activeColor(context),
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.share),
          onTap: () {
            Share.share(
              _displayedCode,
              subject: "Hello World",
            );
          },
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _qrSection(),
              Container(
                height: 32,
              ),
              CupertinoButton(
                child: Text(
                  "Generate new QRCode",
                  style: Styles.generateCode(context),
                ),
                onPressed: () async {
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text(
                          "Renew QR Code",
                          style: Styles.dialogTitle(context),
                        ),
                        content: Text(
                          "The current QR code will be deactivated.",
                          style: Styles.dialogContent(context),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text(
                              "Cancel",
                              style: Styles.dialogActionNormal(context),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text(
                              "Confirm",
                              style: Styles.dialogActionNormal(context),
                            ),
                            onPressed: () {
                              DatabaseService.createQrInstance(widget._plant)
                                  .then((String newCode) {
                                if (newCode != null) {
                                  setState(() {
                                    _displayedCode = newCode;
                                  });
                                } else {
                                  setState(() {
                                    _displayedCode = "";
                                  });
                                }
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
