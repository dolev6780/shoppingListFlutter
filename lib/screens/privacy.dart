import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppinglist/services/theme_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color themeColor = Provider.of<ThemeProvider>(context).themeColor;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Privacy Policy'), backgroundColor: themeColor),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your privacy is important to us. This privacy policy explains how we collect, use, and protect your personal information when you use our app.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Information We Collect:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '1. Personal Information: We may collect personal information such as your name, email address, and other details you provide when you register or use the app.\n\n'
                '2. Usage Data: We may collect information about how you use the app, such as the features you use, the time you spend on the app, and other related data.\n\n'
                '3. Device Information: We may collect information about the device you use to access the app, including the device\'s IP address, operating system, and browser type.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'How We Use Your Information:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We use the information we collect to improve the app, provide customer support, communicate with you, and protect the security of our users.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sharing Your Information:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We do not share your personal information with third parties except as required by law or to protect the rights and safety of our users.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Changes to This Privacy Policy:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contact Us:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'If you have any questions about this privacy policy, please contact us at support@example.com.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
