import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class GallerySnippet extends StatelessWidget {
  static const _count = 4;

  final List<String> images;
  const GallerySnippet({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withAlpha(100)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: List.generate(_count, (index) {
              // Check if we have enough images
              if (index >= images.length) {
                return const SizedBox(width: 70, height: 70);
              }
              
              final url = images[index];
              return SizedBox(
                width: 70,
                height: 70,
                child: index == 3 && images.length > _count
                    ? _MoreGallery(url: url, more: images.length - _count + 1)
                    : _GalleryItem(url: url),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  const _GalleryItem({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ExtendedImage.network(url, fit: BoxFit.cover),
    );
  }
}

class _MoreGallery extends StatelessWidget {
  const _MoreGallery({required this.url, required this.more});
  final String url;
  final int more;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExtendedImage.network(url, fit: BoxFit.cover),
          ColoredBox(color: Colors.black.withValues(alpha: 0.6)),
          Center(
            child: Text(
              '+$more',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
