import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_workflow_builder/utils/responsive_design.dart';

class ImagePreview extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback? onClear; // To clear a specific image if needed in future

  const ImagePreview({super.key, required this.images, this.onClear});

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width > 600 ? 120.0 : 100.0;
    return Container(
      height: imageSize + 16, // Set a fixed height for the horizontal list
      padding: EdgeInsets.all(ResponsiveDesign.sectionSpacing(context) * 0.5),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(
          ResponsiveDesign.borderRadius(context),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageFile = images[index];
          final imageSize = MediaQuery.of(context).size.width > 600
              ? 120.0
              : 100.0;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveDesign.sectionSpacing(context) * 0.25,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ResponsiveDesign.borderRadius(context) * 0.7,
              ),
              child: Image.file(
                File(imageFile.path),
                fit: BoxFit.cover,
                width: imageSize,
                height: imageSize,
              ),
            ),
          );
        },
      ),
    );
  }
}
