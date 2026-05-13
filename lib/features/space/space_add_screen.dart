import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/space_object_provider.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class SpaceAddScreen extends StatefulWidget {
  const SpaceAddScreen({super.key});

  @override
  State<SpaceAddScreen> createState() => _SpaceAddScreenState();
}

class _SpaceAddScreenState extends State<SpaceAddScreen> {
  final _formKey           = GlobalKey<FormState>();
  final _namaController    = TextEditingController();
  final _deskripsiController   = TextEditingController();
  final _jarakController   = TextEditingController();
  final _faktaController   = TextEditingController();

  String _tipe = 'planet';
  File?     _imageFile;
  Uint8List? _imageBytes;
  String    _imageFilename = 'image.jpg';
  bool _isLoading = false;

  static const _tipeOptions = ['planet','bintang','galaksi','nebula','satelit','asteroid'];

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _jarakController.dispose();
    _faktaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes   = bytes;
      _imageFilename = picked.name;
      _imageFile    = kIsWeb ? null : File(picked.path);
    });
  }

  void _showImageSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
            ),
            if (!kIsWeb) ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Kamera'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final ok = await context.read<SpaceObjectProvider>().addSpaceObject(
      nama: _namaController.text.trim(),
      tipe: _tipe,
      deskripsi: _deskripsiController.text.trim(),
      jarakDariBumi: _jarakController.text.trim(),
      fakta: _faktaController.text.trim(),
      imageFile: _imageFile,
      imageBytes: _imageBytes,
      imageFilename: _imageFilename,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objek berhasil ditambahkan.')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<SpaceObjectProvider>().errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const TopAppBarWidget(title: 'Tambah Objek Luar Angkasa', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gambar
              GestureDetector(
                onTap: _showImageSheet,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outline),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 48, color: cs.primary),
                      const SizedBox(height: 8),
                      Text('Ketuk untuk pilih gambar *', style: TextStyle(color: cs.primary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tipe dropdown
              DropdownButtonFormField<String>(
                value: _tipe,
                decoration: const InputDecoration(
                  labelText: 'Tipe Objek',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _tipeOptions.map((t) => DropdownMenuItem(value: t, child: Text(_capitalize(t)))).toList(),
                onChanged: (v) => setState(() => _tipe = v!),
              ),
              const SizedBox(height: 16),

              _buildField(controller: _namaController, label: 'Nama', icon: Icons.public),
              const SizedBox(height: 16),
              _buildField(controller: _deskripsiController, label: 'Deskripsi', icon: Icons.description_outlined, maxLines: 3),
              const SizedBox(height: 16),
              _buildField(controller: _jarakController, label: 'Jarak dari Bumi', icon: Icons.straighten_outlined, hint: 'Contoh: 384.400 km'),
              const SizedBox(height: 16),
              _buildField(controller: _faktaController, label: 'Fakta Menarik', icon: Icons.lightbulb_outline, maxLines: 3),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? '$label tidak boleh kosong.' : null,
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}