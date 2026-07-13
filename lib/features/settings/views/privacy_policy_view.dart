import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      'info_we_collect'.tr,
                      'info_we_collect_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'how_we_use'.tr,
                      'how_we_use_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'data_storage_security'.tr,
                      'data_storage_security_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'data_sharing'.tr,
                      'data_sharing_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'your_rights'.tr,
                      'your_rights_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'cookies_tracking'.tr,
                      'cookies_tracking_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'children_privacy'.tr,
                      'children_privacy_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'third_party_links'.tr,
                      'third_party_links_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'changes_to_policy'.tr,
                      'changes_to_policy_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'contact_us'.tr,
                      'contact_us_desc'.tr,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'last_updated'.tr,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back,
              size: 24,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'privacy_policy_title'.tr,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00A89E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.lato(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
