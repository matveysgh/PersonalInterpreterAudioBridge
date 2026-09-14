import AppKit
import Foundation

private let driverName = "Personal Interpreter Mic.driver"
private let destinationDirectory = "/Library/Audio/Plug-Ins/HAL"

private func shellQuote(_ value: String) -> String {
    "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
}

private func appleScriptQuote(_ value: String) -> String {
    value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
}

private func showAlert(title: String, message: String, style: NSAlert.Style) {
    let alert = NSAlert()
    alert.alertStyle = style
    alert.messageText = title
    alert.informativeText = message
    alert.addButton(withTitle: "OK")
    NSApp.activate(ignoringOtherApps: true)
    alert.runModal()
}

NSApplication.shared.setActivationPolicy(.accessory)

guard let source = Bundle.main.url(forResource: "Personal Interpreter Mic", withExtension: "driver") else {
    showAlert(
        title: "Installation failed",
        message: "The signed audio driver is missing from this installer. Download it again from the official release page.",
        style: .critical
    )
    exit(1)
}

let destination = URL(fileURLWithPath: destinationDirectory).appendingPathComponent(driverName).path
let command = [
    "/bin/mkdir -p \(shellQuote(destinationDirectory))",
    "/bin/rm -rf \(shellQuote(destination))",
    "/usr/bin/ditto \(shellQuote(source.path)) \(shellQuote(destination))",
    "/usr/sbin/chown -R root:wheel \(shellQuote(destination))",
    "/bin/chmod -R go-w \(shellQuote(destination))",
    "/usr/bin/killall coreaudiod >/dev/null 2>&1 || true"
].joined(separator: " && ")

let script = NSAppleScript(source: "do shell script \"\(appleScriptQuote(command))\" with administrator privileges")
var error: NSDictionary?
script?.executeAndReturnError(&error)

if let error {
    let message = (error[NSAppleScript.errorMessage] as? String) ?? "Administrator authorization was cancelled or macOS rejected the installation."
    showAlert(title: "Installation failed", message: message, style: .critical)
    exit(1)
}

showAlert(
    title: "Personal Interpreter Mic installed",
    message: "Restart the calling application, then select Personal Interpreter Mic as its microphone. Personal Interpreter will detect it automatically.",
    style: .informational
)
