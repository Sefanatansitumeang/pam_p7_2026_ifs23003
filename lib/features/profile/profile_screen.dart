// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/top_app_bar_widget.dart';
import '../../providers/plant_provider.dart';
import '../../providers/space_object_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Memastikan data terbaru dimuat saat membuka profil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantProvider>().loadPlants();
      context.read<SpaceObjectProvider>().loadSpaceObjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopAppBarWidget(title: 'Profil Pengguna'),
      body: _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Mengambil data dari provider
    final plantCount = context.watch<PlantProvider>().plants.length;
    final spaceCount = context.watch<SpaceObjectProvider>().objects.length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Profile dengan Background Decor
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
              ),
              Positioned(
                top: 80,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: const AssetImage('assets/images/profile.png'),
                    onBackgroundImageError: (_, __) {},
                    child: const Icon(Icons.person, size: 60, color: Colors.transparent),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 70),

          // Nama & Username
          Text(
            'Glen Rejeki Sitorus',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '@ifs23024',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
          ),

          const SizedBox(height: 24),

          // Stats atau Info Ringkas (Data Real dari Provider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Tanaman', plantCount.toString(), Icons.eco_rounded, Colors.green),
                _buildStatItem('Space', spaceCount.toString(), Icons.rocket_launch_rounded, Colors.indigo),
                _buildStatItem('Level', _calculateLevel(plantCount + spaceCount), Icons.auto_awesome_rounded, Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Bagian Detail / Bio
          _buildProfileSection(
            context,
            title: 'Tentang Saya',
            content: 'Seorang developer yang antusias menjelajahi keindahan alam (Plants) dan misteri alam semesta (Space). Fokus pada pengembangan aplikasi Flutter yang interaktif.',
            icon: Icons.info_outline_rounded,
          ),

          _buildProfileSection(
            context,
            title: 'Kontak',
            content: 'Email: glen.sitorus@student.del.ac.id\nLokasi: Institut Teknologi Del',
            icon: Icons.alternate_email_rounded,
          ),

          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Profil'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _calculateLevel(int total) {
    if (total >= 20) return 'Master';
    if (total >= 10) return 'Explorer';
    if (total >= 5)  return 'Novice';
    return 'Beginner';
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context, {required String title, required String content, required IconData icon}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }
}
