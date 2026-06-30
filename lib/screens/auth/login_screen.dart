import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';
import '/services/guest_service.dart';
import '/screens/main_navigation_screen.dart';
late bool isLogin;
bool hidePassword = true;
bool hideConfirmPassword = true;
bool isLoading = false;
final TextEditingController nameController =
    TextEditingController();

final TextEditingController emailController =
    TextEditingController();

final TextEditingController passwordController =
    TextEditingController();

final TextEditingController confirmPasswordController =
    TextEditingController();
final _formKey = GlobalKey<FormState>();
class LoginScreen extends StatefulWidget {

  final bool startWithLogin;

  const LoginScreen({
    super.key,
    this.startWithLogin = true,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}
final AuthService _authService = AuthService();
class _LoginScreenState extends State<LoginScreen> {
  @override
void initState() {
  super.initState();

  isLogin = widget.startWithLogin;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 235, 235),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER IMAGE
              Container(
                width: double.infinity,
                height: 310,

                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/loginbg.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// LOGIN CARD
  Transform.translate(
  offset: const Offset(0, -45),

  child: Container(
    width: double.infinity,

    margin: const EdgeInsets.symmetric(
      horizontal: 16,
    ),

    padding: const EdgeInsets.fromLTRB(
      24,
      28,
      24,
      24,
    ),

    decoration: BoxDecoration(
      color: const Color(0xFF0B4B4B),

      borderRadius: BorderRadius.circular(34),

      border: Border.all(
        color: const Color(0x33F4D17D),
      ),

      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 25,
          offset: Offset(0, 12),
        ),
      ],
    ),
child: Form(
  key: _formKey,
  child: Column(
      children: [

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),

          child: Text(
            isLogin
                ? "Assalamu Alaikum"
                : "Begin Your Journey",

            key: ValueKey(isLogin),

            style: const TextStyle(
              color: Color(0xFFF8E2A0),
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: .3,
            ),
          ),
        ),

        const SizedBox(height: 4),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),

          child: Text(
            isLogin
                ? "Login to continue your journey"
                : "Create an account and begin seeking knowledge.",

            key: ValueKey(isLogin),

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Color(0xFFB9C6C6),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Container(
          height: 56,

          decoration: BoxDecoration(
            color: const Color(0xFF123C3C),

            borderRadius:
                BorderRadius.circular(16),

            border: Border.all(
              color: const Color(0x33F4D17D),
            ),
          ),

          child: Stack(
            children: [

              AnimatedAlign(
                duration:
                    const Duration(milliseconds: 280),

                curve: Curves.easeInOut,

                alignment: isLogin
                    ? Alignment.centerLeft
                    : Alignment.centerRight,

                child: Container(
                  width:
                      (MediaQuery.of(context).size.width -
                              72) /
                          2,

                  margin:
                      const EdgeInsets.all(4),

                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [

                        Color(0xFFF7E2A5),

                        Color(0xFFE6C36A),

                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(14),

                    boxShadow: const [

                      BoxShadow(
                        color: Color(0x55F4D17D),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),

                    ],
                  ),
                ),
              ),

              Row(
                children: [

                  Expanded(
                    child: InkWell(

                      borderRadius:
                          BorderRadius.circular(16),

                      onTap: () {

                        setState(() {

                          isLogin = true;

                        });

                      },

                      child: Center(
                        child:
                            AnimatedDefaultTextStyle(

                          duration:
                              const Duration(
                                  milliseconds:
                                      250),

                          style: TextStyle(

                            color: isLogin
                                ? const Color(
                                    0xFF0B4B4B)
                                : Colors.white70,

                            fontSize: 16,

                            fontWeight:
                                FontWeight.bold,

                          ),

                          child:
                              const Text("Login"),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: InkWell(

                      borderRadius:
                          BorderRadius.circular(16),

                      onTap: () {

                        setState(() {

                          isLogin = false;

                        });

                      },

                      child: Center(
                        child:
                            AnimatedDefaultTextStyle(

                          duration:
                              const Duration(
                                  milliseconds:
                                      250),

                          style: TextStyle(

                            color: !isLogin
                                ? const Color(
                                    0xFF0B4B4B)
                                : Colors.white70,

                            fontSize: 16,

                            fontWeight:
                                FontWeight.bold,

                          ),

                          child: const Text(
                            "Register",
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),

            ],
          ),
        ),

        const SizedBox(height: 20),

  AnimatedSize(
  duration: const Duration(milliseconds: 300),

  child: isLogin
      ? const SizedBox()
      : buildField(
  controller: nameController,
  hint: "Full Name",
  icon: Icons.person_outline,
  validator: (value) {

  if (!isLogin) {

    if (value == null || value.trim().isEmpty) {
      return "Please enter your full name";
    }

    final name = value.trim();

    if (name.length < 3) {
      return "Name must be at least 3 characters";
    }

    if (name.length > 20) {
      return "Name is too long";
    }

    if (!RegExp(r"^[a-zA-Z\s.-]+$").hasMatch(name)) {
      return "Only letters are allowed";
    }

  }

  return null;
},
),
),
buildField(
  controller: emailController,
  hint: "Email Address",
  icon: Icons.email_outlined,
 validator: (value) {

  if (value == null || value.trim().isEmpty) {
    return "Please enter your email";
  }

  final email = value.trim().toLowerCase();

  final emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  if (!emailRegex.hasMatch(email)) {
    return "Please enter a valid email address";
  }

  if (email.length > 100) {
    return "Email is too long";
  }

  return null;
},
),
buildField(
  controller: passwordController,
  hint: "Password",
  icon: Icons.lock_outline,
  obscure: true,
  hideText: hidePassword,

  onToggleVisibility: () {
    setState(() {
      hidePassword = !hidePassword;
    });
  },
 validator: (value) {

  if (value == null || value.isEmpty) {
    return "Please enter your password";
  }

  if (value.length < 8) {
    return "Password must be at least 8 characters";
  }

  if (value.length > 64) {
    return "Password is too long";
  }

  if (value.contains(" ")) {
    return "Password cannot contain spaces";
  }

  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return "Include at least one uppercase letter";
  }


  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return "Include at least one number";
  }

  return null;
},
),
AnimatedSize(
  duration: const Duration(milliseconds: 300),

  child: isLogin
      ? const SizedBox():
      buildField(
  controller: confirmPasswordController,
  hint: "Confirm Password",
  icon: Icons.lock_outline,
  obscure: true,
  hideText: hideConfirmPassword,

  onToggleVisibility: () {
    setState(() {
      hideConfirmPassword =
          !hideConfirmPassword;
    });
  },

 validator: (value) {

  if (!isLogin) {

    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }

    if (value != passwordController.text) {
      return "Passwords do not match";
    }

  }

  return null;
},
),
),

Align(
  alignment: Alignment.centerRight,

  child: TextButton(
   onPressed: () {

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) =>
          const ForgotPasswordScreen(),

    ),

  );

},

    child: const Text(
      "Forgot Password?",

      style: TextStyle(
        color: Color(0xFFF4D17D),
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  height: 58,

  child: ElevatedButton(

   onPressed: isLoading
    ? null
    : () async {

        if (!_formKey.currentState!.validate()) {
          return;
        }

        setState(() {
          isLoading = true;
        });

        String? error;

        if (isLogin) {

          error = await _authService.login(
            email: emailController.text.trim().toLowerCase(),
            password: passwordController.text,
          );

        } else {

          error = await _authService.register(
            name: nameController.text.trim(),
            email: emailController.text.trim().toLowerCase(),
            password: passwordController.text,
          );

        }

      if (!mounted) return;

setState(() {
  isLoading = false;
});

        if (error != null) {

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
            ),
          );

        }
      },
child: isLoading
    ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      )
    : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            isLogin
                ? "Continue"
                : "Create Account",

            style: const TextStyle(
              color: Color.fromARGB(183, 21, 22, 21),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 10),

          const Icon(
            Icons.arrow_forward_rounded,
            color: Color(0xFF0B4B4B),
          ),

        ],
      ),
  ),
),
const SizedBox(height: 20),

Row(
  children: [

    Expanded(
      child: Divider(
        color: Colors.white24,
        thickness: 1,
      ),
    ),

    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        "OR",
        style: TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    Expanded(
      child: Divider(
        color: Colors.white24,
        thickness: 1,
      ),
    ),

  ],
),

const SizedBox(height: 22),

Row(
  mainAxisAlignment: MainAxisAlignment.center,

  children: [

    _socialButton(
      icon: Icons.g_mobiledata,
      label: "Google",
      onTap: () {},
    ),

    const SizedBox(width: 16),

    _socialButton(
      icon: Icons.person_outline,
      label: "Guest",
    onTap: () async {

    await GuestService().loginAsGuest();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
    );

  },
    ),
  ],
),

const SizedBox(height: 28),

Center(
  child: RichText(
    textAlign: TextAlign.center,
    text: const TextSpan(
      style: TextStyle(
        color: Colors.white60,
        fontSize: 13,
      ),
      children: [

        TextSpan(
          text: "By continuing you agree to our\n",
        ),

        TextSpan(
          text: "Terms of Service",
          style: TextStyle(
            color: Color(0xFFF4D17D),
            fontWeight: FontWeight.bold,
          ),
        ),

        TextSpan(text: " • "),

        TextSpan(
          text: "Privacy Policy",
          style: TextStyle(
            color: Color(0xFFF4D17D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 12),

const Text(
  "Seeker v1.0",
  style: TextStyle(
    color: Colors.white30,
    fontSize: 12,
  ),
),
                      

                    ],
                  ),
                ),
              ),
          )],
          ),
        ),
      ),
    );
  }
  }
  Widget buildField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool obscure = false,
bool? hideText,
VoidCallback? onToggleVisibility,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),

    child: TextFormField(
      controller: controller,
      obscureText: obscure ? hideText! : false,
      validator: validator,

      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(
          color: Color(0xFF9EB3B3),
        ),

        errorStyle: const TextStyle(
          color: Color(0xFFF4D17D),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),

        filled: true,
        fillColor: const Color(0xFF154646),

        prefixIcon: Icon(
          icon,
          color: const Color(0xFFF4D17D),
        ),

        suffixIcon: obscure
    ? IconButton(
        onPressed: onToggleVisibility,
        icon: Icon(
          hideText!
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: const Color(0xFF9EB3B3),
        ),
      )
    : null,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0x22F4D17D),
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFF4D17D),
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFF4D17D),
            width: 1.5,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFF4D17D),
            width: 2,
          ),
        ),
      ),
    ),
  );
}
Widget _socialButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),

    child: Container(
      width: 120,
      height: 56,

      decoration: BoxDecoration(
        color: const Color(0xFF154646),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x22F4D17D),
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: const Color(0xFFF4D17D),
          ),

          const SizedBox(width: 8),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

        ],
      ),
    ),
  );
}