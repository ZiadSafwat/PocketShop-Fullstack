import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttermart/presentation/Auth/presentation/bloc/auth_bloc.dart';
import 'package:fluttermart/presentation/Auth/presentation/bloc/auth_event.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_list_item_widget.dart';
import './widgets/profile_section_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isDarkMode = false;
  bool biometricEnabled = true;
  bool notificationsEnabled = true;



  final List<Map<String, dynamic>> accountItems = [
    {
      "title": "Edit Profile",
      "icon": "person",
      "route": "/edit-profile",
      "hasDisclosure": true
    },
    {
      "title": "Address Book",
      "icon": "location_on",
      "route": "/address-book",
      "hasDisclosure": true
    },
    {
      "title": "Payment Methods",
      "icon": "credit_card",
      "route": "/payment-methods",
      "hasDisclosure": true
    },
    {
      "title": "Order History",
      "icon": "history",
      "route": "/order-history",
      "hasDisclosure": true
    }
  ];

  final List<Map<String, dynamic>> supportItems = [
    {
      "title": "Help Center",
      "icon": "help",
      "route": "/help-center",
      "hasDisclosure": true
    },
    {
      "title": "Contact Support",
      "icon": "support_agent",
      "route": "/contact-support",
      "hasDisclosure": true
    },
    {"title": "FAQ", "icon": "quiz", "route": "/faq", "hasDisclosure": true}
  ];

  final List<Map<String, dynamic>> appItems = [
    {
      "title": "About",
      "icon": "info",
      "route": "/about",
      "hasDisclosure": true
    },
    {
      "title": "Privacy Policy",
      "icon": "privacy_tip",
      "route": "/privacy-policy",
      "hasDisclosure": true
    },
    {
      "title": "Terms of Service",
      "icon": "description",
      "route": "/terms-of-service",
      "hasDisclosure": true
    },
    {
      "title": "App Version",
      "icon": "info_outline",
      "subtitle": "v2.1.0",
      "hasDisclosure": false
    }
  ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ctx.read<AuthBloc>().add(LogoutEvent());
                Navigator.of(context).pop();


                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   '/login-screen',
                //   (route) => false,
                // );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showPhotoSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Change Profile Photo',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption('Camera', 'camera_alt'),
                  _buildPhotoOption('Gallery', 'photo_library'),
                  _buildPhotoOption('Remove', 'delete'),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption(String title, String iconName) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // Handle photo selection logic here
      },
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(

              onPhotoTap: _showPhotoSelectionSheet,
            ),

            SizedBox(height: 3.h),

            // Account Section
            ProfileSectionWidget(
              title: 'Account',
              children: accountItems
                  .map((item) => ProfileListItemWidget(
                        title: item['title'] as String,
                        iconName: item['icon'] as String,
                        subtitle: item['subtitle'] as String?,
                        hasDisclosure: item['hasDisclosure'] as bool,
                        onTap: () {
                          if (item['route'] != null) {
                            Navigator.pushNamed(
                                context, item['route'] as String);
                          }
                        },
                      ))
                  .toList(),
            ),

            SizedBox(height: 2.h),

            // Settings Section
            ProfileSectionWidget(
              title: 'Settings',
              children: [
                ProfileListItemWidget(
                  title: 'Notifications',
                  iconName: 'notifications',
                  hasDisclosure: false,
                  trailing: Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                ),
                ProfileListItemWidget(
                  title: 'Language',
                  iconName: 'language',
                  subtitle: 'English',
                  hasDisclosure: true,
                  onTap: () {
                    // Handle language selection
                  },
                ),
                ProfileListItemWidget(
                  title: 'Theme',
                  iconName: 'palette',
                  hasDisclosure: false,
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                  ),
                ),
                ProfileListItemWidget(
                  title: 'Biometric Authentication',
                  iconName: 'fingerprint',
                  hasDisclosure: false,
                  trailing: Switch(
                    value: biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        biometricEnabled = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Support Section
            ProfileSectionWidget(
              title: 'Support',
              children: supportItems
                  .map((item) => ProfileListItemWidget(
                        title: item['title'] as String,
                        iconName: item['icon'] as String,
                        hasDisclosure: item['hasDisclosure'] as bool,
                        onTap: () {
                          if (item['route'] != null) {
                            Navigator.pushNamed(
                                context, item['route'] as String);
                          }
                        },
                      ))
                  .toList(),
            ),

            SizedBox(height: 2.h),

            // App Section
            ProfileSectionWidget(
              title: 'App',
              children: appItems
                  .map((item) => ProfileListItemWidget(
                        title: item['title'] as String,
                        iconName: item['icon'] as String,
                        subtitle: item['subtitle'] as String?,
                        hasDisclosure: item['hasDisclosure'] as bool,
                        onTap: () {
                          if (item['route'] != null) {
                            Navigator.pushNamed(
                                context, item['route'] as String);
                          }
                        },
                      ))
                  .toList(),
            ),

            SizedBox(height: 3.h),

            // Logout Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'logout',
                      color: Colors.white,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Logout',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
