import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../data/models/space_object_model.dart';
import '../../providers/space_object_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class SpaceDetailScreen extends StatefulWidget {
  const SpaceDetailScreen({super.key, required this.objectId});
  final String objectId;

  @override
  State<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends State<SpaceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpaceObjectProvider>().loadSpaceObjectById(widget.objectId);
    });
  }

  Future<void> _confirmDelete(BuildContext context, SpaceObjectProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Objek'),
        content: const Text('Yakin ingin menghapus objek ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final ok = await provider.removeSpaceObject(widget.objectId);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Objek berhasil dihapus.')),
        );
        context.go(RouteConstants.space);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpaceObjectProvider>(
      builder: (context, provider, _) {
        if (provider.status == SpaceStatus.loading || provider.status == SpaceStatus.initial) {
          return Scaffold(
            appBar: const TopAppBarWidget(title: 'Detail Objek', showBackButton: true),
            body: const LoadingWidget(),
          );
        }
        if (provider.status == SpaceStatus.error) {
          return Scaffold(
            appBar: const TopAppBarWidget(title: 'Detail Objek', showBackButton: true),
            body: AppErrorWidget(
              message: provider.errorMessage,
              onRetry: () => provider.loadSpaceObjectById(widget.objectId),
            ),
          );
        }
        final obj = provider.selected;
        if (obj == null) {
          return Scaffold(
            appBar: const TopAppBarWidget(title: 'Detail Objek', showBackButton: true),
            body: const Center(child: Text('Data tidak ditemukan.')),
          );
        }
        return Scaffold(
          appBar: TopAppBarWidget(
            title: obj.nama,
            showBackButton: true,
            menuItems: [
              TopAppBarMenuItem(
                text: 'Edit', icon: Icons.edit_outlined,
                onTap: () async {
                  final edited = await context.push<bool>(RouteConstants.spaceEdit(obj.id!));
                  if (edited == true && context.mounted) {
                    provider.loadSpaceObjectById(widget.objectId);
                  }
                },
              ),
              TopAppBarMenuItem(
                text: 'Hapus', icon: Icons.delete_outline, isDestructive: true,
                onTap: () => _confirmDelete(context, provider),
              ),
            ],
          ),
          body: _SpaceDetailBody(obj: obj),
        );
      },
    );
  }
}

class _SpaceDetailBody extends StatelessWidget {
  const _SpaceDetailBody({required this.obj});
  final SpaceObjectModel obj;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: obj.gambar.isNotEmpty
                ? Image.network(
              obj.gambar,
              width: double.infinity, height: 250, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imgPlaceholder(colorScheme),
            )
                : _imgPlaceholder(colorScheme),
          ),
          const SizedBox(height: 12),

          // Nama + Badge tipe
          Text(
            obj.nama,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              obj.tipe.toUpperCase(),
              style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Info cards
          _InfoCard(title: '📍 Jarak dari Bumi', content: obj.jarakDariBumi),
          const SizedBox(height: 12),
          _InfoCard(title: '📖 Deskripsi', content: obj.deskripsi),
          const SizedBox(height: 12),
          _InfoCard(title: '💡 Fakta Menarik', content: obj.fakta),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _imgPlaceholder(ColorScheme cs) {
    return Container(
      height: 250, color: cs.primaryContainer,
      child: const Center(child: Text('🔭', style: TextStyle(fontSize: 80))),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Divider(height: 16),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}