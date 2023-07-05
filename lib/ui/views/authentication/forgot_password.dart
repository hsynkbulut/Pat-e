import 'package:flutter/material.dart';
import 'package:pat_e/common/constants/app_constant.dart';
import 'package:pat_e/common/constants/path_constant.dart';
import 'package:pat_e/core/utils/routing/route_constant.dart';
import 'package:pat_e/core/utils/themes/custom_textfield.dart';
import 'package:pat_e/core/utils/themes/color.dart';
import 'package:pat_e/core/viewmodels/authentication/forgotpassword_viewmodel.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgotPasswordPageViewModel>(
      create: (_) => ForgotPasswordPageViewModel(),
      child: const ForgotPasswordPageView(),
    );
  }
}

class ForgotPasswordPageView extends StatelessWidget {
  const ForgotPasswordPageView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final viewModel = Provider.of<ForgotPasswordPageViewModel>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColor1,
            gradientColor2,
            gradientColor3,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: transparentColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  PathConstant.authenticationLogoImage,
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: 20),
                Text(
                  AppConstant.appName.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'ErasBold',
                    fontSize: 60.0,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextfield(
                  controller: viewModel.emailController,
                  obscureText: false,
                  hintText: 'Email adresinizi girin',
                  icon: Icons.alternate_email,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    viewModel.resetPassword(context);
                  },
                  child: Container(
                    width: size.width,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: const Center(
                      child: Text(
                        'Şifre Sıfırla',
                        style: TextStyle(
                          color: mainAuxiliaryColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, RouteConstant.loginScreenRoute);
                    },
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Hesabınız var mı? ',
                            style: TextStyle(
                              color: mainAuxiliaryColor,
                            ),
                          ),
                          TextSpan(
                            text: 'Giriş Yap',
                            style: TextStyle(
                              color: bgColor,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
