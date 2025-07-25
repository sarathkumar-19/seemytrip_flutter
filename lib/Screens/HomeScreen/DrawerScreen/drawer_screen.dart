import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:seemytrip/Constants/colors.dart';
import 'package:seemytrip/Controller/login_controller.dart';
import 'package:seemytrip/Screens/MyAccountScreen/edit_profile_screen.dart';
import 'package:seemytrip/Screens/Utills/common_text_widget.dart';
import 'package:seemytrip/Screens/Utills/lists_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DrawerScreen extends StatefulWidget {
  DrawerScreen({Key? key}) : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final LoginController loginController = Get.find<LoginController>();

  String fullName = "";
  String gender = "";
  String dateOfBirth = "";
  String emailId = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      loginController.isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print("⚠️ No access token found. Please log in again.");
        return;
      }

      final response = await http.get(
        Uri.parse(loginController.userProfileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        loginController.userData.value = responseData;
        print("✅ User Profile: $responseData");

        setState(() {
          fullName =
              "${responseData['firstName'] ?? ''} ${responseData['lastName'] ?? ''}"
                  .trim();
          gender = responseData['gender'] ?? '';
          dateOfBirth = responseData['dob'] ?? '';
          emailId = responseData['email'] ?? '';
        });
      } else {
        print("❌ Failed to fetch profile. Status: ${response.statusCode}");
      }
    } catch (error) {
      print("❌ Exception while fetching profile: $error");
    } finally {
      loginController.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (loginController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: redCA0,
          ),
        );
      }

      return Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            onTap: () {
              Get.to(() => EditProfileScreen());
            },
            leading: Icon(Icons.account_circle, size: 70, color: redCA0),
            title: CommonTextWidget.PoppinsMedium(
              text: fullName.isNotEmpty ? fullName : "Guest User",
              color: black2E2,
              fontSize: 18,
            ),
            subtitle: CommonTextWidget.PoppinsMedium(
              text: "View/Edit Profile",
              color: redCA0,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 10),
          Divider(color: greyE8E, thickness: 1),
          SizedBox(height: 15),
          ListView.builder(
            itemCount: Lists.homeDrawerList.length,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 24),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: InkWell(
                onTap: Lists.homeDrawerList[index]["onTap"],
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: black262.withOpacity(0.25),
                          ),
                        ],
                        color: white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          Lists.homeDrawerList[index]["image"],
                          color: redCA0,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    CommonTextWidget.PoppinsRegular(
                      text: Lists.homeDrawerList[index]["text"],
                      color: black2E2,
                      fontSize: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
