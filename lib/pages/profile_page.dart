import 'package:flutter/material.dart';
import 'jual_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Page'), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/100'),
            ),
            SizedBox(height: 20),
            Text(
              'Profile Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('dalam profile', style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('dalam profile', style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('dalam profile', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JualPage()),
                );
              },
              child: Text('Go to Jual Page'),
            ),
          ],
        ),
      ),
    );
  }
} //End Stream
