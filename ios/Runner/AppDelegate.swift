import Flutter
import UIKit
import VisionKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var scannerResult: FlutterResult?
  private var scannedImagePaths: [String] = []

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(name: "com.benopdf.scan/scanner", binaryMessenger: engineBridge.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      if call.method == "scanDocument" {
        self?.scannerResult = result
        self?.presentDocumentCamera()
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func presentDocumentCamera() {
    guard VNDocumentCameraViewController.isSupported else {
      scannerResult?([])
      scannerResult = nil
      return
    }
    let vc = VNDocumentCameraViewController()
    vc.delegate = self
    if let root = window?.rootViewController {
      var top = root
      while let presented = top.presentedViewController { top = presented }
      top.present(vc, animated: true)
    }
  }
}

extension AppDelegate: VNDocumentCameraViewControllerDelegate {
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    scannedImagePaths.removeAll()
    let tmp = FileManager.default.temporaryDirectory
    for i in 0..<scan.pageCount {
      let image = scan.imageOfPage(at: i)
      if let data = image.jpegData(compressionQuality: 0.9) {
        let url = tmp.appendingPathComponent("scan_\(DateTime.now)_\(i).jpg")
        try? data.write(to: url)
        scannedImagePaths.append(url.path)
      }
    }
    controller.dismiss(animated: true) { [weak self] in
      self?.scannerResult?(self?.scannedImagePaths ?? [])
      self?.scannerResult = nil
    }
  }

  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    controller.dismiss(animated: true) { [weak self] in
      self?.scannerResult?([])
      self?.scannerResult = nil
    }
  }

  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    controller.dismiss(animated: true) { [weak self] in
      self?.scannerResult?(FlutterError(code: "SCAN_FAILED", message: error.localizedDescription, details: nil))
      self?.scannerResult = nil
    }
  }
}

private extension Date {
  static var now: String { "\(Int(Date().timeIntervalSince1970 * 1000))" }
}
