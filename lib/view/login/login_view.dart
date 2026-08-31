import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/round_textfield.dart';
import 'package:fitness/data/providers.dart';
import 'package:fitness/view/on_boarding/on_boarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isShowPassword = false;
  bool isBusy = false;
  String? errorText;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      isBusy = true;
      errorText = null;
    });

    final session = ref.read(sessionServiceProvider);
    final userScope = ref.read(userScopeProvider);
    final outcome = await session.signIn(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!outcome.success) {
      setState(() {
        isBusy = false;
        errorText = outcome.message;
      });
      return;
    }

    // A session-csere lecseréli ezt a képernyőt, ezért a providereket
    // előre kiolvassuk, és a profil új példánya magától betölt.
    await session.completeOnboarding();
    if (!mounted) {
      final userId = session.userId;
      if (userId != null) {
        userScope.attachAndSync(userId);
      }
      return;
    }
    final userId = session.userId;
    if (userId != null) {
      userScope.attachAndSync(userId);
    }
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errorText = "Írd be az e-mail címedet, és újraküldjük a jelszót.";
      });
      return;
    }

    final outcome =
        await ref.read(sessionServiceProvider).sendPasswordReset(email);
    if (!mounted) {
      return;
    }

    if (outcome.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(outcome.message ?? "Levél elküldve.")),
      );
    } else {
      setState(() => errorText = outcome.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Üdvözlünk!",
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  Text(
                    "Jó újra látni!",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: media.width * 0.09,
                  ),
                  RoundTextField(
                    controller: emailController,
                    hitText: "Email",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value ?? "").trim().isEmpty
                        ? "Add meg az e-mail címedet."
                        : null,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    controller: passwordController,
                    hitText: "Jelszó",
                    icon: "assets/img/lock.png",
                    obscureText: !isShowPassword,
                    validator: (value) => (value ?? "").isEmpty
                        ? "Add meg a jelszavadat."
                        : null,
                    rigtIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            isShowPassword = !isShowPassword;
                          });
                        },
                        child: Container(
                            alignment: Alignment.center,
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              "assets/img/show_password.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              color: isShowPassword
                                  ? TColor.primaryColor1
                                  : TColor.gray,
                            ))),
                  ),
                  TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      "Elfelejtetted a jelszavad?",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 11,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFFE53935), fontSize: 12),
                      ),
                    ),
                  const Spacer(),
                  RoundButton(
                      title: isBusy ? "Bejelentkezés..." : "Bejelentkezés",
                      onPressed: isBusy ? () {} : _submit),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: 1,
                        color: TColor.gray.withValues(alpha: 0.5),
                      )),
                      Text(
                        "  Vagy  ",
                        style: TextStyle(color: TColor.black, fontSize: 12),
                      ),
                      Expanded(
                          child: Container(
                        height: 1,
                        color: TColor.gray.withValues(alpha: 0.5),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnBoardingView(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Nincs még fiókod? ",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Regisztráció",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
