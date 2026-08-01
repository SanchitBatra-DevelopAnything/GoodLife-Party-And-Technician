import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../providers/auth_provider.dart';
import '../providers/categories_provider.dart';
import '../models/categories_model.dart';
import '../providers/service_request_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/voice_recorder_widget.dart';
import '../widgets/whatsapp_more_info_note.dart';

class ServiceRequestFormScreen extends StatefulWidget {
  const ServiceRequestFormScreen({super.key});

  @override
  State<ServiceRequestFormScreen> createState() =>
      _ServiceRequestFormScreenState();
}

class _ServiceRequestFormScreenState extends State<ServiceRequestFormScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  String selectedType = 'SERVICE'; // 'SERVICE' or 'INSTALLATION'
  final List<File> selectedImages = [];
  // Pre-upload: maps each picked File to its in-progress upload Future
  final Map<File, Future<String>> _uploadFutures = {};
  File? selectedAudio;

  // Multi-machine selection
  final List<CategoryModel> selectedMachines = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      context
          .read<CategoryProvider>()
          .fetchCategories(machineIds: authProvider.machineIds);
    });
  }

  Future<void> pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    if (selectedImages.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.maxPhotos6Allowed)),
      );
      return;
    }

    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image != null) {
      final file = File(image.path);
      setState(() {
        selectedImages.add(file);
      });
      // Start uploading immediately in the background
      _uploadFutures[file] = context
          .read<ServiceRequestProvider>()
          .uploadImageEarly(file);
    }
  }

  Future<void> submitRequest() async {
    final l10n = AppLocalizations.of(context)!;
    if (selectedMachines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectOneMachine)),
      );
      return;
    }

    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseDescribeDetails)),
      );
      return;
    }

    try {
      await context.read<ServiceRequestProvider>().submitServiceRequest(
            machineIds: selectedMachines.map((m) => m.id).toList(),
            machineNames: selectedMachines.map((m) => m.name).toList(),
            images: selectedImages,
            preUploadedFutures: _uploadFutures,
            audio: selectedAudio,
            type: selectedType,
            description: description,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.serviceRequestSuccess)),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.inventory,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.submissionFailed(e.toString()))),
      );
    }
  }

  Widget buildTypeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: buildTypeButton(
                'SERVICE', l10n.serviceComplaintTab, Icons.warning_amber_rounded),
          ),
          Expanded(
            child: buildTypeButton(
                'INSTALLATION', l10n.installationTab, Icons.build_circle_outlined),
          ),
        ],
      ),
    );
  }

  Widget buildTypeButton(String key, String label, IconData icon) {
    final isSelected = selectedType == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = key;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Multi-select machine list with checkboxes
  Widget buildMachineSelector(List<CategoryModel> machines) {
    final l10n = AppLocalizations.of(context)!;
    if (machines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(l10n.noMachinesAssigned),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: machines.asMap().entries.map((entry) {
          final index = entry.key;
          final machine = entry.value;
          final isSelected = selectedMachines.contains(machine);
          final isLast = index == machines.length - 1;

          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.only(
                  topLeft: index == 0
                      ? const Radius.circular(16)
                      : Radius.zero,
                  topRight: index == 0
                      ? const Radius.circular(16)
                      : Radius.zero,
                  bottomLeft: isLast
                      ? const Radius.circular(16)
                      : Radius.zero,
                  bottomRight: isLast
                      ? const Radius.circular(16)
                      : Radius.zero,
                ),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedMachines.remove(machine);
                    } else {
                      selectedMachines.add(machine);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          machine.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 52,
                  color: Colors.grey.shade200,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildImageSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.photosCount(selectedImages.length).replaceAll('/4', '/6'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (selectedImages.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedImages.clear();
                  });
                },
                child: Text(l10n.clearAll),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: selectedImages.length < 6 ? selectedImages.length + 1 : 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            if (index < selectedImages.length) {
              final imageFile = selectedImages[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImages.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: pickImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addPhoto,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildMediaSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.voiceNote,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        VoiceRecorderWidget(
          onAudioRecorded: (file) {
            setState(() {
              selectedAudio = file;
            });
          },
        ),
      ],
    );
  }

  Widget buildPickCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSelectedMediaCard({
    required IconData icon,
    required String title,
    required String fileName,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Icon(icon, size: 32, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceRequestProvider>();
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.build_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.serviceRequest,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.requestInstallationSubtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Machine Selection ---
                Row(
                  children: [
                    Text(
                      l10n.selectMachines,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    if (selectedMachines.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.selectedCount(selectedMachines.length),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.selectMachinesInstruction,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    if (categoryProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return buildMachineSelector(categoryProvider.categories);
                  },
                ),
                const SizedBox(height: 24),

                // --- Request Type ---
                Text(
                  l10n.selectRequestType,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                buildTypeSelector(),
                const SizedBox(height: 24),

                // --- Photos ---
                buildImageSection(),
                const SizedBox(height: 24),

                // --- Audio ---
                buildMediaSection(),
                const SizedBox(height: 24),

                // --- Description ---
                Text(
                  l10n.description,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: descriptionController,
                      maxLength: 1000,
                      minLines: 4,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: l10n.provideMoreDetailsHint,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const WhatsAppMoreInfoNote(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavBar(
            currentIndex: 3,
            showCartBar: false,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.isSubmitting ? null : submitRequest,
            label: Row(
              children: [
                const Icon(Icons.send_rounded),
                const SizedBox(width: 8),
                Text(l10n.submitRequest,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        if (provider.isSubmitting)
          ServiceRequestLoader(
            message: provider.progressMessage,
          ),
      ],
    ),
    );
  }
}

class ServiceRequestLoader extends StatelessWidget {
  final String message;

  const ServiceRequestLoader({
    super.key,
    required this.message,
  });

  String _getLocalizedMessage(BuildContext context, String msg) {
    final l10n = AppLocalizations.of(context)!;
    if (msg.startsWith('Uploading')) {
      final regex = RegExp(r'(\d+)\s*of\s*(\d+)');
      final match = regex.firstMatch(msg);
      if (match != null) {
        return '${l10n.uploading.replaceAll("...", "")} ${match.group(1)}/${match.group(2)}';
      }
      return l10n.uploading;
    } else if (msg.contains('Creating') || msg.contains('Preparing') || msg.contains('Saving') || msg.contains('Validating')) {
      return l10n.submittingRequest;
    } else if (msg == 'Request submitted successfully') {
      return l10n.serviceRequestSuccess;
    } else if (msg.startsWith('Failed to submit')) {
      return l10n.submissionFailed('');
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.submittingRequest,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getLocalizedMessage(context, message),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
