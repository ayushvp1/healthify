import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:grown_health/services/nutrition_service.dart';
import 'recipe_detail_screen.dart';

/// Screen that displays all recipes from the API
class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({super.key});

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  List<NutritionItem> _recipes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final recipes = await NutritionService.getRecipes(limit: 50);
      if (mounted) {
        setState(() {
          _recipes = recipes;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Recipes',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.grey400),
            const SizedBox(height: 16),
            Text(
              'Failed to load recipes',
              style: GoogleFonts.inter(fontSize: 16, color: AppTheme.grey600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecipes,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: AppTheme.grey300),
            const SizedBox(height: 16),
            Text(
              'No recipes available',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new recipes!',
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecipes,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return _RecipeCard(
            recipe: recipe,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final NutritionItem recipe;
  final VoidCallback onTap;

  const _RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppTheme.grey200),
        ),
        child: Row(
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: recipe.image.isNotEmpty
                  ? Image.network(
                      recipe.image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            // Recipe Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.calories} cal',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.grey600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.timer, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTime} min',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: AppTheme.lightPinkBg,
      child: Icon(
        Icons.restaurant_menu,
        size: 40,
        color: AppTheme.primaryColor.withOpacity(0.5),
      ),
    );
  }
}
