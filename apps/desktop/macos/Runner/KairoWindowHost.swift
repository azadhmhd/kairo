import Cocoa
import FlutterMacOS

/// Creates and drives the windows Kairo asks for.
///
/// Each window runs its own `FlutterEngine` on its own Dart entrypoint, which
/// means its own isolate: two Kairo windows are two Dart programs that happen to
/// share a process. Nothing is shared between them except what crosses this
/// bridge.
///
/// Only public, non-experimental embedder API is used here — `FlutterEngine`,
/// `FlutterViewController` and `NSWindow`. Flutter's own multi-window API exists
/// in the SDK but is internal and unavailable on the stable channel; see
/// ADR-0005.
final class KairoWindowHost: NSObject, KairoNativeWindowApi {

  /// A window Kairo created, together with the engine drawing into it.
  private final class HostedWindow {
    let window: NSWindow
    let engine: FlutterEngine

    /// This window's isolate, as something to send messages to.
    let relay: KairoNativeRelay

    /// This window's isolate, as something that sends them.
    ///
    /// Held for as long as the window is, because it carries the identity the
    /// relay needs in order not to echo a message back to its sender.
    let endpoint: KairoRelayEndpoint

    init(
      window: NSWindow,
      engine: FlutterEngine,
      relay: KairoNativeRelay,
      endpoint: KairoRelayEndpoint
    ) {
      self.window = window
      self.engine = engine
      self.relay = relay
      self.endpoint = endpoint
    }
  }

  private var windows: [Int64: HostedWindow] = [:]

  /// Handles start at 1 so that 0 is never a valid window.
  private var nextHandle: Int64 = 1

  /// The handle standing for the isolate the application launched into.
  ///
  /// It is not a window this host created, so it has no handle of its own, but
  /// the relay still has to be able to tell it apart from the ones that do.
  fileprivate static let mainIsolate: Int64 = 0

  private let events: KairoNativeWindowEvents

  /// The main isolate, as something to send messages to.
  private let mainRelay: KairoNativeRelay

  /// The main isolate, as something that sends them.
  private var mainEndpoint: KairoRelayEndpoint?

  /// Kept alive for as long as the application runs.
  ///
  /// The host owns every window and engine Kairo created; if it were collected,
  /// they would go with it.
  private static var shared: KairoWindowHost?

  private init(binaryMessenger: FlutterBinaryMessenger) {
    self.events = KairoNativeWindowEvents(binaryMessenger: binaryMessenger)
    self.mainRelay = KairoNativeRelay(binaryMessenger: binaryMessenger)
    super.init()
  }

  /// Attaches the host to the main window's engine.
  ///
  /// Called once, from `MainFlutterWindow`.
  static func register(with binaryMessenger: FlutterBinaryMessenger) {
    let host = KairoWindowHost(binaryMessenger: binaryMessenger)
    KairoNativeWindowApiSetup.setUp(binaryMessenger: binaryMessenger, api: host)

    // The main isolate's end of the relay. Every engine gets its own, because
    // the endpoint is what tells the host which isolate a message came from —
    // a Pigeon handler is not told which messenger it was called through.
    let endpoint = KairoRelayEndpoint(sender: mainIsolate, host: host)
    KairoNativeRelayApiSetup.setUp(binaryMessenger: binaryMessenger, api: endpoint)
    host.mainEndpoint = endpoint

    shared = host
  }

  /// Passes `message` to every Kairo isolate except `sender`.
  fileprivate func deliver(_ message: String, from sender: Int64) {
    if sender != Self.mainIsolate {
      mainRelay.onMessage(message: message) { _ in }
    }
    for (handle, hosted) in windows where handle != sender {
      hosted.relay.onMessage(message: message) { _ in }
    }
  }

  // MARK: - KairoNativeWindowApi

  func createWindow(
    spec: KairoNativeWindowSpec,
    completion: @escaping (Result<Int64, Error>) -> Void
  ) {
    // Headless execution must be allowed, even though this engine ends up with
    // a view. The engine has to be running before a FlutterViewController can
    // be built around it, and for the moment in between it has no view at all —
    // which is precisely what the embedder refuses to do when this is false.
    let engine = FlutterEngine(
      name: "kairo.\(spec.entrypoint).\(nextHandle)",
      project: nil,
      allowHeadlessExecution: true
    )

    guard engine.run(withEntrypoint: spec.entrypoint) else {
      completion(.failure(
        PigeonError(
          code: "entrypoint-failed",
          message: "The Dart entrypoint '\(spec.entrypoint)' did not start.",
          details: "It must be a top-level function annotated @pragma('vm:entry-point')."
        )
      ))
      return
    }

    let handle = nextHandle
    nextHandle += 1

    // Attached to the new engine before its Dart code can have anything to say.
    // The window's isolate reaches the rest of Kairo through this and nothing
    // else; without it, it can only draw.
    let relay = KairoNativeRelay(binaryMessenger: engine.binaryMessenger)
    let endpoint = KairoRelayEndpoint(sender: handle, host: self)
    KairoNativeRelayApiSetup.setUp(
      binaryMessenger: engine.binaryMessenger,
      api: endpoint
    )

    let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    RegisterGeneratedPlugins(registry: controller)

    let contentRect = Self.frame(for: spec)

    // A panel rather than a plain window, and this is not a detail. Every
    // window Kairo creates is an overlay: it appears above whatever the user is
    // working in without taking the keyboard from it. That is what a
    // non-activating panel is for, and it is the only window kind macOS will
    // carry onto another application's full screen space. A plain NSWindow at
    // the same level, with the same collection behaviour, stays on the desktop
    // it was created on — which is a character nobody working full screen ever
    // sees.
    let window = NSPanel(
      contentRect: contentRect,
      styleMask: Self.styleMask(for: spec),
      backing: .buffered,
      defer: false
    )

    // Panels hide themselves when their application is deactivated, and Kairo
    // is deactivated nearly always — it never asks for focus. Left alone this
    // would hide the character the instant it appeared.
    window.hidesOnDeactivate = false

    window.contentViewController = controller

    // Restored, because setting `contentViewController` resizes the window
    // around the view's fitting size — and a Flutter view that has not laid
    // itself out yet does not have one. The window collapses, which looks
    // exactly like a window that never opened. `MainFlutterWindow` saves and
    // restores its frame across the same assignment, for the same reason.
    window.setFrame(window.frameRect(forContentRect: contentRect), display: true)

    window.title = spec.title
    window.level = Self.level(for: spec.level)
    window.ignoresMouseEvents = spec.ignoresMouseEvents
    window.isReleasedWhenClosed = false
    window.delegate = self

    if spec.transparent {
      // All three are needed. An opaque window paints its background before
      // Flutter draws, a coloured backing shows through wherever Flutter's
      // pixels are transparent, and a shadow traces the window's rectangle
      // even when nothing is drawn in it.
      window.isOpaque = false
      window.backgroundColor = .clear
      window.hasShadow = false
      controller.backgroundColor = .clear
    }

    if spec.skipTaskbar {
      window.isExcludedFromWindowsMenu = true

      // What makes the character follow the user rather than belong to the
      // desktop it was created on:
      //
      //   canJoinAllSpaces    — appears on every desktop, not just its own
      //   ignoresCycle        — never offered by the window switcher
      //   fullScreenAuxiliary — permitted onto a full screen space
      //
      // `stationary` was here and was the reason the character never reached a
      // full screen space. Apple describes it as keeping the window "visible
      // and stationary, like the desktop window", and the desktop is precisely
      // the thing that does not follow the user into full screen. It overrode
      // `canJoinAllSpaces` rather than complementing it.
      //
      // `canJoinAllApplications` reads like the right flag for this and is not:
      // adding it stopped the window appearing anywhere at all. It belongs to
      // the same group as `primary` and `auxiliary`, and setting it alone
      // leaves the window in no group, which is not a state worth being in.
      window.collectionBehavior = [
        .canJoinAllSpaces,
        .ignoresCycle,
        .fullScreenAuxiliary,
      ]
    }

    if spec.x == nil || spec.y == nil {
      window.center()
    }

    windows[handle] = HostedWindow(
      window: window,
      engine: engine,
      relay: relay,
      endpoint: endpoint
    )

    completion(.success(handle))
  }

  func showWindow(handle: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    withWindow(handle, completion) { window in
      // Ordered front without taking focus. A character window that stole the
      // keyboard every time it appeared would interrupt the very work it is
      // meant to look after.
      window.orderFrontRegardless()
    }
  }

  func hideWindow(handle: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    withWindow(handle, completion) { window in
      window.orderOut(nil)
    }
  }

  func closeWindow(handle: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let hosted = windows[handle] else {
      completion(.failure(Self.unknownWindow(handle)))
      return
    }

    // Dropped from the table first, so the delegate callback that `close()`
    // triggers does not report a window Dart is already being told about.
    windows.removeValue(forKey: handle)
    hosted.window.delegate = nil
    hosted.window.close()
    hosted.engine.shutDownEngine()

    events.onWindowClosed(handle: handle) { _ in }
    completion(.success(()))
  }

  func focusWindow(handle: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    withWindow(handle, completion) { window in
      NSApp.activate(ignoringOtherApps: true)
      window.makeKeyAndOrderFront(nil)
    }
  }

  func setWindowBounds(
    handle: Int64,
    bounds: KairoNativeRect,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    withWindow(handle, completion) { window in
      window.setFrame(Self.toAppKit(bounds), display: true)
    }
  }

  func getWindowBounds(
    handle: Int64,
    completion: @escaping (Result<KairoNativeRect, Error>) -> Void
  ) {
    guard let hosted = windows[handle] else {
      completion(.failure(Self.unknownWindow(handle)))
      return
    }
    completion(.success(Self.fromAppKit(hosted.window.frame)))
  }

  func isWindowVisible(
    handle: Int64,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    guard let hosted = windows[handle] else {
      completion(.failure(Self.unknownWindow(handle)))
      return
    }
    completion(.success(hosted.window.isVisible))
  }

  func setWindowLevel(
    handle: Int64,
    level: KairoNativeWindowLevel,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    withWindow(handle, completion) { window in
      window.level = Self.level(for: level)
    }
  }

  func setIgnoresMouseEvents(
    handle: Int64,
    ignore: Bool,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    withWindow(handle, completion) { window in
      window.ignoresMouseEvents = ignore
    }
  }

  func activeDisplayBounds(
    completion: @escaping (Result<KairoNativeRect, Error>) -> Void
  ) {
    // `NSScreen.main` is the screen with the keyboard focus — where the user is
    // working — not the one AppKit measures coordinates from. `screens.first`
    // is the fallback for the moment during login when nothing has focus yet.
    guard let screen = NSScreen.main ?? NSScreen.screens.first else {
      completion(.failure(
        PigeonError(
          code: "no-display",
          message: "This machine reports no displays.",
          details: "There is nowhere to put a window."
        )
      ))
      return
    }
    completion(.success(Self.fromAppKit(screen.visibleFrame)))
  }

  // MARK: - Helpers

  private func withWindow(
    _ handle: Int64,
    _ completion: @escaping (Result<Void, Error>) -> Void,
    _ body: (NSWindow) -> Void
  ) {
    guard let hosted = windows[handle] else {
      completion(.failure(Self.unknownWindow(handle)))
      return
    }
    body(hosted.window)
    completion(.success(()))
  }

  private func handle(for window: NSWindow) -> Int64? {
    windows.first { $0.value.window === window }?.key
  }

  private static func unknownWindow(_ handle: Int64) -> PigeonError {
    PigeonError(
      code: "unknown-window",
      message: "There is no window with handle \(handle).",
      details: "It was either never created or has already been closed."
    )
  }

  /// Non-activating throughout: clicking one of Kairo's surfaces answers a
  /// reminder, and answering a reminder must never pull the user out of what
  /// they were doing to do it.
  private static func styleMask(for spec: KairoNativeWindowSpec) -> NSWindow.StyleMask {
    guard spec.decorated else {
      return [.borderless, .nonactivatingPanel]
    }
    var mask: NSWindow.StyleMask = [
      .titled, .closable, .miniaturizable, .nonactivatingPanel,
    ]
    if spec.resizable {
      mask.insert(.resizable)
    }
    return mask
  }

  private static func level(for level: KairoNativeWindowLevel) -> NSWindow.Level {
    switch level {
    case .normal:
      return .normal
    case .floating:
      // Deliberately not `NSWindow.Level.floating`, which clears ordinary
      // windows but not another application's full screen space — and a user
      // working full screen is exactly the user who has been sitting still too
      // long. This is the level notification banners arrive at, which is the
      // observable proof that it reaches over a full screen application.
      return .statusBar
    case .desktop:
      return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
    }
  }

  private static func frame(for spec: KairoNativeWindowSpec) -> NSRect {
    guard let x = spec.x, let y = spec.y else {
      // Position is irrelevant until `center()` runs; only the size matters.
      return NSRect(x: 0, y: 0, width: spec.width, height: spec.height)
    }
    return toAppKit(
      KairoNativeRect(x: x, y: y, width: spec.width, height: spec.height)
    )
  }

  /// Converts Kairo's top-left origin to AppKit's bottom-left one.
  ///
  /// Dart measures y downwards from the top of the screen, as every other part
  /// of Flutter does. AppKit measures it upwards from the bottom. Getting this
  /// wrong puts windows off-screen in a way that looks like they failed to open,
  /// so both directions go through here and nowhere else.
  private static func toAppKit(_ rect: KairoNativeRect) -> NSRect {
    NSRect(
      x: rect.x,
      y: screenHeight() - rect.y - rect.height,
      width: rect.width,
      height: rect.height
    )
  }

  private static func fromAppKit(_ frame: NSRect) -> KairoNativeRect {
    KairoNativeRect(
      x: frame.origin.x,
      y: screenHeight() - frame.origin.y - frame.height,
      width: frame.width,
      height: frame.height
    )
  }

  /// The height of the coordinate space both origins are measured in.
  ///
  /// `NSScreen.screens.first` is the screen containing the origin, which is what
  /// AppKit measures every window's position against — not `NSScreen.main`,
  /// which is wherever the keyboard focus happens to be.
  private static func screenHeight() -> CGFloat {
    NSScreen.screens.first?.frame.height ?? 0
  }
}

// MARK: - Relay

/// One isolate's end of the relay.
///
/// A Pigeon handler is not told which messenger it was called through, so the
/// only way to know who is speaking is to give each isolate an endpoint of its
/// own that already knows. That is this class's entire reason to exist, and why
/// there is one per engine rather than one per application.
final class KairoRelayEndpoint: NSObject, KairoNativeRelayApi {

  private let sender: Int64

  /// Weak, because the host owns every endpoint but the main one, and an
  /// endpoint that owned the host back would keep the whole graph alive.
  private weak var host: KairoWindowHost?

  fileprivate init(sender: Int64, host: KairoWindowHost) {
    self.sender = sender
    self.host = host
    super.init()
  }

  func relay(message: String, completion: @escaping (Result<Void, Error>) -> Void) {
    host?.deliver(message, from: sender)
    completion(.success(()))
  }
}

// MARK: - NSWindowDelegate

extension KairoWindowHost: NSWindowDelegate {
  func windowWillClose(_ notification: Notification) {
    guard
      let window = notification.object as? NSWindow,
      let handle = handle(for: window)
    else {
      return
    }

    // The user closed it, rather than Dart asking. Tell Dart, and take the
    // engine down with the window it was drawing into.
    windows[handle]?.engine.shutDownEngine()
    windows.removeValue(forKey: handle)
    events.onWindowClosed(handle: handle) { _ in }
  }

  func windowDidBecomeKey(_ notification: Notification) {
    reportFocus(notification, focused: true)
  }

  func windowDidResignKey(_ notification: Notification) {
    reportFocus(notification, focused: false)
  }

  func windowDidMove(_ notification: Notification) {
    reportBounds(notification)
  }

  func windowDidResize(_ notification: Notification) {
    reportBounds(notification)
  }

  private func reportFocus(_ notification: Notification, focused: Bool) {
    guard
      let window = notification.object as? NSWindow,
      let handle = handle(for: window)
    else {
      return
    }
    events.onWindowFocusChanged(handle: handle, focused: focused) { _ in }
  }

  private func reportBounds(_ notification: Notification) {
    guard
      let window = notification.object as? NSWindow,
      let handle = handle(for: window)
    else {
      return
    }
    events.onWindowMoved(
      handle: handle,
      bounds: KairoWindowHost.fromAppKit(window.frame)
    ) { _ in }
  }
}
