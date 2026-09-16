import 'dart:async';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    if (widget.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      int nextIndex = _currentIndex + 1;
      if (nextIndex >= widget.imageUrls.length) {
        nextIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onUserInteraction(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
    _timer?.cancel();
    if (widget.imageUrls.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.isEmpty ? 1 : widget.imageUrls.length,
            onPageChanged: _onUserInteraction,
            itemBuilder: (context, index) {
              if (widget.imageUrls.isEmpty) {
                return Container(
                  color: const Color(0xFFE0E3E5),
                  child: const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
                );
              }

              return Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE0E3E5),
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == index ? const Color(0xFF6CF8BB) : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}