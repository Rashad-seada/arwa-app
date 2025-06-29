import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../domain/providers/eye_scan_provider.dart';
import '../../domain/models/eye_scan.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class EyeScanScreen extends ConsumerStatefulWidget {
  const EyeScanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EyeScanScreen> createState() => _EyeScanScreenState();
}

class _EyeScanScreenState extends ConsumerState<EyeScanScreen> {
  final _tabs = ['eye_scan.all_scans'.tr(), 'eye_scan.new_scan'.tr()];
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final eyeScanState = ref.watch(eyeScanProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('eye_scan.title'.tr()),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final title = entry.value;
                final isSelected = index == _currentTabIndex;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentTabIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Tab content
          Expanded(
            child: _currentTabIndex == 0
                ? _buildScansList(eyeScanState)
                : _buildNewScanForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildScansList(EyeScanState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('eye_scan.error_loading'.tr()),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () => ref.read(eyeScanProvider.notifier).loadEyeScans(),
              text: 'eye_scan.try_again'.tr(),
            ),
          ],
        ),
      );
    }
    
    if (state.scans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_red_eye_outlined,
              size: 64,
              color: AppColors.muted,
            ),
            const SizedBox(height: 16),
            Text(
              'eye_scan.no_scans'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'eye_scan.create_first_scan'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () => setState(() => _currentTabIndex = 1),
              text: 'eye_scan.add_scan'.tr(),
              icon: Icons.add,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.scans.length,
      itemBuilder: (context, index) {
        final scan = state.scans[index];
        return _buildScanItem(scan);
      },
    );
  }

  Widget _buildScanItem(EyeScan scan) {
    final formattedDate = DateFormat.yMMMd().format(scan.createdAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showScanDetails(scan),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  scan.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.muted.withOpacity(0.2),
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.muted.withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Scan info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (scan.description != null && scan.description!.isNotEmpty)
                    Text(
                      scan.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
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
    );
  }

  void _showScanDetails(EyeScan scan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  // Image
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      scan.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  // Scan details
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat.yMMMMd().format(scan.createdAt),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (scan.description != null && scan.description!.isNotEmpty) ...[
                          Text(
                            'eye_scan.description'.tr(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scan.description!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _confirmDeleteScan(scan);
                                },
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                label: Text('eye_scan.delete'.tr()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNewScanForm() {
    return const NewScanForm();
  }

  void _confirmDeleteScan(EyeScan scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('eye_scan.confirm_delete'.tr()),
        content: Text('eye_scan.delete_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('eye_scan.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(eyeScanProvider.notifier).deleteEyeScan(scan.id);
            },
            child: Text(
              'eye_scan.delete'.tr(),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class NewScanForm extends ConsumerStatefulWidget {
  const NewScanForm({Key? key}) : super(key: key);

  @override
  ConsumerState<NewScanForm> createState() => _NewScanFormState();
}

class _NewScanFormState extends ConsumerState<NewScanForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _imageFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.muted.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.muted.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'eye_scan.tap_to_select_image'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'eye_scan.title'.tr(),
                hintText: 'eye_scan.title_hint'.tr(),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'eye_scan.title_required'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'eye_scan.description'.tr(),
                hintText: 'eye_scan.description_hint'.tr(),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            
            // Submit button
            PrimaryButton(
              onPressed: _isSubmitting ? null : _submitForm,
              text: 'eye_scan.save'.tr(),
              isLoading: _isSubmitting,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text('eye_scan.take_photo'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    _processPickedImage(File(pickedFile.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('eye_scan.choose_from_gallery'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    _processPickedImage(File(pickedFile.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPickedImage(File image) async {
    // Save the image to the app's documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final savedImage = await image.copy('${appDir.path}/$fileName');
    
    setState(() {
      _imageFile = savedImage;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('eye_scan.image_required'.tr())),
        );
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        final scan = await ref.read(eyeScanProvider.notifier).createEyeScan(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          imagePath: _imageFile!.path,
        );
        
        if (scan != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('eye_scan.scan_saved'.tr())),
            );
            
            // Reset form
            _titleController.clear();
            _descriptionController.clear();
            setState(() {
              _imageFile = null;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('eye_scan.error_saving'.tr())),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
} 