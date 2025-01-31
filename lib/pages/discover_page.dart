// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:peer_tube_api_sdk/peer_tube_api_sdk.dart';
import 'package:system_theme/system_theme.dart';

import '../widgets/peertube_logo_widget.dart';
import 'category_page.dart';

class DiscoverScreen extends StatefulWidget {
  final PeerTubeApiSdk api;

  const DiscoverScreen({Key? key, required this.api}) : super(key: key);

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<Map<String, dynamic>> categoriesWithIcons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => isLoading = true);

    try {
      final response = await widget.api.getVideoApi().getCategories();

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          categoriesWithIcons = response.data!
              .asMap()
              .entries
              .map((entry) => {
                    'name': entry.value.asString,
                    'icon': _getIconForCategory(entry.key)
                  })
              .toList();
        });
      }
    } catch (error) {
      debugPrint('Error fetching categories: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Returns the corresponding icon for each category.
  IconData _getIconForCategory(String categoryId) {
    switch (categoryId) {
      case '1':
        return Icons.music_note_outlined;
      case '2':
        return Icons.movie_outlined;
      case '3':
        return Icons.bike_scooter_outlined;
      case '4':
        return Icons.brush_outlined;
      case '5':
        return Icons.sports;
      case '6':
        return Icons.airplane_ticket_outlined;
      case '7':
        return Icons.games_outlined;
      case '8':
        return Icons.emoji_people_rounded;
      case '9':
        return Icons.theater_comedy_outlined;
      case '10':
        return Icons.tv_outlined;
      case '11':
        return Icons.newspaper_outlined;
      case '12':
        return Icons.settings_applications;
      case '13':
        return Icons.school_outlined;
      case '14':
        return Icons.volunteer_activism_outlined;
      case '15':
        return Icons.science_outlined;
      case '16':
        return Icons.forest_outlined;
      case '17':
        return Icons.child_friendly_outlined;
      case '18':
        return Icons.fastfood_rounded;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = SystemTheme.accentColor.accent;

    return Scaffold(
      backgroundColor: const Color(0xFF13100E),
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoriesWithIcons.isEmpty
              ? const Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    itemCount: categoriesWithIcons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two categories per row
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.8, // Adjusted aspect ratio
                    ),
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(
                        categoriesWithIcons[index]['name'],
                        index + 1,
                        categoriesWithIcons[index]['icon'],
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
      String category, int categoryId, IconData iconData, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryVideosScreen(
              api: widget.api,
              categoryName: category,
              categoryId: categoryId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1B18), // Slightly lighter than background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.6), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(iconData, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
