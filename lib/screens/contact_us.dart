import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/services/theme_provider.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text("צור קשר"),
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "נשמח לשמוע ממך.י",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: 'שם מלא',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person, color: themeColor),
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: themeColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          floatingLabelStyle:
                              const TextStyle(color: Colors.white)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: 'אימייל',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: themeColor),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: themeColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          floatingLabelStyle:
                              const TextStyle(color: Colors.white)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                          labelText: 'הקלד.י',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.message,
                            color: themeColor,
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: themeColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          floatingLabelStyle:
                              const TextStyle(color: Colors.white)),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 1,
                              color: Color.fromARGB(255, 125, 125, 125),
                              offset: Offset(0, 1),
                            )
                          ],
                        ),
                        width: 100,
                        child: TextButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Handle form submission
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Message sent successfully!'),
                                ),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'שלח',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
