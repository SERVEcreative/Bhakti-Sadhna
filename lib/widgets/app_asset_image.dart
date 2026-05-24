import 'package:bhakti_sadhana/core/assets/asset_image_resolver.dart';
import 'package:bhakti_sadhana/core/assets/asset_paths.dart';
import 'package:flutter/material.dart';

/// PNG asset image — known .png paths load synchronously (smooth scroll).
class AppAssetImage extends StatefulWidget {
  const AppAssetImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fallback,
    this.errorBuilder,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Widget? fallback;
  final ImageErrorWidgetBuilder? errorBuilder;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  State<AppAssetImage> createState() => _AppAssetImageState();
}

class _AppAssetImageState extends State<AppAssetImage> {
  String? _resolvedPath;
  bool _failed = false;
  bool _loading = true;

  bool get _isDirectPng =>
      widget.assetPath.toLowerCase().endsWith('.png');

  @override
  void initState() {
    super.initState();
    if (_isDirectPng) {
      _resolvedPath = widget.assetPath;
      _loading = false;
    } else {
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant AppAssetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      if (_isDirectPng) {
        setState(() {
          _resolvedPath = widget.assetPath;
          _loading = false;
          _failed = false;
        });
      } else {
        _resolvedPath = null;
        _failed = false;
        _loading = true;
        _load();
      }
    }
  }

  Future<void> _load() async {
    final path = await AssetImageResolver.resolvePng(widget.assetPath);
    if (!mounted) return;
    if (path == null) {
      setState(() {
        _loading = false;
        _failed = true;
      });
      return;
    }
    setState(() {
      _resolvedPath = path;
      _loading = false;
      _failed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
      );
    }

    if (_failed || _resolvedPath == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.fallback ?? const SizedBox.shrink(),
      );
    }

    return Image.asset(
      _resolvedPath!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      filterQuality: FilterQuality.medium,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      gaplessPlayback: true,
      errorBuilder: widget.errorBuilder ??
          (context, error, stackTrace) =>
              widget.fallback ?? const SizedBox.shrink(),
    );
  }
}

/// Deity/category thumbnails — sized decode for lists.
int? assetCacheDimension(double logicalSize, BuildContext context) {
  if (logicalSize.isFinite && logicalSize > 0) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (logicalSize * dpr).round().clamp(64, 512);
  }
  return null;
}

String deityPngPath(String id) => AssetPaths.deityImage(id);
