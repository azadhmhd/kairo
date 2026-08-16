import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()

    RegisterGeneratedPlugins(registry: flutterViewController)

    KairoWindowHost.register(with: flutterViewController.engine.binaryMessenger)
    KairoSystemHost.register(with: flutterViewController.engine.binaryMessenger)

    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.delegate = self

    super.awakeFromNib()
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    orderOut(nil)
    return false
  }
}
