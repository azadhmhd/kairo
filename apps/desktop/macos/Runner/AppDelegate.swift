import Cocoa
import FlutterMacOS
import ServiceManagement

@main
class AppDelegate: FlutterAppDelegate {

  /// Kairo's presence in the menu bar, for as long as the application runs.
  ///
  /// Created here rather than lazily, because it is the only thing on screen
  /// once the dashboard is closed and there would be no way back in without it.
  private let statusItem = KairoStatusItem()

  /// Closing the dashboard does not end Kairo.
  ///
  /// The reminders are the product and they need no window open to work. Kairo
  /// goes on keeping time with nothing showing but the menu bar icon, which is
  /// what a companion is for — an application the user has to leave a window
  /// open for is an application they will close and forget.
  override func applicationShouldTerminateAfterLastWindowClosed(
    _ sender: NSApplication
  ) -> Bool {
    return false
  }

  /// Clicking the dock icon brings the dashboard back.
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
///
/// A companion that has to be started by hand is a companion that is running on
/// the days the user remembered and absent on the days they did not, which is
/// the wrong way round: the days you forget to look after yourself are the days
/// the reminders are worth having.
final class KairoSystemHost: NSObject, KairoNativeSystemApi {

  /// Held for as long as the application runs; Pigeon keeps only a reference
  /// inside its channel handler.
  private static var shared: KairoSystemHost?

  /// Attaches the host to the main window's engine. Called once.
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
      // `register` throws if it is already registered, and `unregister` if it
      // is already gone. Both mean the system is in the state being asked for,
      // which is not a failure — the caller wanted an end state, not an event.
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

/// Kairo in the menu bar: an icon that is always there, a way back to the
/// dashboard, and a way to stop.
///
/// This is the whole of Kairo's interface while it is working. Everything else
/// — the dashboard, the character, the reminders themselves — comes and goes,
/// and this does not.
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

  /// Brings the dashboard forward, whether it was hidden or merely behind
  /// something.
  ///
  /// The window is never destroyed — closing it only orders it out — so there
  /// is always one to show, and showing it costs nothing beyond a frame.
  static func showDashboard() {
    guard
      let window = NSApp.windows.first(where: { $0 is MainFlutterWindow })
    else {
      return
    }

    // The dock icon exists only while the dashboard does. Kairo spends nearly
    // all of its life with no window open, and an application permanently in
    // the dock that cannot be clicked into anything is clutter — the menu bar
    // is where a background application belongs. `regular` has to be set before
    // activating, or the icon appears without the application coming forward.
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)
  }

  /// Gives up the dock icon, leaving Kairo in the menu bar alone.
  static func dashboardClosed() {
    NSApp.setActivationPolicy(.accessory)
  }

  @objc private func openDashboard() {
    Self.showDashboard()
  }

  @objc private func quit() {
    NSApp.terminate(nil)
  }

  /// The menu bar icon.
  ///
  /// A template image, so the system draws it in whatever colour the menu bar
  /// currently needs — light, dark, and the inverted state while the menu is
  /// open — rather than Kairo guessing at three of them.
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

    // Older macOS has no symbol library to ask. A soft dot is not the mark, but
    // it is unmistakably something, and the menu bar renders it correctly.
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
