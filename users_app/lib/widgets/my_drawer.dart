import 'package:flutter/material.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/splashScreen/splash_screen.dart';

class MyDrawer extends StatefulWidget {
  String? name;
  String? email;

  MyDrawer({
    Key? key, // Use Key? to accept a nullable key parameter
    this.name,
    this.email,
  }) : super(key: key); // Pass the key parameter to the superclass constructor

  // MyDrawer({super.key, this.name, this.email});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

/*In the context of Flutter, the term "drawer" typically refers to a user interface component called a "Drawer." A Drawer is a widget that slides in from the side of the screen, typically from the left, to reveal a navigation menu or a set of options. It's a common pattern used in mobile app development to provide users with access to various app features and navigation options.

The Drawer widget is often used in combination with a hamburger menu icon (a stack of horizontal lines) or other similar icons to indicate to users that they can swipe or tap to open the Drawer. When the Drawer is opened, it can display a list of items, links, or any other content that helps users navigate the app or access additional functionality.*/

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    // // Accessing the 'name' and 'email' properties using 'widget' keyword
    // String? name = widget.name;
    // String? email = widget.email;

    return Drawer(
      child: ListView(
        children: [
          //drawer has a header and a body
          //implementing the drawer header here
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //text is not constant here bcz if only user neha kharat is online then the name will be neha kharat at that time. Therefore, only the textstyle will be constant and not the text.
                      Text(
                        widget.name.toString(),
                        //  widget.name?.toString() ?? 'Default Name',
                        // widget.name?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 12.0,
          ),

          //implementing the drawer body
          //for click event we use gestureDetector
          GestureDetector(
            onTap: () {},
            child: const ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.black,
              ), //leading means 1st Drawer option in the Drawer body
              title: Text(
                "History",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {},
            child: const ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.black,
              ), //leading means 1st Drawer option in the Drawer body
              title: Text(
                "Profile",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {},
            child: const ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.black,
              ), //leading means 1st Drawer option in the Drawer body
              title: Text(
                "About",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              fAuth.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MySplashScreen()));
            },
            child: const ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.black,
              ), //leading means 1st Drawer option in the Drawer body
              title: Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
