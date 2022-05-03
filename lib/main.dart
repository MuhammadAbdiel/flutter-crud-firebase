import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase_5/google_sign_in_provider.dart';
import 'package:crud_firebase_5/page/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:crud_firebase_5/model/user.dart';
import 'package:crud_firebase_5/page/user_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  static const String title = 'Firestore CRUD Write';

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: title,
        home: const SignUp(),
      ),
    );
  }
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
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: buildUsers(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const UserPage(),
            ));
          },
        ),
      );

  Widget buildUsers() => StreamBuilder<List<Member>>(
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

  Widget buildUser(Member user) => ListTile(
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

  Stream<List<Member>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Member.fromJson(doc.data())).toList());
}
