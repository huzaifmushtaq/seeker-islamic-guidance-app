import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0B4B4B),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B4B4B),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter your registered email address and we'll send you a password reset link.",
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),

              const SizedBox(height: 35),

              TextFormField(
                controller: emailController,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your email";
                  }

                  final emailRegex = RegExp(
                    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                  );

                  if (!emailRegex.hasMatch(value.trim())) {
                    return "Please enter a valid email";
                  }

                  return null;
                },

                decoration: InputDecoration(
                  hintText: "Email Address",

                  prefixIcon: const Icon(Icons.email_outlined),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),

                    borderSide: const BorderSide(color: Color(0x220B4B4B)),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),

                    borderSide: const BorderSide(
                      color: Color(0xFF0B4B4B),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          setState(() {
                            isLoading = true;
                          });

                          final error = await _authService.resetPassword(
                            emailController.text.trim().toLowerCase(),
                          );

                          if (!mounted) return;

                          setState(() {
                            isLoading = false;
                          });

                          if (error == null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Password reset link sent."),
                              ),
                            );

                            Future.delayed(const Duration(seconds: 2), () {
                              if (!mounted) return;
                              navigator.pop();
                            });
                          } else {
                            messenger.showSnackBar(
                              SnackBar(content: Text(error)),
                            );
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4B4B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Send Reset Link",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
