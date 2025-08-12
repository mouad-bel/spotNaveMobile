import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/common/widgets/custom_failed_section.dart';
import 'package:spotnav/common/widgets/custom_outlined_button.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/data/models/saved_destination_model.dart';
import 'package:spotnav/presentation/destination_detail/blocs/detail/destination_detail_bloc.dart';
import 'package:spotnav/presentation/destination_detail/blocs/is_saved/is_saved_destination_bloc.dart';
import 'package:spotnav/presentation/saved_destinations/bloc/saved_destinations_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';

import 'detail_sheet.dart';
import 'gallery_snippet.dart';

class DestinationDetailsPage extends StatefulWidget {
  const DestinationDetailsPage({super.key, required this.id});
  final String id;

  @override
  State<DestinationDetailsPage> createState() => _DestinationDetailsPageState();
}

class _DestinationDetailsPageState extends State<DestinationDetailsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PersistentBottomSheetController? _persistentController;

  void _showDetailSheet(DestinationModel destination) {
    // Prevent showing multiple sheets
    if (_persistentController != null) {
      debugPrint("Sheet is already open.");
      return;
    }

    _persistentController = _scaffoldKey.currentState?.showBottomSheet(
      (context) => DetailSheet(destination: destination),
      enableDrag: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );

    // This ensures the controller is reset when the sheet is dismissed programmatically or otherwise.
    _persistentController?.closed.whenComplete(() {
      if (mounted) {
        _persistentController = null;
        context.pop();
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DestinationDetailBloc>().add(
        GetDestinationDetailEvent(id: widget.id),
      );
      context.read<IsSavedDestinationBloc>().add(
        CheckIsSavedStatusEvent(destinationId: widget.id.toString()),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkMode : false;
        
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leadingWidth: 72,
            leading: const CustomBackButton(),
            actionsPadding: const EdgeInsets.only(right: 16),
            actions: [
              BlocBuilder<DestinationDetailBloc, DestinationDetailState>(
                builder: (context, state) {
                  if (state is! DestinationDetailLoaded) {
                    return const SizedBox.shrink();
                  }
                  final destination = state.destination;
                  return BlocConsumer<
                    IsSavedDestinationBloc,
                    IsSavedDestinationState
                  >(
                    listener: (context, state) {
                      if (state is IsSavedDestinationOperationSuccess) {
                        context.read<SavedDestinationsBloc>().add(
                          const FetchSavedDestinationsEvent(),
                        );
                        SnackbarUtil.showSuccess(context, state.message);
                      }
                      if (state is IsSavedDestinationFailed) {
                        SnackbarUtil.showError(context, state.failure.message);
                      }
                    },
                    builder: (context, state) {
                      final isSaved = state.isSaved;
                      if (isSaved == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.getPrimaryColor(isDarkMode),
                          ),
                        );
                      }
                      final icon = isSaved
                          ? AppAssets.icons.archive.remove
                          : AppAssets.icons.archive.add;
                      final savedDestination = SavedDestinationModel(
                        id: destination.id.toString(),
                        name: destination.name,
                        cover: destination.cover,
                      );
                      return IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
                          elevation: 8,
                          shadowColor: AppColors.getShadowColor(isDarkMode),
                        ),
                        onPressed: () {
                          context.read<IsSavedDestinationBloc>().add(
                            ToggleIsSavedStatusEvent(
                              destination: savedDestination,
                              isCurrentlySaved: isSaved,
                            ),
                          );
                        },
                        icon: ImageIcon(AssetImage(icon)),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: BlocConsumer<DestinationDetailBloc, DestinationDetailState>(
            listener: (context, state) {
              if (state is DestinationDetailLoaded) {
                _showDetailSheet(state.destination);
              }
            },
            builder: (context, state) {
              if (state is DestinationDetailLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.getPrimaryColor(isDarkMode),
                  ),
                );
              }
              if (state is DestinationDetailFailed) {
                return CustomFailedSection(failure: state.failure);
              }
              if (state is DestinationDetailLoaded) {
                final destination = state.destination;
                return FractionallySizedBox(
                  heightFactor: 0.75,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ExtendedImage.network(
                          destination.cover,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.sizeOf(context).height * 0.1 + 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                                                     children: [
                             ClipRRect(
                               child: BackdropFilter(
                                 filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                 child: CustomOutlinedButton(
                                   onPressed: () {
                                     context.push(
                                       '/destinations/gallery',
                                       extra: {
                                         'title': destination.name,
                                         'images': destination.gallery,
                                       },
                                     );
                                   },
                                   text: 'Gallery',
                                   height: 30,
                                   width: 100,
                                   backgroundColor: AppColors.getCardBackgroundColor(isDarkMode).withOpacity(0.8),
                                   foregroundColor: AppColors.getTextPrimaryColor(isDarkMode),
                                   outlineColor: Colors.transparent,
                                 ),
                               ),
                             ),
                            const Gap(8),
                            GallerySnippet(images: destination.gallery!),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
