import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, 
          title: Text(
            "Settings",
            style: GoogleFonts.roboto(
              color: Colors.black,
            ), // set color explicitly
          ),
          bottom: TabBar(
            labelColor: Colors.black, // active tab text color
            unselectedLabelColor: Colors.grey, // inactive tab text color
            indicatorColor: Colors.blue,
            dividerColor: Colors.black,
           indicator: const UnderlineTabIndicator(
             borderSide: BorderSide(color: Colors.black, width: 5.0),
           ), 
            tabs: const [
              Tab(text: "General" ),
              Tab(text: "Account"),
              Tab(text: "Notifications"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            AccountsTab(),
            _buildTabPage(context, "Account Settings Content"),
            _buildTabPage(context, "Notification Preferences Content"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPage(BuildContext context, String contentText) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(
            contentText,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


class AccountsTab extends StatelessWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Text(
            "Profile",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/avatar.png"), // Add your image here
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "View and edit your profile information",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 32),

          // Account Section
          Text(
            "Account",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to change password
            },
          ),
          const Divider(),
          ListTile(
            title: const Text("Delete Account"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to delete account
            },
          ),
        ],
      ),
    );
  }
}
