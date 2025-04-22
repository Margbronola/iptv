// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/data_cacher.dart';
import 'package:seizhiptv/globals/labeled_textfield.dart';
import 'package:seizhiptv/globals/loader.dart';
import 'package:seizhiptv/globals/logo.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/m3u/m3u_firebase_auth.dart';
import 'package:seizhiptv/models/m3u_user.dart';
import 'package:seizhiptv/services/google_sign_in.dart';
import 'package:seizhiptv/views/landing_page/source_management.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> kForm = GlobalKey<FormState>();
  late final TextEditingController _email, _password;
  final M3uFirebaseAuthService _auth = M3uFirebaseAuthService.instance;
  final DataCacher _cacher = DataCacher.instance;
  final GoogleSignInService _google = GoogleSignInService.instance;
  bool isLoading = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
                    child: LogoSVG(bottomText: "Register_with_us".tr()),
                  ),
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
                        const SizedBox(height: 10),
                        LabeledTextField(
                          isPassword: true,
                          controller: _password,
                          label: "Password".tr(),
                          hinttext: "Password".tr(),
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
                  const SizedBox(height: 40),
                  MaterialButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (kForm.currentState!.validate()) {
                        isLoading = true;
                        if (mounted) setState(() {});
                        await _auth
                            .register(_email.text, _password.text, "")
                            .then((u) async {
                              if (u != null) {
                                refId = u.user.uid;
                                user = M3uUser.fromProvider(u);
                                _cacher.saveRefID(refId!);
                                _cacher.saveM3uUser(user!);
                                _cacher.saveLoginType(0);

                                print("REFID : $refId");
                                print("USER : $user");
                                await Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                    child: const SourceManagementPage(),
                                    type: PageTransitionType.leftToRight,
                                  ),
                                );
                              }
                              isLoading = false;
                              if (mounted) setState(() {});
                            })
                            .onError((error, stackTrace) {
                              isLoading = false;
                              if (mounted) setState(() {});
                            });
                      }
                    },
                    color: ColorPalette().orange,
                    height: 55,
                    child: Center(child: Text("Register".tr().toUpperCase())),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: "Already_have_an_account".tr(),
                      children: [
                        TextSpan(
                          text: "Login".tr(),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pop();
                                },
                          style: TextStyle(
                            color: ColorPalette().orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: Colors.white.withOpacity(.3),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text("OR"),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: Colors.white.withOpacity(.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  MaterialButton(
                    onPressed: () async {
                      isLoading = true;
                      if (mounted) setState(() {});
                      await _google.signOut();
                      await _google
                          .signIn()
                          .then((u) async {
                            if (u == null) return;
                            refId = u.user.uid;
                            user = M3uUser.fromProvider(u);
                            _cacher.saveRefID(refId!);
                            _cacher.saveM3uUser(user!);
                            _cacher.saveLoginType(0);
                            print("USER : $user");
                            await Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: const SourceManagementPage(),
                                type: PageTransitionType.leftToRight,
                              ),
                            );
                          })
                          .whenComplete(() {
                            isLoading = false;
                            if (mounted) setState(() {});
                          });
                    },
                    height: 50,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/icons/2991148.png", height: 30),
                        const SizedBox(width: 10),
                        Text(
                          "Login_with_Google".tr(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
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
