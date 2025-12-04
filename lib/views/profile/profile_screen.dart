import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/providers/user_profile_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Consumer<UserprofileProvider>(
            builder: (context, provider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // avatar
                  Center(
                    child: InkWell(
                      onTap: () async {
                        await provider.pickImage(context);
                      },
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.blue[50],
                        // replace with AssetImage('assets/avatar.png') if you add asset
                        backgroundImage: provider.uint8list == null
                            ? const NetworkImage(
                                'https://cdn-icons-png.flaticon.com/512/219/219983.png',
                              )
                            : MemoryImage(provider.uint8list!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    provider.userModel.firstName ?? "",
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Parent ID
                  Text(
                    'Parents ID: 000123',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Edit info link
                  InkWell(
                    onTap: () async {
                      // final provider = Provider.of<AuthProviders>(
                      //   context,
                      //   listen: false,
                      // );
                      // await provider.logout(context);

                      Navigator.pushNamed(context, AppRoutes.editprofile);
                    },
                    child: Text(
                      'Edit info',
                      style: textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        color: Colors.grey[800],
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Personal info section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Personal info',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildInfoRow('Email', provider.userModel.email ?? ""),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Phone',
                    '${provider.userModel.phoneCode} ${provider.userModel.phoneNumber}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Date of Birth', '08 Feb 2001'),

                  const SizedBox(height: 18),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Preferences',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Cards list like screenshot
                  _buildPreferenceCard(
                    context,
                    title: 'Students',
                    subtitle: 'Manage students profiles here',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.studentsScreen);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceCard(
                    context,
                    title: 'Packages',
                    subtitle: 'Manage students profiles here',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildPreferenceCard(
                    context,
                    title: 'Orders',
                    subtitle: 'Manage students profiles here',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.ordersScreen);
                    },
                  ),

                  const SizedBox(height: 12),
                  _buildSettingsCard(context),

                  const SizedBox(height: 90),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildPreferenceCard(
    BuildContext context, {
    required void Function()? onTap,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      splashColor: AppColors.thirdPrimary,
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return InkWell(
      splashColor: AppColors.thirdPrimary,
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'App Setting Centrew',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.settings_outlined, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
