import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildProfileAvatar(),
                        const SizedBox(height: 32),
                        _buildProfileFields(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, size: 24),
        ),
        Builder(
          builder: (context) => Text(
            'profile'.tr,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed('/edit-profile'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Builder(
              builder: (context) => Text(
                'edit_profile'.tr,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFB3D9F2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar_placeholder.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.grey.shade600,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileFields() {
    return Obx(() => Column(
      children: [
        _buildReadOnlyField('Name', controller.name.value.isEmpty ? '--' : controller.name.value),
        const SizedBox(height: 16),
        _buildReadOnlyField('Email ID', controller.email.value.isEmpty ? '--' : controller.email.value),
        const SizedBox(height: 16),
        _buildReadOnlyField('Mobile Number', controller.mobile.value.isEmpty ? '--' : controller.mobile.value),
        const SizedBox(height: 16),
        _buildReadOnlyField('Gender', controller.gender.value.isEmpty ? '--' : controller.gender.value),
        const SizedBox(height: 16),
        _buildReadOnlyField('DOB', controller.dob.value.isEmpty ? '--' : controller.dob.value),
        const SizedBox(height: 16),
        _buildReadOnlyField('City', controller.city.value.isEmpty ? '--' : controller.city.value),
        const SizedBox(height: 16),
        _buildReadOnlyField('State', controller.state.value.isEmpty ? '--' : controller.state.value),
        const SizedBox(height: 16),
        _buildReadOnlyFieldWithUnit('Height', controller.getHeightDisplay(), controller.heightUnit.value.toUpperCase()),
        const SizedBox(height: 16),
        _buildReadOnlyFieldWithUnit('Weight', controller.getWeightDisplay(), controller.weightUnit.value.toUpperCase()),
      ],
    ));
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyFieldWithUnit(String label, String value, String unit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  unit,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
