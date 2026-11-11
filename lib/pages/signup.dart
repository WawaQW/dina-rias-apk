import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'widget/button.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Ubah ke true agar layout menyesuaikan dengan keyboard
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(
        title: 'Register',
        showBackButton: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Tambahkan physics agar scroll lebih smooth
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Pastikan content minimal setinggi viewport
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tambahkan spacing atas yang flexible
                          const Spacer(flex: 1),

                          // Profile Image using shared widget
                          const ProfileImage(
                            radius: 60,
                            hasCircleAvatar: false,
                          ),

                          const SizedBox(height: 32),

                          // Username field using shared widget
                          CustomTextField(
                            controller: _usernameController,
                            hintText: 'Username',
                            prefixIcon: Icons.person_outline,
                            marginBottom: 16,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),

                          // WhatsApp field using shared widget
                          CustomTextField(
                            controller: _whatsappController,
                            hintText: 'No. Whatsapp',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            marginBottom: 16,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your WhatsApp number';
                              }
                              if (value.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),

                          // Email field using shared widget
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            marginBottom: 16,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          // Password field using shared widget
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureText,
                            marginBottom: 24,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: PasswordVisibilityIcon(
                              obscureText: _obscureText,
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),

                          // Sign Up button using shared widget
                          GradientButton(
                            text: 'Sign Up',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Handle registration logic here
                                await AuthService().sendOTPViaWhatsApp(
                                    username: _usernameController.text,
                                    whatsapp: _whatsappController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    context: context);
                              }
                            },
                          ),

                          const SizedBox(height: 24),

                          // Already have account text using shared widget
                          LinkText(
                            normalText: "Already Have Account? ",
                            linkText: "Log In",
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),

                          // Tambahkan spacing bawah yang flexible
                          const Spacer(flex: 1),

                          // Tambahkan sedikit padding bawah
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
