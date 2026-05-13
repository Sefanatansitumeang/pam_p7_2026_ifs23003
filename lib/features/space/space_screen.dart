import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../data/models/space_object_model.dart';
import '../../providers/space_object_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class SpaceScreen extends StatefulWidget {
  const SpaceScreen({super.key});

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  static const _tipeList = ['', 'planet', 'bintang', 'galaksi', 'nebula', 'satelit', 'asteroid'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpaceObjectProvider>().loadSpaceObjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SpaceObjectProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B0D17), // Dark space background
          appBar: TopAppBarWidget(
            title: 'Jelajah Antariksa',
            withSearch: true,
            searchQuery: provider.searchQuery,
            onSearchQueryChange: provider.updateSearchQuery,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  Colors.indigo.withOpacity(0.2),
                  const Color(0xFF0B0D17),
                ],
              ),
            ),
            child: Column(
              children: [
                // Filter chips with custom styling
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tipeList.length,
                    itemBuilder: (context, index) {
                      final t = _tipeList[index];
                      final label = t.isEmpty ? 'Semua' : _capitalize(t);
                      final isSelected = provider.filterTipe == t;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) => provider.updateFilterTipe(t),
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? colorScheme.primary : Colors.white10,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(child: _buildBody(provider)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            onPressed: () async {
              final added = await context.push<bool>(RouteConstants.spaceAdd);
              if (added == true && context.mounted) {
                provider.loadSpaceObjects();
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_rounded, size: 30),
          ),
        );
      },
    );
  }

  Widget _buildBody(SpaceObjectProvider provider) {
    return switch (provider.status) {
      SpaceStatus.loading || SpaceStatus.initial => const LoadingWidget(),
      SpaceStatus.error => AppErrorWidget(
        message: provider.errorMessage,
        onRetry: provider.loadSpaceObjects,
      ),
      SpaceStatus.success => provider.objects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  const Text('Kosong seperti ruang hampa...', 
                    style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            )
          : RefreshIndicator(
        onRefresh: provider.loadSpaceObjects,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: provider.objects.length,
          itemBuilder: (context, i) => _SpaceCard(
            obj: provider.objects[i],
            onTap: () => context.go(RouteConstants.spaceDetail(provider.objects[i].id!)),
          ),
        ),
      ),
    };
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({required this.obj, required this.onTap});

  final SpaceObjectModel obj;
  final VoidCallback onTap;

  static const _tipeIcon = {
    'planet':   '🪐',
    'bintang':  '⭐',
    'galaksi':  '🌌',
    'nebula':   '🌠',
    'satelit':  '🛰️',
    'asteroid': '☄️',
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = _tipeIcon[obj.tipe.toLowerCase()] ?? '🔭';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image or Icon Container
                Container(
                  width: 85, height: 85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: obj.gambar.isNotEmpty
                        ? Image.network(
                      obj.gambar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(icon),
                    )
                        : _placeholder(icon),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              obj.nama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          _TypeBadge(type: obj.tipe),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        obj.deskripsi,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 14, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Ketuk untuk detail',
                            style: TextStyle(
                              color: colorScheme.primary.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(String icon) {
    return Container(
      color: Colors.white.withOpacity(0.05),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 36))),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade400.withOpacity(0.3),
            Colors.purple.shade400.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
