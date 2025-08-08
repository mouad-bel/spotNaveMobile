import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:spotnav/data/models/destination_model.dart';
import 'package:spotnav/presentation/suggested_destinations/bloc/suggested_destinations_bloc.dart';
import 'package:spotnav/presentation/suggested_destinations/views/suggested_destination_card.dart';

class SuggestedDestinationsPage extends StatefulWidget {
  final String category;
  final String excludeDestinationId;

  const SuggestedDestinationsPage({
    super.key,
    required this.category,
    required this.excludeDestinationId,
  });

  @override
  State<SuggestedDestinationsPage> createState() => _SuggestedDestinationsPageState();
}

class _SuggestedDestinationsPageState extends State<SuggestedDestinationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SuggestedDestinationsBloc>().add(
      LoadSuggestedDestinations(
        category: widget.category,
        excludeDestinationId: widget.excludeDestinationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Suggested for You',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SuggestedDestinationsBloc, SuggestedDestinationsState>(
        builder: (context, state) {
          if (state is SuggestedDestinationsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SuggestedDestinationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const Gap(16),
                  Text(
                    'Failed to load suggestions',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Gap(8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SuggestedDestinationsBloc>().add(
                        LoadSuggestedDestinations(
                          category: widget.category,
                          excludeDestinationId: widget.excludeDestinationId,
                        ),
                      );
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is SuggestedDestinationsLoaded) {
            if (state.destinations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const Gap(16),
                    Text(
                      'No suggestions found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'We couldn\'t find any similar destinations.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Based on your interest in ${widget.category} destinations',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Here are some destinations you might enjoy:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.destinations.length,
                    itemBuilder: (context, index) {
                      final destination = state.destinations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SuggestedDestinationCard(
                          destination: destination,
                          onTap: () {
                            context.push('/destinations/${destination.id}');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
} 