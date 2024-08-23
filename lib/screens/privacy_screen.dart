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
          title: const Text('מדיניות פרטיות'),
          backgroundColor: themeColor,
          centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'מדיניות פרטיות',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'הפרטיות שלך חשובה לנו. מדיניות פרטיות זו מסבירה כיצד אנו אוספים, משתמשים ומגנים על המידע האישי שלך כאשר אתה משתמש באפליקציה שלנו.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'מידע שאנו אוספים:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '1. מידע אישי: אנו עשויים לאסוף מידע אישי כגון שם, כתובת אימייל ופרטים נוספים שתספק בעת הרשמה או שימוש באפליקציה.\n\n'
                  '2. נתוני שימוש: אנו עשויים לאסוף מידע על אופן השימוש שלך באפליקציה, כגון הפונקציות שאתה משתמש בהן, הזמן שאתה מבלה באפליקציה ומידע קשור נוסף.\n\n'
                  '3. מידע על המכשיר: אנו עשויים לאסוף מידע על המכשיר שבו אתה משתמש לגישה לאפליקציה, כולל כתובת ה-IP של המכשיר, מערכת ההפעלה וסוג הדפדפן.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'כיצד אנו משתמשים במידע שלך:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'אנו משתמשים במידע שאנו אוספים לשיפור האפליקציה, לספק תמיכה ללקוחות, לתקשר איתך ולהגן על ביטחון המשתמשים שלנו.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'שיתוף המידע שלך:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'איננו משתפים את המידע האישי שלך עם צדדים שלישיים אלא אם כן נדרש על פי חוק או כדי להגן על זכויות וביטחון המשתמשים שלנו.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'שינויים במדיניות פרטיות זו:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'אנו עשויים לעדכן מדיניות פרטיות זו מעת לעת. נודיע לך על כל שינוי על ידי פרסום מדיניות הפרטיות החדשה בעמוד זה.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'צור קשר:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'אם יש לך שאלות לגבי מדיניות פרטיות זו, אנא צור קשר בכתובת support@example.com.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('קבל'),
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
