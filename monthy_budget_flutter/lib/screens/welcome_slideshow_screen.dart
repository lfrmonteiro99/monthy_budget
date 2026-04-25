import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../constants/app_constants.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

class WelcomeSlideshowScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomeSlideshowScreen({super.key, required this.onComplete});

  @override
  State<WelcomeSlideshowScreen> createState() => _WelcomeSlideshowScreenState();
}

class _WelcomeSlideshowScreenState extends State<WelcomeSlideshowScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final slides = _buildSlides(l10n);

    return CalmScaffold(
      body: Column(
        children: [
          // Skip button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton(
                onPressed: widget.onComplete,
                child: Text(
                  l10n.onbSkip,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            ),
          ),
          // Slides
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => _buildSlide(context, slides[i]),
            ),
          ),
          // Swipe hint on first slide
          if (_currentPage == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.onbSwipeHint,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          // Dot indicator + button
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                Semantics(
                  label: l10n.onbSlideOf(_currentPage + 1, slides.length),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (i) => Container(
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary(context)
                              : AppColors.border(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_currentPage < slides.length - 1) {
                        _controller.nextPage(
                          duration: AppConstants.animPageTransition,
                          curve: Curves.easeInOut,
                        );
                      } else {
                        widget.onComplete();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage < slides.length - 1
                          ? l10n.onbNext
                          : l10n.onbGetStarted,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(BuildContext context, _SlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary(context),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 56, color: AppColors.onPrimary(context)),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<_SlideData> _buildSlides(S l10n) => [
        _SlideData(Icons.dashboard, l10n.onbSlide0Title, l10n.onbSlide0Body),
        _SlideData(Icons.add_circle_outline, l10n.onbSlide1Title, l10n.onbSlide1Body),
        _SlideData(Icons.shopping_basket_outlined, l10n.onbSlide2Title, l10n.onbSlide2Body),
        _SlideData(Icons.psychology_outlined, l10n.onbSlide3Title, l10n.onbSlide3Body),
        _SlideData(Icons.restaurant_outlined, l10n.onbSlide4Title, l10n.onbSlide4Body),
      ];
}

class _SlideData {
  final IconData icon;
  final String title;
  final String body;
  const _SlideData(this.icon, this.title, this.body);
}
