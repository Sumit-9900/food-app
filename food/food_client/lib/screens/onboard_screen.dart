import 'package:flutter/material.dart';
import 'package:food_client/model/onboard_model.dart';
import 'package:food_client/provider/user_provider.dart';
import 'package:food_client/screens/signup_screen.dart';
import 'package:food_client/utils/textstyle.dart';
import 'package:food_client/widgets/build_dot.dart';
import 'package:provider/provider.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final PageController controller = PageController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller,
              itemCount: contents.length,
              onPageChanged: userProvider.pageIndex,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 1.8,
                        child: Image.asset(contents[index].image),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        contents[index].title,
                        style: Style.text,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        contents[index].description,
                        style: Style.text2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      BuildDot(currentPage: userProvider.currentPage),
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          if (userProvider.currentPage == contents.length - 1) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          }
                          controller.nextPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Text(
                              userProvider.currentPage == contents.length - 1
                                  ? 'Start'
                                  : 'Next',
                              style: Style.text3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
