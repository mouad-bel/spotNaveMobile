import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageSourcesSection extends StatefulWidget {
  final List<String> sources;

  const ImageSourcesSection({super.key, required this.sources});

  @override
  State<ImageSourcesSection> createState() => _ImageSourcesSectionState();
}

class _ImageSourcesSectionState extends State<ImageSourcesSection> {
  static final _logger = Logger('ImageSourcesSection');

  void _openLink(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      _logger.severe('Could not launch $url', e);
      if (mounted) SnackbarUtil.showError(context, 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Image Sources',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.sources.map((e) {
              return Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: AppColors.textSecondary,
                  ),
                  const Gap(12),
                  LinkifyText(
                    e,
                    linkStyle: const TextStyle(color: AppColors.primary),
                    onTap: (link) {
                      if (link.type == LinkType.url) _openLink(link.value!);
                    },
                    // style: TextStyle(
                    //   fontWeight: FontWeight.w400,
                    //   fontSize: 14,
                    //   color: AppColors.textSecondary,
                    //   decoration: TextDecoration.underline,
                    // ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
