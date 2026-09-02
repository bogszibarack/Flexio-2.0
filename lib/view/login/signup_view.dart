import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/round_textfield.dart';
import 'package:fitness/data/providers.dart';
import 'package:fitness/view/login/complete_profile_view.dart';
import 'package:fitness/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isCheck = false;
  bool isShowPassword = false;
  bool isBusy = false;
  String? errorText;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!isCheck) {
      setState(() {
        errorText = "Fogadd el az adatvédelmi tájékoztatót a folytatáshoz.";
      });
      return;
    }

    setState(() {
      isBusy = true;
      errorText = null;
    });

    final session = ref.read(sessionServiceProvider);
    final outcome = await session.signUp(
      email: emailController.text,
      password: passwordController.text,
      firstName: firstNameController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() => isBusy = false);

    if (!outcome.success) {
      setState(() => errorText = outcome.message);
      return;
    }

    if (outcome.message != null &&
        outcome.message!.contains("megerősítő e-mailt")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(outcome.message!)),
      );
      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginView(
            initialEmail: emailController.text.trim(),
          ),
        ),
      );
      return;
    }

    if (outcome.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(outcome.message!)),
      );
    }

    // A profiladatokat akkor is felvesszük, ha e-mail megerősítés kell: a
    // mentés a helyi adatbázisba megy, és a szinkron később feltölti.
    await ref.read(profileControllerProvider).update(
          firstName: firstNameController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompleteProfileView(
          firstName: firstNameController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
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
                    "Hozd létre a fiókod",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  RoundTextField(
                    controller: firstNameController,
                    hitText: "Keresztnév",
                    icon: "assets/img/user_text.png",
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value ?? "").trim().isEmpty ? "Add meg a keresztnevedet." : null,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    controller: lastNameController,
                    hitText: "Vezetéknév",
                    icon: "assets/img/user_text.png",
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    controller: emailController,
                    hitText: "Email",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    controller: passwordController,
                    hitText: "Jelszó",
                    icon: "assets/img/lock.png",
                    obscureText: !isShowPassword,
                    validator: (value) => (value ?? "").length < 6
                        ? "A jelszó legyen legalább 6 karakter."
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            isCheck = !isCheck;
                          });
                        },
                        icon: Icon(
                          isCheck
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: TColor.gray,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "A folytatással elfogadod az Adatvédelmi irányelveket és a Felhasználási feltételeket.",
                            softWrap: true,
                            style: TextStyle(color: TColor.gray, fontSize: 10),
                          ),
                        ),
                      )
                    ],
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        errorText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFFE53935), fontSize: 12),
                      ),
                    ),
                  if (errorText != null &&
                      errorText!.contains("már létezik fiók"))
                    TextButton(
                      onPressed: isBusy
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginView(
                                    initialEmail: emailController.text.trim(),
                                  ),
                                ),
                              );
                            },
                      child: Text(
                        "Bejelentkezés ezzel az e-mail címmel",
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: media.width * 0.3,
                  ),
                  RoundButton(
                      title: isBusy ? "Regisztráció..." : "Regisztráció",
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
                              builder: (context) => const LoginView()));
                    },
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Már van fiókod? ",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Bejelentkezés",
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

  static String? _validateEmail(String? value) {
    final email = (value ?? "").trim();
    if (email.isEmpty) {
      return "Add meg az e-mail címedet.";
    }
    if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) {
      return "Ez nem tűnik érvényes e-mail címnek.";
    }
    return null;
  }
}
