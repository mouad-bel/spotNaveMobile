import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/app_constants.dart';
import 'package:spotnav/presentation/home/bloc/categories_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomeCategory extends StatelessWidget {
  final bool isDarkMode;
  
  const HomeCategory({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoriesBloc(
        destinationRepository: context.read(),
      )..add(const FetchCategoriesEvent()),
      child: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.getTextPrimaryColor(isDarkMode),
                    ),
                  ),
                ),
                const Gap(16),
                SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.getPrimaryColor(isDarkMode),
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is CategoriesFailed) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.getTextPrimaryColor(isDarkMode),
                    ),
                  ),
                ),
                const Gap(16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    itemCount: AppConstants.categories.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 16),
                    itemBuilder: (context, index) {
                      final category = AppConstants.categories[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 16 : 6,
                          right: index == AppConstants.categories.length - 1 ? 16 : 6,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to unified destinations page with category filter
                            context.push('/destinations?filter=${category.toLowerCase()}');
                          },
                          child: Chip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: AppColors.getTextPrimaryColor(isDarkMode),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
                            side: BorderSide(
                              color: AppColors.getDividerColor(isDarkMode),
                              width: 1,
                            ),
                            elevation: 2,
                            shadowColor: AppColors.getShadowColor(isDarkMode),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is CategoriesLoaded) {
            final categories = state.categories;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.getTextPrimaryColor(isDarkMode),
                    ),
                  ),
                ),
                const Gap(16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    itemCount: categories.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 16),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 16 : 6,
                          right: index == categories.length - 1 ? 16 : 6,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to unified destinations page with category filter
                            context.push('/destinations?filter=${category.toLowerCase()}');
                          },
                          child: Chip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: AppColors.getTextPrimaryColor(isDarkMode),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
                            side: BorderSide(
                              color: AppColors.getDividerColor(isDarkMode),
                              width: 1,
                            ),
                            elevation: 2,
                            shadowColor: AppColors.getShadowColor(isDarkMode),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Fallback to static categories
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.getTextPrimaryColor(isDarkMode),
                  ),
                ),
              ),
              const Gap(16),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  itemCount: AppConstants.categories.length,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 16),
                  itemBuilder: (context, index) {
                    final category = AppConstants.categories[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 16 : 6,
                        right: index == AppConstants.categories.length - 1 ? 16 : 6,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to unified destinations page with category filter
                          context.push('/destinations?filter=${category.toLowerCase()}');
                        },
                        child: Chip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: AppColors.getTextPrimaryColor(isDarkMode),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
                          side: BorderSide(
                            color: AppColors.getDividerColor(isDarkMode),
                            width: 1,
                          ),
                          elevation: 2,
                          shadowColor: AppColors.getShadowColor(isDarkMode),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
