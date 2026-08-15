import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Attached before the controller becomes the window's content, because that
    // is what puts the view on screen and starts the engine running Dart.
    // `bootstrap` opens the character window during startup, and a call that
    // arrived before this line would find no handler waiting for it.
    KairoWindowHost.register(with: flutterViewController.engine.binaryMessenger)
    KairoSystemHost.register(with: flutterViewController.engine.binaryMessenger)

    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.delegate = self

    super.awakeFromNib()
  }

  /// Closing the dashboard hides it rather than ending Kairo.
  ///
  /// This window holds the engine every service in the application runs on —
  /// the scheduler, the reminders, the database, the character. Letting the red
  /// button tear all of that down would mean the user closing a window and
  /// silently switching off the thing they installed Kairo for. It goes away;
  /// Kairo keeps working, and the menu bar brings it back.
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    orderOut(nil)
    KairoStatusItem.dashboardClosed()
    return false
  }
}
