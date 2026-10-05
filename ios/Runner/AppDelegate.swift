import Flutter
import ImageIO
import UIKit
import Vision
import VisionKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MedScanPlugin") {
      MedScanPlugin.register(with: registrar)
    }
  }
}

/// 薬の説明書・薬袋・ラベルの撮影（VisionKit の書類スキャナ）と、端末内の文字認識（Vision）。
///
/// 撮った画像はアプリの一時フォルダにだけ書き出し、保存するかどうかは Flutter 側が決める。
/// 画像や文字を端末の外へ送ることはない。
final class MedScanPlugin: NSObject, FlutterPlugin, VNDocumentCameraViewControllerDelegate {
  private let queue = DispatchQueue(label: "snapmed.scan", qos: .userInitiated)
  private var pendingScan: FlutterResult?

  /// 長辺の上限。読み取りと見返しに十分で、保存容量を抑えられる大きさ。
  private static let maxSide: CGFloat = 2400

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "snapmed/scanner", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(MedScanPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isScannerSupported":
      result(VNDocumentCameraViewController.isSupported)
    case "scan":
      presentScanner(result: result)
    case "recognize":
      guard let args = call.arguments as? [String: Any], let path = args["path"] as? String else {
        result(FlutterError(code: "bad_args", message: "path is required", details: nil))
        return
      }
      queue.async {
        let lines = MedScanPlugin.recognize(path: path)
        DispatchQueue.main.async { result(lines) }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - 書類スキャナ

  private func presentScanner(result: @escaping FlutterResult) {
    guard VNDocumentCameraViewController.isSupported else {
      result(FlutterError(code: "unsupported", message: "Document camera is not supported", details: nil))
      return
    }
    guard pendingScan == nil, let top = MedScanPlugin.topViewController() else {
      result(FlutterError(code: "busy", message: "Scanner is not available now", details: nil))
      return
    }
    pendingScan = result
    let scanner = VNDocumentCameraViewController()
    scanner.delegate = self
    top.present(scanner, animated: true)
  }

  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan
  ) {
    let images = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
    controller.dismiss(animated: true)
    queue.async { [weak self] in
      let paths = images.compactMap { MedScanPlugin.writeJpeg($0) }
      DispatchQueue.main.async { self?.finishScan(paths) }
    }
  }

  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    controller.dismiss(animated: true)
    finishScan([])
  }

  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController, didFailWithError error: Error
  ) {
    controller.dismiss(animated: true)
    let result = pendingScan
    pendingScan = nil
    result?(FlutterError(code: "scan_failed", message: error.localizedDescription, details: nil))
  }

  private func finishScan(_ paths: [String]) {
    let result = pendingScan
    pendingScan = nil
    result?(paths)
  }

  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window =
      scenes.flatMap { $0.windows }.first { $0.isKeyWindow } ?? scenes.first?.windows.first
    var top = window?.rootViewController
    while let presented = top?.presentedViewController { top = presented }
    return top
  }

  private static func writeJpeg(_ image: UIImage) -> String? {
    let scaled = downscale(image)
    guard let data = scaled.jpegData(compressionQuality: 0.85) else { return nil }
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("scan_\(UUID().uuidString).jpg")
    do {
      try data.write(to: url, options: .atomic)
      return url.path
    } catch {
      return nil
    }
  }

  private static func downscale(_ image: UIImage) -> UIImage {
    let size = image.size
    let longest = max(size.width, size.height)
    guard longest > maxSide else { return image }
    let ratio = maxSide / longest
    let target = CGSize(width: floor(size.width * ratio), height: floor(size.height * ratio))
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    return UIGraphicsImageRenderer(size: target, format: format).image { _ in
      image.draw(in: CGRect(origin: .zero, size: target))
    }
  }

  // MARK: - 文字認識

  /// 画像の文字を読み、上から順（同じ高さなら左から）の行で返す。
  private static func recognize(path: String) -> [String] {
    let url = URL(fileURLWithPath: path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else { return [] }
    let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    let raw = (props?[kCGImagePropertyOrientation] as? UInt32) ?? 1
    let orientation = CGImagePropertyOrientation(rawValue: raw) ?? .up

    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.recognitionLanguages = ["ja-JP", "en-US"]
    if #available(iOS 16.0, *) {
      request.revision = VNRecognizeTextRequestRevision3
    }

    let handler = VNImageRequestHandler(cgImage: image, orientation: orientation)
    do {
      try handler.perform([request])
    } catch {
      return []
    }
    let items: [(text: String, box: CGRect)] = (request.results ?? []).compactMap { obs in
      guard let text = obs.topCandidates(1).first?.string else { return nil }
      return (text, obs.boundingBox)
    }
    // Vision の座標は左下が原点。上から順に並べ、ほぼ同じ高さのものは1行として左から。
    let byTop = items.sorted { $0.box.maxY > $1.box.maxY }
    var rows: [[(text: String, box: CGRect)]] = []
    for item in byTop {
      if let first = rows.last?.first,
        abs(first.box.midY - item.box.midY) < min(first.box.height, item.box.height) * 0.5
      {
        rows[rows.count - 1].append(item)
      } else {
        rows.append([item])
      }
    }
    return rows.flatMap { row in row.sorted { $0.box.minX < $1.box.minX }.map { $0.text } }
  }
}
