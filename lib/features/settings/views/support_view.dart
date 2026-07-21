import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildHeader(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactCard(context),
                    const SizedBox(height: 32),
                    _buildFAQSection(context),
                    const SizedBox(height: 32),
                    _buildSocialLinks(context),
                    const SizedBox(height: 16),
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
    return Row(
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
          'help_support'.tr,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00E3CC), Color(0xFF00A89E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent_outlined,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'need_help'.tr,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'need_help_desc'.tr,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildContactButton(
            context,
            icon: Icons.email_outlined,
            label: 'send_email'.tr,
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'app.caloriz@gmail.com',
                query: 'subject=Support Request',
              );

              try {
                if (!await launchUrl(emailLaunchUri)) {
                  Get.snackbar(
                    'Error',
                    'Could not launch email client',
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Could not launch email client',
                  backgroundColor: Colors.white,
                  colorText: Colors.black,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF00A89E)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00A89E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {'question': 'faq_track_meals_q'.tr, 'answer': 'faq_track_meals_a'.tr},
      {'question': 'faq_accuracy_q'.tr, 'answer': 'faq_accuracy_a'.tr},
      {
        'question': 'faq_customize_macros_q'.tr,
        'answer': 'faq_customize_macros_a'.tr,
      },
      {
        'question': 'faq_cancel_subscription_q'.tr,
        'answer': 'faq_cancel_subscription_a'.tr,
      },
      {'question': 'faq_data_secure_q'.tr, 'answer': 'faq_data_secure_a'.tr},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'faq'.tr,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 20),
        ...faqs.map(
          (faq) => _buildFAQItem(context, faq['question']!, faq['answer']!),
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          iconColor: const Color(0xFF00A89E),
          collapsedIconColor: Theme.of(
            context,
          ).iconTheme.color?.withOpacity(0.5),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  height: 1.6,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'connect_with_us'.tr,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSocialButton(
              context,
              FontAwesomeIcons.tiktok,
              'TikTok',
              'https://www.tiktok.com/@caloriz.app?_r=1&_t=ZS-93ucRa0ao4o',
            ),
            _buildSocialButton(
              context,
              FontAwesomeIcons.instagram,
              'Instagram',
              'https://www.instagram.com/caloriz.app?igsh=MTdjaHYyZHJicmRvNA==',
            ),
            _buildSocialButton(
              context,
              Icons.email,
              'Gmail',
              'mailto:app.caloriz@gmail.com',
            ),
            _buildSocialButton(
              context,
              FontAwesomeIcons.facebook,
              'Facebook',
              'https://www.facebook.com/share/1JFizJ6iHS/',
            ),
            _buildSocialButton(
              context,
              FontAwesomeIcons.xTwitter,
              'X',
              'https://x.com/caloriz_app',
            ),
          ],
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            'app_version'.tr,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    dynamic icon,
    String label,
    String url, {
    String? nativeUrl,
  }) {
    return GestureDetector(
      onTap: () async {
        try {
          if (nativeUrl != null) {
            final Uri nativeUri = Uri.parse(nativeUrl);
            try {
              if (await launchUrl(nativeUri)) {
                return;
              }
            } catch (e) {
              // Ignore invalid native URL launch
            }
          }

          final Uri uri = Uri.parse(url);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            Get.snackbar(
              'Error',
              'Could not launch $label',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
            );
          }
        } catch (e) {
          Get.snackbar(
            'Error',
            'Could not launch $label',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF00E3CC).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: icon is IconData 
            ? Icon(icon, size: 24, color: const Color(0xFF00A89E))
            : FaIcon(icon, size: 24, color: const Color(0xFF00A89E)),
      ),
    );
  }
}
