import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/providers/auth_provider.dart';
import 'package:wisdom_portal_1/screens/signup_screen.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/custom_elevated_button.dart';
import 'package:wisdom_portal_1/widgets/custom_text_field.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrappper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    final resetKey = GlobalKey<FormState>();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Reset Password"),
              content: Form(
                key: resetKey,
                child: CustomTextField(
                  text: "enter your email",
                  controller: resetEmailController,
                  prefixIcon: Icons.email,
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
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          if (resetKey.currentState!.validate()) {
                            setDialogState(() => isSending = true);

                            final success = await context
                                .read<AuthProvider>()
                                .sendPasswordReset(
                                  resetEmailController.text.trim(),
                                );

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password reset link sent! Check your email.",
                                  ),
                                ),
                              );
                            } else {
                              setDialogState(() => isSending = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.read<AuthProvider>().errorMsg ??
                                        "Failed to send reset email.",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Send Link"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                        "Welcome Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF202A36),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Sign in to continue to your portal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 28),
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
                        text: "enter your password",
                        controller: passwordController,
                        textCapitalization: TextCapitalization.words,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return " enter your password";
                          }

                          if (value.length < 8) {
                            return "password must be at least 8 character";
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
                                text: "Login",
                                onpressed: () async {
                                  if (_key.currentState!.validate()) {
                                    await context.read<AuthProvider>().login(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                  }
                                },
                              ),
                      ),

                      const SizedBox(height: 4),

                      Align(
                        alignment: Alignment.centerRight,

                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,

                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color(0xFF123D78),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "Don't have an account?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColor.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupScreen(),
                                ),
                              );
                            },

                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xFFD6A928),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
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
