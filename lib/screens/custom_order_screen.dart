import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/custom_order_loader.dart';
import '../l10n/app_localizations.dart';
import '../widgets/voice_recorder_widget.dart';
import '../widgets/whatsapp_more_info_note.dart';

class CustomOrderScreen extends StatefulWidget {
  const CustomOrderScreen({
    super.key,
  });

  @override
  State<CustomOrderScreen> createState() =>
      CustomOrderScreenState();
}

class CustomOrderScreenState
    extends State<CustomOrderScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final ImagePicker imagePicker =
      ImagePicker();

  final List<File> selectedImages = [];
  File? selectedAudio;

  Future<void> pickImage() async {
    if (selectedImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.maxPhotosAllowed,
          ),
        ),
      );

      return;
    }

    final XFile? image =
        await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) {
      return;
    }

    setState(() {
      selectedImages.add(
        File(image.path),
      );
    });
  }

  Future<void> submitInquiry() async {
    final message =
        messageController.text.trim();

    if (selectedImages.isEmpty &&
        message.isEmpty &&
        selectedAudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseUploadPhotosOrMessage, // Can be improved but good for now
          ),
        ),
      );

      return;
    }

    try {
      await context
          .read<OrderProvider>()
          .placeInquiryOrder(
            images: selectedImages,
            message: message,
            audio: selectedAudio,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.inquirySubmittedSuccess,
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Widget buildImageCard(
    File image,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(18),
          child: Image.file(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedImages.remove(image);
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAddPhotoCard() {
    return InkWell(
      borderRadius:
          BorderRadius.circular(18),
      onTap: pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 10),

            Text(
              AppLocalizations.of(context)!.addPhoto,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider =
        context.watch<OrderProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
          backgroundColor:
              Colors.grey.shade50,

          appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(110),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary,
                borderRadius:
                    const BorderRadius.vertical(
                  bottom: Radius.circular(
                    26,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary
                        .withOpacity(
                          0.18,
                        ),
                    blurRadius: 14,
                    offset:
                        const Offset(
                      0,
                      6,
                    ),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.pop(
                          context,
                        ),
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .all(12),
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(
                              0.15,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                          child:
                              const Icon(
                            Icons
                                .arrow_back_rounded,
                            color:
                                Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      Expanded(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.customInquiry,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            SizedBox(
                              height: 4,
                            ),

                            Text(
                              AppLocalizations.of(context)!.uploadProductPhotosDetails,
                              style:
                                  TextStyle(
                                color:
                                    Colors.white70,
                                fontSize:
                                    14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .all(10),
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withOpacity(
                            0.12,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .inventory_2_rounded,
                          color:
                              Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          body: SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets
                          .all(20),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .all(14),
                        decoration:
                            BoxDecoration(
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .primary
                              .withOpacity(
                                .1,
                              ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                        child:
                            Icon(
                          Icons
                              .photo_camera_back,
                          color:
                              Theme.of(
                            context,
                          )
                              .colorScheme
                              .primary,
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.cantFindProduct,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize:
                                    18,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              AppLocalizations.of(context)!.uploadPhotosOrDescribe,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.photosCount(selectedImages.length),
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount:
                      selectedImages.length <
                              4
                          ? selectedImages
                                  .length +
                              1
                          : 4,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing:
                        12,
                    mainAxisSpacing:
                        12,
                    childAspectRatio:
                        1,
                  ),
                  itemBuilder:
                      (context, index) {
                    if (index <
                        selectedImages
                            .length) {
                      return buildImageCard(
                        selectedImages[
                            index],
                      );
                    }

                    return buildAddPhotoCard();
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                Card(
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(16),
                    child: TextField(
                      controller:
                          messageController,
                      maxLength: 500,
                      minLines: 5,
                      maxLines: 8,
                      decoration:
                          InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.describeProductHint,
                        border:
                            InputBorder
                                .none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.voiceNote,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                VoiceRecorderWidget(
                  onAudioRecorded: (file) {
                    setState(() {
                      selectedAudio = file;
                    });
                  },
                ),

                const SizedBox(
                  height: 16,
                ),
                const WhatsAppMoreInfoNote(),

                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),

          bottomNavigationBar:
              SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets
                      .all(16),
              child: SizedBox(
                height: 58,
                child:
                    ElevatedButton(
                  onPressed:
                      orderProvider
                              .isPlacingOrder
                          ? null
                          : submitInquiry,
                  child:
                      Text(
                    AppLocalizations.of(context)!.placeInquiryOrder,
                  ),
                ),
              ),
            ),
          ),
        ),

        if (orderProvider
            .isPlacingOrder)
          InquiryOrderLoader(
            message:
                orderProvider
                    .inquiryProgressMessage,
          ),
      ],
    ),
    );
  }
}