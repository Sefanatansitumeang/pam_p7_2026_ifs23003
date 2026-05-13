import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/space_object_model.dart';
import '../../providers/space_object_provider.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class SpaceEditScreen extends StatefulWidget {
  const SpaceEditScreen({super.key, required this.objectId});
  final String objectId;

  @override
  State<SpaceEditScreen> createState() => _SpaceEditScreenState();
}

class _SpaceEditScreenState extends State<SpaceEditScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _namaController      = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jarakController     = TextEditingController();
  final _faktaController     = TextEditingController();

  String _tipe = 'planet';
  File?      _newImageFile;
  Uint8List? _newImageBytes;
  String     _newImageFilename = 'image.jpg';
  bool _isLoading      = false;
  bool _isInitialized  = false;

  static const _tipeOptions = ['planet','bintang','galaksi','nebula','satelit','asteroid'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        context.read<SpaceObjectProvider>().loadSpaceObjectById(widget.objectId);
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _jarakController.dispose();
    _faktaController.dispose();
    super.dispose();
  }

  void _populate(SpaceObjectModel obj) {
    if (_isInitialized) return;
    _namaController.text      = obj.nama;
    _deskripsiController.text = obj.deskripsi;
    _jarakController.text     = obj.jarakDariBumi;
    _faktaController.text     = obj.fakta;
    _tipe                     = obj.tipe;
    _isInitialized            = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _newImageBytes    = bytes;
      _newImageFilename = picked.name;
      _newImageFile     = kIsWeb ? null : File(picked.path);
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

  Future<void> _submit(SpaceObjectModel original) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final ok = await context.read<SpaceObjectProvider>().editSpaceObject(
      id: original.id!,
      nama: _namaController.text.trim(),
      tipe: _tipe,
      deskripsi: _deskripsiController.text.trim(),
      jarakDariBumi: _jarakController.text.trim(),
      fakta: _faktaController.text.trim(),
      imageFile: _newImageFile,
      imageBytes: _newImageBytes,
      imageFilename: _newImageFilename,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objek berhasil diperbarui.')),
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

    return Consumer<SpaceObjectProvider>(
      builder: (context, provider, _) {
        final obj = provider.selected;
        if (obj != null) _populate(obj);

        return Scaffold(
          appBar: const TopAppBarWidget(title: 'Edit Objek Luar Angkasa', showBackButton: true),
          body: obj == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _newImageBytes != null
                                ? Image.memory(_newImageBytes!, fit: BoxFit.cover)
                                : Image.network(
                              obj.gambar, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text('🔭', style: TextStyle(fontSize: 60, color: cs.primary)),
                              ),
                            ),
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(
                                color: Colors.black45,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: const Text(
                                  'Ketuk untuk ganti gambar (opsional)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tipe
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
                  _buildField(controller: _jarakController, label: 'Jarak dari Bumi', icon: Icons.straighten_outlined),
                  const SizedBox(height: 16),
                  _buildField(controller: _faktaController, label: 'Fakta Menarik', icon: Icons.lightbulb_outline, maxLines: 3),
                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _isLoading ? null : () => _submit(obj),
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
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? '$label tidak boleh kosong.' : null,
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}