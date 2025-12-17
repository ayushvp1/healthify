import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:grown_health/services/nutrition_service.dart';

/// Recipe Detail Screen - Shows full details of a recipe
class RecipeDetailScreen extends StatelessWidget {
  final NutritionItem recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppTheme.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppTheme.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: recipe.image.isNotEmpty
                  ? Image.network(
                      recipe.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats Row
                  _buildStatsRow(),
                  const SizedBox(height: 24),

                  // Description
                  if (recipe.description.isNotEmpty) ...[
                    _buildSectionTitle('Description'),
                    const SizedBox(height: 12),
                    Text(
                      recipe.description,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.6,
                        color: AppTheme.grey700,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Ingredients
                  if (recipe.ingredients.isNotEmpty) ...[
                    _buildSectionTitle('Ingredients'),
                    const SizedBox(height: 12),
                    _buildIngredientsList(),
                    const SizedBox(height: 24),
                  ],

                  // Instructions
                  if (recipe.instructions.isNotEmpty) ...[
                    _buildSectionTitle('Instructions'),
                    const SizedBox(height: 12),
                    _buildInstructions(),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.lightPinkBg,
      child: Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 80,
          color: AppTheme.primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.local_fire_department_rounded,
            '${recipe.calories}',
            'Calories',
            Colors.orange,
          ),
          Container(height: 40, width: 1, color: AppTheme.grey200),
          _buildStatItem(
            Icons.timer_rounded,
            '${recipe.prepTime} min',
            'Prep Time',
            Colors.blue,
          ),
          Container(height: 40, width: 1, color: AppTheme.grey200),
          _buildStatItem(
            Icons.category_rounded,
            recipe.type,
            'Type',
            AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.grey500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.black,
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: recipe.ingredients.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < recipe.ingredients.length - 1 ? 12 : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.grey800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructions() {
    // Split instructions by newlines or numbered patterns
    final steps = recipe.instructions
        .split(RegExp(r'\n|(?=\d+\.\s)'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (steps.length <= 1) {
      // Single block of text
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.grey200),
        ),
        child: Text(
          recipe.instructions,
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.6,
            color: AppTheme.grey800,
          ),
        ),
      );
    }

    // Multiple steps
    return Column(
      children: steps.asMap().entries.map((entry) {
        final stepText = entry.value
            .replaceFirst(RegExp(r'^\d+\.\s*'), '')
            .trim();
        if (stepText.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  stepText,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.grey800,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
