import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

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
                      'introduction'.tr,
                      'introduction_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'use_of_service'.tr,
                      'use_of_service_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'user_content'.tr,
                      'user_content_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'health_disclaimer'.tr,
                      'health_disclaimer_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'prohibited_activities'.tr,
                      'prohibited_activities_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'intellectual_property'.tr,
                      'intellectual_property_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'subscription_payments'.tr,
                      'subscription_payments_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'termination'.tr,
                      'termination_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'changes_to_terms'.tr,
                      'changes_to_terms_desc'.tr,
                    ),
                    _buildSection(
                      context,
                      'contact_us_terms'.tr,
                      'contact_us_terms_desc'.tr,
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
            'terms_conditions_title'.tr,
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
