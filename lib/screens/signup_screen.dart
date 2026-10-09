import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/providers/auth_provider.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/custom_elevated_button.dart';
import 'package:wisdom_portal_1/widgets/custom_text_field.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrappper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      body: ResponsiveWrapper(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),

              child: Form(
                key: _key,
                autovalidateMode: AutovalidateMode.onUserInteraction,

                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 150,
                        height: 150,

                        padding: const EdgeInsets.all(8),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,

                          border: Border.all(
                            color: const Color(0xFFD6A928),
                            width: 2,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF123D78,
                              ).withValues(alpha: 0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),

                        child: ClipOval(
                          child: Image.asset(
                            "lib/assets/images/school_logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "WISDOM",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF123D78),
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 2),

                      const Text(
                        "ACADEMIC CENTER",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFD6A928),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        "Create Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF202A36),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Create your account to access the portal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 28),

                      CustomTextField(
                        text: "enter full name",
                        controller: nameController,
                        prefixIcon: Icons.person,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "enter your name";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      CustomTextField(
                        text: "enter email",
                        controller: emailController,
                        prefixIcon: Icons.email,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "enter your email";
                          }

                          if (!value.contains("@")) {
                            return "enter a valid email (@)";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      CustomTextField(
                        prefixIcon: Icons.lock,
                        text: "enter password",
                        controller: passwordController,
                        textCapitalization: TextCapitalization.words,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "enter your password";
                          }

                          if (value.length < 8) {
                            return "password must be at least 8 character";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      CustomTextField(
                        prefixIcon: Icons.lock,
                        text: "confirm password",
                        controller: confirmPasswordController,
                        textCapitalization: TextCapitalization.words,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "enter your password again";
                          }

                          if (value != passwordController.text) {
                            return "passwords do not match";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      if (authProvider.errorMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.15),
                              ),
                            ),

                            child: Text(
                              authProvider.errorMsg!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,

                        child: authProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomElevatedButton(
                                text: "Sign Up",
                                onpressed: () async {
                                  if (_key.currentState!.validate()) {
                                    bool success = await context
                                        .read<AuthProvider>()
                                        .signUp(
                                          nameController.text.trim(),
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );

                                    if (success && context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "Already have an account?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColor.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Color(0xFFD6A928),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // FOOTER
                      Text(
                        "Empowering Minds • Building Futures",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
