import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class CircularCachedImage extends StatelessWidget {
  final String _imageUrl;
  final double _size;
  final Widget _placeHolderWidget, _defaultWidget;

  ImageProvider _imageProvider;

  CircularCachedImage(
      this._imageUrl, this._size, this._placeHolderWidget, this._defaultWidget);

  ImageProvider get imageProvider {
    return _imageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_size / 2),
        child: CachedNetworkImage(
          imageUrl: _imageUrl,
          imageBuilder: (BuildContext context, ImageProvider imageProvider) {
            _imageProvider = imageProvider;
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          placeholder: (context, url) => _placeHolderWidget,
          errorWidget: (context, url, error) => _defaultWidget,
        ),
      ),
    );
  }
}
