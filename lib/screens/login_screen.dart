import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/storage/local_storage.dart';
import '../core/theme/app_theme.dart';
import 'root_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController =
      TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Pre-populate mock user for easy testing
    _loginEmailController.text = 'admin@emagz.com';
    _loginPasswordController.text = 'password123';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network authentication delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if ((email == 'admin@emagz.com' || email == 'user@emagz.com') &&
        password == 'password123') {
      await LocalStorage.setBool('isLoggedIn', true);
      await LocalStorage.setString('user_name', 'me_adventurer');
      await LocalStorage.setString('user_email', email);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful! Welcome back.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RootNavigationShell()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Invalid credentials. Use admin@emagz.com / password123',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    final name = _signupNameController.text.trim();
    final email = _signupEmailController.text.trim();

    await LocalStorage.setBool('isLoggedIn', true);
    await LocalStorage.setString('user_name', name);
    await LocalStorage.setString('user_email', email);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created! Welcome, $name.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RootNavigationShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Brand Logo Header
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.fameoPurpleGradientStart,
                          AppColors.fameoPurpleGradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'F',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'fameo - X',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Connect & Update Instantly',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Login/Signup Card Container
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tab Bar Selector
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              labelColor: AppColors.fameoPurpleGradientEnd,
                              unselectedLabelColor: AppColors.textMuted,
                              labelStyle: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              unselectedLabelStyle: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Login'),
                                Tab(text: 'Sign Up'),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Tab Views
                          AnimatedBuilder(
                            animation: _tabController,
                            builder: (context, _) {
                              return IndexedStack(
                                index: _tabController.index,
                                children: [
                                  _buildLoginForm(),
                                  _buildSignupForm(),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: _inputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: _inputDecoration(
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 12),

          // Credentials hint info
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Demo credentials: admin@emagz.com / password123',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.fameoPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Action Button
          _buildActionButton(
            label: 'LOG IN',
            onPressed: _isLoading ? null : _handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          TextFormField(
            controller: _signupNameController,
            keyboardType: TextInputType.name,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: _inputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: _signupEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: _inputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _signupPasswordController,
            obscureText: _obscureSignupPassword,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: _inputDecoration(
              labelText: 'Create Password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignupPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureSignupPassword = !_obscureSignupPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please choose a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 24),

          // Action Button
          _buildActionButton(
            label: 'CREATE ACCOUNT',
            onPressed: _isLoading ? null : _handleSignup,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: AppColors.fameoPurple, size: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.fameoPurple, width: 1.5),
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: onPressed == null
            ? null
            : LinearGradient(
                colors: [
                  AppColors.fameoPurpleGradientStart,
                  AppColors.fameoPurpleGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: onPressed == null ? Colors.grey[300] : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
