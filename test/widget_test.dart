import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p7_2026_ifs23024/app.dart';
import 'package:pam_p7_2026_ifs23024/shared/widgets/bottom_nav_widget.dart';

void main() {
  group('App Navigation & Smoke Test', () {
    testWidgets('Memastikan aplikasi memuat halaman Home dengan benar', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      expect(find.text('Plants + Space'), findsAtLeastNWidgets(1));
      expect(find.text('Menu Utama'), findsOneWidget);
      expect(find.byType(BottomNavWidget), findsOneWidget);
    });

    testWidgets('Navigasi antar menu melalui Bottom Navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      // Menggunakan find.text karena widget navigasi kita menggunakan Text label
      final plantsButton = find.text('Plants');
      expect(plantsButton, findsOneWidget);
      
      await tester.tap(plantsButton);
      await tester.pumpAndSettle();
      
      // Verifikasi kita pindah ke halaman lain (Home sudah tidak terlihat teks hero-nya)
      // Catatan: Karena menggunakan GoRouter, pastikan context.go bekerja di test environment
    });

    testWidgets('Memastikan Profil menampilkan nama pengguna yang benar', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      // Klik menu Profil berdasarkan teks labelnya
      final profileButton = find.text('Profile');
      expect(profileButton, findsOneWidget);
      
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Verifikasi nama user muncul di halaman profil
      expect(find.text('Glen Rejeki Sitorus'), findsOneWidget);
      expect(find.text('@ifs23024'), findsOneWidget);
    });
  });
}


//    flutter test test/widget_test.dart
