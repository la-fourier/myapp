import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/app_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'test@debug.com');
  final _passwordController = TextEditingController(text: 'debug123');
  bool obscurePassword = true;
  bool showInfoDialog = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid credentials. Use test@debug.com / debug123 for testing.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      // The AuthWrapper will handle navigation automatically upon state change.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signup');
                        },
                        child: const Text('Sign Up'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline_rounded),
                        tooltip: 'Info',
                        onPressed: () {
                          setState(() {
                            showInfoDialog = true;
                          });
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Test Account Info'),
                                content: const Text(
                                  'Use test@debug.com / debug123 for testing.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        showInfoDialog = false;
                                      });
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
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
