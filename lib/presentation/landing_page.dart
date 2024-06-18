import 'package:elewa_test/repository/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _login = true;
  final _formKey = GlobalKey<FormState>();

  String emailPattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  void _toggleMode() {
    setState(() {
      _login = !_login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
            image:
                DecorationImage(image: AssetImage('assets/landing_page.jpeg'))),
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 480) {
            return Padding(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                child: mobileView(context));
          } else {
            return Padding(
              padding: const EdgeInsets.all(30.0),
              child: desktopView(context),
            );
          }
        }),
      ),
    );
  }

  Widget mobileView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          softWrap: true,
          "Real productivity begins here. Manage your teams and their tasks",
          style: TextStyle(
              fontSize: 26,
              overflow: TextOverflow.clip,
              fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Flexible(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(label: Text("Email")),
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text('Password')),
                ),
                const SizedBox(
                  height: 40,
                ),
                loginButton()
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget desktopView(BuildContext context) {
    final RegExp emailRegex = RegExp(emailPattern);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * .45,
            child: const Text(
              softWrap: true,
              "Real productivity begins here. Manage your teams and their tasks",
              style: TextStyle(
                  fontSize: 32,
                  overflow: TextOverflow.clip,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * .15,
          ),
          Flexible(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _login
                      ? const SizedBox()
                      : TextFormField(
                          controller: _fullNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter full name";
                            } else if (!value.contains(" ")) {
                              return "Please enter ypur second or last name";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              label: Text("FullName"),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter an Email';
                      } else if (!emailRegex.hasMatch(value)) {
                        return 'Enter a valid email';
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                        label: Text("Email"),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter a password';
                      } else if (value.length < 6) {
                        return 'Password must be 6 characters or more';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        label: Text("Password"),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  loginButton(),
                  const SizedBox(
                    height: 30,
                  ),
                  _login
                      ? RichText(
                          text: TextSpan(
                            children: <InlineSpan>[
                              const TextSpan(
                                text: "Have No Account? ",
                                style: TextStyle(color: Colors.cyan),
                              ),
                              TextSpan(
                                  text: "Sign Up",
                                  style: const TextStyle(color: Colors.purple),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _toggleMode())
                            ],
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            children: <InlineSpan>[
                              const TextSpan(
                                text: "Have An Account? ",
                                style: TextStyle(color: Colors.cyan),
                              ),
                              TextSpan(
                                  text: "Login",
                                  style: const TextStyle(color: Colors.purple),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _toggleMode())
                            ],
                          ),
                        )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ElevatedButton loginButton() {
    return ElevatedButton(
      style: const ButtonStyle(
        foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
        backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          if (_login) {
            await Provider.of<AuthService>(context, listen: false).signIn(
              _emailController.text,
              _passwordController.text,
            );
          } else {
            await Provider.of<AuthService>(context, listen: false).signUp(
              _emailController.text,
              _passwordController.text,
              _fullNameController.text,
            );
          }
        }
      },
      child: Text(_login ? 'Login' : 'Sign Up'),
    );
  }
}
