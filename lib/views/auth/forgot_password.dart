import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhiptv/globals/labeled_textfield.dart';
import 'package:seizhiptv/globals/loader.dart';
import 'package:seizhiptv/globals/logo.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/m3u/m3u_firebase_auth.dart';
import 'package:seizhiptv/views/auth/login.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> kForm = GlobalKey<FormState>();
  final M3uFirebaseAuthService auth = M3uFirebaseAuthService.instance;

  late final TextEditingController _email;
  bool isLoading = false;

  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey.shade800,
            body: Container(
              decoration: BoxDecoration(gradient: ColorPalette().gradient),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: "auth-logo",
                    child: LogoSVG(bottomText: "Forget_Password".tr()),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: kForm,
                    child: Column(
                      children: [
                        LabeledTextField(
                          controller: _email,
                          label: "Email".tr(),
                          hinttext: "Email".tr(),
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                  MaterialButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (kForm.currentState!.validate()) {
                        isLoading = true;
                        if (mounted) setState(() {});
                        await auth
                            .forgotPassword(_email.text)
                            .then((value) {
                              Fluttertoast.showToast(
                                msg: "Password reset link sent to your email",
                              );
                            })
                            .whenComplete(() {
                              setState(() {
                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                    child: LoginPage(),
                                    type: PageTransitionType.rightToLeft,
                                  ),
                                );
                              });
                            })
                            .onError((error, stackTrace) {
                              isLoading = false;
                              if (mounted) setState(() {});
                            });
                      }
                    },
                    color: ColorPalette().orange,
                    height: 55,
                    child: Center(
                      child: Text(
                        "Reset".tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    height: 50,
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        "Cancel".tr(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) ...{
            const Positioned.fill(child: SeizhTvLoader(opacity: .7)),
          },
        ],
      ),
    );
  }
}
