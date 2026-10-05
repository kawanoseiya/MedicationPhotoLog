import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// 撮影・取り込みと、端末内の文字読み取り。
///
/// - 撮影は iOS の書類スキャナ（VisionKit）。複数ページを続けて撮れて、
///   紙の輪郭に合わせて切り抜き・傾き補正される。使えない端末ではカメラで1枚ずつ撮る
/// - 文字読み取りは Vision（日本語・英語）。画像を端末の外へ送らない
class ScanService {
  ScanService._();

  static const _channel = MethodChannel('snapmed/scanner');
  static final _picker = ImagePicker();

  /// 書類スキャナで撮る。撮った各ページの一時ファイルのパス（キャンセルなら空）。
  static Future<List<String>> scan() async {
    try {
      final supported =
          await _channel.invokeMethod<bool>('isScannerSupported') ?? false;
      if (supported) {
        final paths = await _channel.invokeListMethod<String>('scan');
        return paths ?? const [];
      }
    } on PlatformException catch (e) {
      debugPrint('書類スキャナを使えませんでした: $e');
    } on MissingPluginException {
      // テスト環境など。カメラへ。
    }
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 85,
    );
    return photo == null ? const [] : [photo.path];
  }

  /// 写真ライブラリから選ぶ（複数可）。
  static Future<List<String>> pickFromLibrary() async {
    final photos = await _picker.pickMultiImage(
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 85,
    );
    return [for (final p in photos) p.path];
  }

  /// 画像の文字を読む。上から順の行（Vision の1まとまりずつ）。
  static Future<List<String>> recognize(String path) async {
    try {
      final lines = await _channel.invokeListMethod<String>('recognize', {
        'path': path,
      });
      return lines ?? const [];
    } on PlatformException catch (e) {
      debugPrint('文字を読み取れませんでした: $e');
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }
}
