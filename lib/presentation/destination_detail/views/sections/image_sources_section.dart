import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Image Sources',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.getTextPrimaryColor(isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.sources.map((e) {
                  return Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                      ),
                      const Gap(12),
                      LinkifyText(
                        e,
                        linkStyle: TextStyle(color: AppColors.getPrimaryColor(isDarkMode)),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: AppColors.getTextSecondaryColor(isDarkMode),
                        ),
                        onTap: (link) {
                          if (link.type == LinkType.url) _openLink(link.value!);
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
