import 'package:extended_image/extended_image.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key, required this.images, required this.title});
  final String title;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            title: Text(
              title,
              style: TextStyle(
                color: AppColors.getTextPrimaryColor(isDarkMode),
              ),
            ),
            titleSpacing: 0,
            centerTitle: true,
            leading: const CustomBackButton(),
            forceMaterialTransparency: true,
            backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          ),
          body: MasonryGridView.count(
            itemCount: images.length,
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemBuilder: (context, index) {
              final imageURL = images[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          InteractiveViewer(child: ExtendedImage.network(imageURL)),
                          Positioned(
                            bottom: 60,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: CloseButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: ExtendedImage.network(imageURL),
              );
            },
          ),
        );
      },
    );
  }
}
