import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:crud_firebase_5/model/user.dart';
import 'package:crud_firebase_5/page/user_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Firestore CRUD Write';

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('All Users'),
        ),
        body: buildUsers(),
        // body: buildSingleUser(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const UserPage(),
            ));
          },
        ),
      );

  Widget buildUsers() => StreamBuilder<List<User>>(
      stream: readUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final users = snapshot.data!;

          return ListView(
            children: users.map(buildUser).toList(),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      });

  Widget buildUser(User user) => ListTile(
        leading: CircleAvatar(child: Text('${user.age}')),
        title: Text(user.name),
        subtitle: Text(user.birthday.toIso8601String()),
        trailing: GestureDetector(
          child: const Icon(Icons.delete),
          onTap: () {
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.id)
                .delete();

            const snackBar = SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Deleted from Firebase!',
                style: TextStyle(fontSize: 24),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserPage(user: user),
        )),
      );

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

  // Widget buildSingleUser() => FutureBuilder<User?>(
  //       future: readUser(),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasError) {
  //           return Text('Something went wrong! ${snapshot.error}');
  //         } else if (snapshot.hasData) {
  //           final user = snapshot.data;

  //           return user == null
  //               ? const Center(child: Text('No User'))
  //               : buildUser(user);
  //         } else {
  //           return const Center(child: CircularProgressIndicator());
  //         }
  //       },
  //     );

  // Future<User?> readUser() async {
  //   /// Get single document by ID
  //   final docUser = FirebaseFirestore.instance.collection('users').doc('my-id');
  //   final snapshot = await docUser.get();

  //   if (snapshot.exists) {
  //     return User.fromJson(snapshot.data()!);
  //   }
  //   return null;
  // }
}
