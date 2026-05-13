import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p7_2026_ifs23024/app.dart';
import 'package:pam_p7_2026_ifs23024/features/home/home_screen.dart';
import 'package:pam_p7_2026_ifs23024/features/plants/plants_screen.dart';
import 'package:pam_p7_2026_ifs23024/features/profile/profile_screen.dart';
import 'package:pam_p7_2026_ifs23024/features/space/space_screen.dart';

void main() {
  group('2.7.4 Pengujian Integrasi (Integration)', () {
    
    testWidgets('Alur Navigasi Lengkap: Beranda -> Tanaman -> Antariksa -> Profil', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Plants'));
      await tester.pumpAndSettle();
      expect(find.byType(PlantsScreen), findsOneWidget);

      await tester.tap(find.text('Space'));
      await tester.pumpAndSettle();
      expect(find.byType(SpaceScreen), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      
      expect(find.text('Glen Rejeki Sitorus'), findsOneWidget);
      expect(find.text('@ifs23024'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Integrasi Data: Memastikan Statistik Muncul di Profil setelah Navigasi', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Gunakan find.descendant untuk memastikan kita mencari icon di dalam ProfileScreen,
      // bukan di Bottom Navigation Bar.
      final profileScreen = find.byType(ProfileScreen);
      
      expect(
        find.descendant(of: profileScreen, matching: find.byIcon(Icons.eco_rounded)), 
        findsOneWidget
      );
      
      expect(
        find.descendant(of: profileScreen, matching: find.byIcon(Icons.rocket_launch_rounded)), 
        findsOneWidget
      );

      expect(find.text('Tentang Saya'), findsOneWidget);
    });
  });
}
// flutter test test/integration_test.dart