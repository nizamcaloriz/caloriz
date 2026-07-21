import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/language_controller.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_language'.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            ...languageController.locales.entries.map((entry) {
              return Obx(() {
                final isSelected = languageController.currentLocale.value == entry.value;
                return InkWell(
                  onTap: () async {
                    await languageController.changeLanguage(entry.key);
                    Get.back();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF00E0C6).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF00E0C6)
                            : Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key.toLowerCase().tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF00E0C6)
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF00E0C6),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              });
            }),
          ],
        ),
      ),
    );
  }
}
