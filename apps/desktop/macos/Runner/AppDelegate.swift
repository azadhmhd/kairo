import Cocoa
import FlutterMacOS
import ServiceManagement

@main
class AppDelegate: FlutterAppDelegate {

  private let statusItem = KairoStatusItem()

  override func applicationShouldTerminateAfterLastWindowClosed(
    _ sender: NSApplication
  ) -> Bool {
    return false
  }

  override func applicationShouldHandleReopen(
    _ sender: NSApplication,
    hasVisibleWindows flag: Bool
  ) -> Bool {
    KairoStatusItem.showDashboard()
    return true
  }

  override func applicationSupportsSecureRestorableState(
    _ app: NSApplication
  ) -> Bool {
    return true
  }
}

/// Whether the system starts Kairo when the user logs in.
final class KairoSystemHost: NSObject, KairoNativeSystemApi {

  private static var shared: KairoSystemHost?

  static func register(with binaryMessenger: FlutterBinaryMessenger) {
    let host = KairoSystemHost()
    KairoNativeSystemApiSetup.setUp(binaryMessenger: binaryMessenger, api: host)
    shared = host
  }

  func launchesAtLogin(completion: @escaping (Result<Bool, Error>) -> Void) {
    guard #available(macOS 13.0, *) else {
      completion(.success(false))
      return
    }
    completion(.success(SMAppService.mainApp.status == .enabled))
  }

  func setLaunchAtLogin(
    enabled: Bool,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard #available(macOS 13.0, *) else {
      completion(.failure(
        PigeonError(
          code: "unsupported",
          message: "Login items need macOS 13 or later.",
          details: "SMAppService is unavailable on this system."
        )
      ))
      return
    }

    do {
      // register throws when already registered, unregister when already gone;
      // both mean the requested end state already holds.
      if enabled {
        if SMAppService.mainApp.status != .enabled {
          try SMAppService.mainApp.register()
        }
      } else {
        if SMAppService.mainApp.status == .enabled {
          try SMAppService.mainApp.unregister()
        }
      }
      completion(.success(()))
    } catch {
      completion(.failure(error))
    }
  }
}

/// Kairo's menu bar icon, and the menu behind it.
final class KairoStatusItem: NSObject {

  private let item: NSStatusItem

  override init() {
    item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    super.init()

    item.button?.image = Self.icon()
    item.button?.toolTip = "Kairo"

    let menu = NSMenu()
    menu.addItem(
      withTitle: "Open Dashboard",
      action: #selector(openDashboard),
      keyEquivalent: ""
    ).target = self
    menu.addItem(.separator())
    menu.addItem(
      withTitle: "Quit Kairo",
      action: #selector(quit),
      keyEquivalent: "q"
    ).target = self

    item.menu = menu
  }

  static func showDashboard() {
    guard
      let window = NSApp.windows.first(where: { $0 is MainFlutterWindow })
    else {
      return
    }

    NSApp.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)
  }

  @objc private func openDashboard() {
    Self.showDashboard()
  }

  @objc private func quit() {
    NSApp.terminate(nil)
  }

  private static func icon() -> NSImage {
    if #available(macOS 11.0, *),
      let symbol = NSImage(
        systemSymbolName: "leaf.fill",
        accessibilityDescription: "Kairo"
      )
    {
      symbol.isTemplate = true
      return symbol
    }

    let fallback = NSImage(
      size: NSSize(width: 16, height: 16),
      flipped: false
    ) { rect in
      NSColor.black.setFill()
      NSBezierPath(ovalIn: rect.insetBy(dx: 3, dy: 3)).fill()
      return true
    }
    fallback.isTemplate = true
    return fallback
  }
}
