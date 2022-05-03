import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:crud_firebase_5/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserPage extends StatefulWidget {
  final Member? user;

  const UserPage({Key? key, this.user}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController controllerName;
  late TextEditingController controllerAge;
  late TextEditingController controllerDate;

  @override
  void initState() {
    super.initState();

    controllerName = TextEditingController();
    controllerAge = TextEditingController();
    controllerDate = TextEditingController();

    if (widget.user != null) {
      final user = widget.user!;

      controllerName.text = user.name;
      controllerAge.text = user.age.toString();
      controllerDate.text = DateFormat('yyyy-MM-dd').format(user.birthday);
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerAge.dispose();
    controllerDate.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? controllerName.text : 'Add User'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteUser(widget.user!);

                final snackBar = SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(
                    'Deleted ${controllerName.text} to Firebase!',
                    style: const TextStyle(fontSize: 24),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: controllerName,
              decoration: decoration('Name'),
              validator: (text) =>
                  text != null && text.isEmpty ? 'Not valid input' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: controllerAge,
              decoration: decoration('Age'),
              keyboardType: TextInputType.number,
              validator: (text) => text != null && int.tryParse(text) == null
                  ? 'Not valid input'
                  : null,
            ),
            const SizedBox(height: 24),
            DateTimeField(
              initialValue: widget.user?.birthday,
              controller: controllerDate,
              decoration: decoration('Birthday'),
              validator: (dateTime) =>
                  dateTime == null ? 'Not valid input' : null,
              format: DateFormat('yyyy-MM-dd'),
              onShowPicker: (context, currentValue) => showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                initialDate: currentValue ?? DateTime.now(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: Text(isEditing ? 'Save' : 'Create'),
              onPressed: () {
                final isValid = formKey.currentState!.validate();

                if (isValid) {
                  final user = Member(
                    id: widget.user?.id ?? '',
                    name: controllerName.text,
                    age: int.parse(controllerAge.text),
                    birthday: DateTime.parse(controllerDate.text),
                  );

                  if (isEditing) {
                    updateUser(user);
                  } else {
                    createUser(user);
                  }

                  final action = isEditing ? 'Edited' : 'Added';
                  final snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      '$action ${controllerName.text} to Firebase!',
                      style: const TextStyle(fontSize: 24),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration decoration(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      );

  Future createUser(Member user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    user.id = docUser.id;

    final json = user.toJson();
    await docUser.set(json);
  }

  Future updateUser(Member user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user.id);

    final json = user.toJson();
    await docUser.update(json);
  }

  Future deleteUser(Member user) async {
    /// Reference to document
    final docUser = FirebaseFirestore.instance.collection('users').doc(user.id);

    await docUser.delete();
  }
}
