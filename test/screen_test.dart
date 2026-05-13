import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pam_p7_2026_ifs23024/app.dart';
import 'package:pam_p7_2026_ifs23024/features/home/home_screen.dart';
import 'package:pam_p7_2026_ifs23024/features/plants/plants_screen.dart';
import 'package:pam_p7_2026_ifs23024/features/space/space_screen.dart';
import 'package:pam_p7_2026_ifs23024/features/profile/profile_screen.dart';

void main() {
  group('2.7.3 Pengujian Layar (Screens)', () {
    
    testWidgets('Pengujian Layar Beranda (HomeScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      // Memastikan layar Home aktif
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Memastikan elemen visual utama muncul
      expect(find.text('Plants + Space'), findsAtLeastNWidgets(1));
      expect(find.text('Jelajahi Keajaiban\nAlam & Semesta'), findsOneWidget);
      expect(find.text('Menu Utama'), findsOneWidget);
      expect(find.text('Tanaman'), findsOneWidget);
      expect(find.text('Antariksa'), findsOneWidget);
    });

    testWidgets('Pengujian Layar Tanaman (PlantsScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      // Navigasi ke menu Plants
      await tester.tap(find.text('Plants'));
      await tester.pumpAndSettle();

      // Memastikan layar Plants aktif
      expect(find.byType(PlantsScreen), findsOneWidget);
      
      // Memastikan tombol tambah tanaman (FloatingActionButton) tersedia
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Pengujian Layar Jelajah Antariksa (SpaceScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      // Navigasi ke menu Space
      await tester.tap(find.text('Space'));
      await tester.pumpAndSettle();

      // Memastikan layar Space aktif
      expect(find.byType(SpaceScreen), findsOneWidget);
      
      // Memastikan Filter Chip muncul (Setidaknya 'Semua')
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Planet'), findsOneWidget);
      
      // Memastikan Judul AppBar benar
      expect(find.text('Jelajah Antariksa'), findsOneWidget);
    });

    testWidgets('Pengujian Layar Profil (ProfileScreen)', (WidgetTester tester) async {
      await tester.pumpWidget(const DelcomPlantsApp());
      await tester.pumpAndSettle();

      // Navigasi ke menu Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Memastikan layar Profil aktif
      expect(find.byType(ProfileScreen), findsOneWidget);
      
      // Memastikan data profil utama muncul
      expect(find.text('Glen Rejeki Sitorus'), findsOneWidget);
      expect(find.text('@ifs23024'), findsOneWidget);
      expect(find.text('Tentang Saya'), findsOneWidget);
    });
  });
}
// flutter test test/integration_test.dart