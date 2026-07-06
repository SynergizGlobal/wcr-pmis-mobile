import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/home/widgets/dashboard_slideshow_constants.dart';

class DashboardHomeSlideshow extends StatefulWidget {
  const DashboardHomeSlideshow({
    super.key,
    this.animationType = DashboardSlideshowAnimationType.active,
    this.autoPlayInterval = const Duration(milliseconds: 3000),
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  final int animationType;
  final Duration autoPlayInterval;
  final Duration transitionDuration;

  @override
  State<DashboardHomeSlideshow> createState() => _DashboardHomeSlideshowState();
}

class _DashboardHomeSlideshowState extends State<DashboardHomeSlideshow> {
  static const int _virtualItemCount = 10000;
  static const List<_DashboardSlide> _slides = <_DashboardSlide>[
    _DashboardSlide(assetPath: 'assets/dashboard_slides/slide_1.png'),
    _DashboardSlide(assetPath: 'assets/dashboard_slides/slide_2.png'),
    _DashboardSlide(
      assetPath: 'assets/dashboard_slides/slide_3.png',
      caption:
          'Important Bridge No. 80304 (16x45.7 m span) (Sone River) at Churhat - Sidhi',
    ),
    _DashboardSlide(
      assetPath: 'assets/dashboard_slides/slide_4.png',
      caption:
          'TUNNEL (BLT) T3 - TCL casting Qty=60 cum at Churhat-Sidhi on 25.02.26',
    ),
    _DashboardSlide(
      assetPath: 'assets/dashboard_slides/slide_5.png',
      caption: 'Baghwar Station',
    ),
    _DashboardSlide(
      assetPath: 'assets/dashboard_slides/slide_6.png',
      caption:
          'TUNNEL (BLT) T3 - TCL Layer Concrete, Grade-M35, Total length-462 meter Previous Done=195 m, Today-50 m comple, Casting Qty=59.4 cum WIP at Churhat - Sidhi on 10.01.26',
    ),
    _DashboardSlide(
      assetPath: 'assets/dashboard_slides/slide_7.png',
      caption: 'ROB at NH- 39 (1x50m Span) CH 3912 Distt. Satna',
    ),
    _DashboardSlide(
      assetPath: 'assets/dashboard_slides/slide_8.png',
      caption: 'Nagod Station - District Satna',
    ),
    _DashboardSlide(
      assetPath: 'assets/dashboard_slides/slide_9.png',
      caption:
          'Mar Br-15 STA River(5x30.5m CG) Satna-Barethiya-Distt.- STA',
    ),
    _DashboardSlide(assetPath: 'assets/dashboard_slides/slide_10.png'),
    _DashboardSlide(assetPath: 'assets/dashboard_slides/slide_11.png'),
  ];

  PageController? _pageController;
  int? _initialPage;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  bool get _usesSlideAnimation =>
      widget.animationType == DashboardSlideshowAnimationType.slide;

  @override
  void initState() {
    super.initState();
    _initSlideController();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant DashboardHomeSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationType != widget.animationType) {
      _disposeSlideController();
      _initSlideController();
      _startAutoPlay();
    } else if (oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _disposeSlideController();
    super.dispose();
  }

  void _initSlideController() {
    if (!_usesSlideAnimation) {
      return;
    }
    final int initialPage =
        _virtualItemCount ~/ 2 - (_virtualItemCount ~/ 2) % _slides.length;
    _initialPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
  }

  void _disposeSlideController() {
    _pageController?.dispose();
    _pageController = null;
    _initialPage = null;
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_slides.length < 2) {
      return;
    }
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) => _advance());
  }

  void _advance() {
    if (_usesSlideAnimation) {
      final PageController? controller = _pageController;
      if (controller == null || !controller.hasClients) {
        return;
      }
      controller.nextPage(
        duration: widget.transitionDuration,
        curve: Curves.easeInOut,
      );
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _currentPage = (_currentPage + 1) % _slides.length;
    });
  }

  void _onSlidePageChanged(int index) {
    final int slideIndex = index % _slides.length;
    setState(() => _currentPage = slideIndex);

    final int? initialPage = _initialPage;
    final PageController? controller = _pageController;
    if (initialPage == null || controller == null) {
      return;
    }

    if (index >= _virtualItemCount - _slides.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients) {
          controller.jumpToPage(initialPage + slideIndex);
        }
      });
    } else if (index <= _slides.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients) {
          controller.jumpToPage(initialPage + slideIndex);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: _usesSlideAnimation
                ? _buildSlideView(context)
                : _buildFadeView(context),
          ),
        ),
        if (_slides.length > 1) ...<Widget>[
          const SizedBox(height: 8),
          _buildPageIndicators(context),
        ],
      ],
    );
  }

  Widget _buildSlideView(BuildContext context) {
    final PageController? controller = _pageController;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return PageView.builder(
      controller: controller,
      itemCount: _virtualItemCount,
      onPageChanged: _onSlidePageChanged,
      itemBuilder: (BuildContext context, int index) {
        return _buildSlideCard(
          context,
          _slides[index % _slides.length],
        );
      },
    );
  }

  Widget _buildFadeView(BuildContext context) {
    final _DashboardSlide slide = _slides[_currentPage];
    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(slide.assetPath),
        child: _buildSlideCard(context, slide),
      ),
    );
  }

  Widget _buildSlideCard(BuildContext context, _DashboardSlide slide) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          slide.assetPath,
          fit: BoxFit.fitHeight,
          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            return ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
        if (slide.caption != null && slide.caption!.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const <double>[0, 0.35, 1],
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                child: Text(
                  slide.caption!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    shadows: const <Shadow>[
                      Shadow(
                        color: Color(0xCC000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                      Shadow(
                        color: Color(0x99000000),
                        blurRadius: 18,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPageIndicators(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(_slides.length, (int index) {
        final bool active = index == _currentPage;
        return AnimatedContainer(
          duration: widget.transitionDuration,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _DashboardSlide {
  const _DashboardSlide({
    required this.assetPath,
    this.caption,
  });

  final String assetPath;
  final String? caption;
}
