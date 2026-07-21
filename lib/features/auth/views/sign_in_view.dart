import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sign_in_controller.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
              
              // App Logo
              Image.asset(
                'assets/images/splash_logo.png',
                width: 200,
                height: 200,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E3CC).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 60,
                      color: Color(0xFF00E3CC),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                'welcome_to_caloriz'.tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'sign_in_subtitle'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Email TextField
              TextField(
                onChanged: (value) => controller.email.value = value,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF00E3CC),
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Password TextField
              Obx(() => TextField(
                onChanged: (value) => controller.password.value = value,
                obscureText: controller.obscurePassword.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF00E3CC),
                      width: 2,
                    ),
                  ),
                ),
              )),
              
              const SizedBox(height: 24),
              
              // Sign In Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E3CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: const Color(0xFF00E3CC).withOpacity(0.5),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),
              
              const SizedBox(height: 24),
              
              // Divider with "OR"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Continue with Google Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: controller.signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    side: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'continue_with_google'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
