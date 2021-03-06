import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:winterchallenge/core/data/database.dart';
import 'package:winterchallenge/ui/screens/login_page.dart';
import '../../core/services/auth.dart'; /// Used for log out 

/// Screen for viewing user profile and all their commitments.
///
/// Owners: Ashley Alvarez, Christy Koh, Chloe Chan

class ProfileWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileWidgetState();
  }
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final user = auth.FirebaseAuth.instance.currentUser;
  final firebaseRepository = new FirebaseRepository();

  String name;
  bool isBrother;
  String photoUrl;
  ImageProvider profileImage;

  String servanthood;
  bool isEditingServanthood;

  List<String> prayerList;
  bool isEditingPrayer;

  @override
  void initState() {
    super.initState();
    // TODO: init with user data
    name = user.displayName;
    isBrother = true;
    photoUrl = user.photoURL;

    if (photoUrl != null) {
      profileImage = NetworkImage(photoUrl);
    } else {
      profileImage = AssetImage(
          isBrother ? "assets/default_man.jpeg" : "assets/default_woman.jpeg");
    }

    servanthood = "Code the winter challenge app";
    prayerList = ["Christy Koh", "Ashley Alvarez", "Chloe Chan"];
    isEditingServanthood = false;
    isEditingPrayer = false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _profilePic(profileImage),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                  Card(
                      child: Column(
                    children: [
                      ListTile(
                          title: Text('Memory Verse'),
                          trailing: IconButton(
                            icon: Icon(Icons.arrow_forward_ios_rounded),
                            onPressed: () {},
                          )),
                      Divider(),
                      TextfieldWidget(),
                      Divider(),
                      _PrayerChipWidget(people: prayerList),
                    ],
                  )),
                  _logOutWidget(context)
                ])),
      );
}

/// A button that logs the user out when pressed, then returns to login page
Widget _logOutWidget(BuildContext context) {
  return RaisedButton(
    onPressed: () async {
      // Sign out
      await signOutGoogle();
      // Return to login page
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
    },
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
  );
}

Widget _profilePic(ImageProvider image) => Stack(
      alignment: const Alignment(0.6, 0.6),
      children: [
        CircleAvatar(
          backgroundImage: image,
          backgroundColor: Colors.white,
          radius: 100,
        )
      ],
    );

class TextfieldWidget extends StatefulWidget {
  final TextEditingController _editingController = TextEditingController();
  String initialText = 'Write your commitment here!';

  @override
  State<StatefulWidget> createState() {
    return _TextfieldWidgetState();
  }
}

class _TextfieldWidgetState extends State<TextfieldWidget> {
  bool _isEditingText = false;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text('Servanthood'),
        subtitle: _editTitleTextField(),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            setState(() {
              _isEditingText = !_isEditingText;
            });
          },
        ),
      );

  Widget _editTitleTextField() {
    if (_isEditingText)
      return Column(children: [
        TextField(
          onSubmitted: (newValue) {
            setState(() {
              widget.initialText = newValue;
              _isEditingText = false;
            });
          },
          autofocus: true,
          controller: widget._editingController,
        ),
        new RaisedButton(
          child: new Text("Done Editing"),
          onPressed: () {
            setState(() {
              widget.initialText = widget._editingController.text;
              _isEditingText = false;
            });
          },
        ),
      ]);
    return InkWell(
        child: Text(
      widget.initialText,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18.0,
      ),
    ));
  }

  @override
  void dispose() {
    widget._editingController.dispose();
    super.dispose();
  }
}

class _PrayerChipWidget extends StatefulWidget {
  List<String> people;

  _PrayerChipWidget({Key key, @required this.people}) : super(key: key);

  @override
  _PrayerChipWidgetState createState() => new _PrayerChipWidgetState();
}

class _PrayerChipWidgetState extends State<_PrayerChipWidget> {
  TextEditingController _textEditingController = new TextEditingController();
  bool isEditing = false;

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }

  Widget buildChips() {
    List<Widget> chips = new List();

    if (isEditing) {
      for (int i = 0; i < widget.people.length; i++) {
        InputChip actionChip = InputChip(
          label: Text(widget.people[i]),
          elevation: 10,
          pressElevation: 5,
          shadowColor: Colors.lightBlue,
          onDeleted: () {
            widget.people.removeAt(i);

            setState(() {
              widget.people = widget.people;
            });
          },
        );
        chips.add(actionChip);
      }
    } else {
      // no delete
      for (int i = 0; i < widget.people.length; i++) {
        InputChip actionChip = InputChip(
            label: Text(widget.people[i]),
            elevation: 10,
            pressElevation: 5,
            shadowColor: Colors.lightBlue);
        chips.add(actionChip);
      }
    }

    return Wrap(spacing: 6.0, children: chips);
  }

  @override
  Widget build(BuildContext context) {
    Widget inner;

    if (!isEditing) {
      inner = SizedBox();
    } else {
      inner = TextFormField(
        controller: _textEditingController,
        onFieldSubmitted: (text) {
          if (widget.people.length < 5) {
            widget.people.add(text);
          }
          _textEditingController.clear();

          setState(() {
            widget.people = widget.people;
          });
        },
      );
    }

    return ListTile(
      title: Text('Prayer'),
      subtitle: Container(
        child: Column(
          children: <Widget>[buildChips(), inner],
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            isEditing = !isEditing;
          });
        },
      ),
    );
  }
}
