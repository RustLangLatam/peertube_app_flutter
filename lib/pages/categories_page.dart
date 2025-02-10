import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/api_provider.dart';
import '../widgets/peertube_logo_widget.dart';
import 'category_page.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  final String node;

  const CategoriesScreen({super.key, required this.node});

  @override
  ConsumerState<CategoriesScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<CategoriesScreen> {
  List<VideoConstantNumberCategory> categoriesWithIcons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => isLoading = true);

    try {
      final api = ref.read(videoApiProvider());

      final response = await api.getCategories();

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          categoriesWithIcons = response.data!.asMap().entries.map((entry) {
            return VideoConstantNumberCategory((b) => b
              ..id = int.parse(entry.key)
              ..label = entry.value.asString);
          }).toList();
        });
      }
    } catch (error) {
      debugPrint('Error fetching categories: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Returns the corresponding icon for each category.
  IconData _getIconForCategory(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.music_note_outlined;
      case 2:
        return Icons.movie_outlined;
      case 3:
        return Icons.bike_scooter_outlined;
      case 4:
        return Icons.brush_outlined;
      case 5:
        return Icons.sports;
      case 6:
        return Icons.airplane_ticket_outlined;
      case 7:
        return Icons.games_outlined;
      case 8:
        return Icons.emoji_people_rounded;
      case 9:
        return Icons.theater_comedy_outlined;
      case 10:
        return Icons.tv_outlined;
      case 11:
        return Icons.newspaper_outlined;
      case 12:
        return Icons.settings_applications;
      case 13:
        return Icons.school_outlined;
      case 14:
        return Icons.volunteer_activism_outlined;
      case 15:
        return Icons.science_outlined;
      case 16:
        return Icons.forest_outlined;
      case 17:
        return Icons.child_friendly_outlined;
      case 18:
        return Icons.fastfood_rounded;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.grey[700]!;

    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: isLoading
          ? _buildShimmerEffect() // Show shimmer while loading
          : categoriesWithIcons.isEmpty
              ? const Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount: categoriesWithIcons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Three categories per row
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9, // Adjusted aspect ratio
                    ),
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(
                        categoriesWithIcons[index],
                        _getIconForCategory(categoriesWithIcons[index].id!),
                        primaryColor,
                      );
                    },
                  ),
                ),
    );
  }

  /// Builds the app bar with search & settings
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      title: PeerTubeTextWidget(text: 'Discover'),
      leading: PeerTubeLogoWidget(),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  /// Builds an elegant category card
  Widget _buildCategoryCard(
      VideoConstantNumberCategory category, IconData iconData, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryVideosScreen(
              node: widget.node,
              category: category,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circle with icon and logo
            Stack(
              alignment: Alignment.center,
              children: [
                // Circle background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.9), width: 1),
                  ),
                ),
                // Icon on top of the logo
                Icon(iconData, color: color.withOpacity(0.9), size: 28),
              ],
            ),
            const SizedBox(height: 8),
            // Category name with shadow
            Text(
              category.label!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the shimmer effect for loading state
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: 16, // Number of shimmer placeholders
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Three placeholders per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9, // Adjusted aspect ratio
          ),
          itemBuilder: (context, index) {
            return _buildShimmerCategoryCard();
          },
        ),
      ),
    );
  }

  /// Builds a shimmering category card placeholder
  Widget _buildShimmerCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!.withOpacity(0.2),
            Colors.grey[800]!.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shimmering circle placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.grey[800]!.withOpacity(0.3), width: 2),
            ),
          ),
          const SizedBox(height: 8),
          // Shimmering text placeholder
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
