// TODO(remover-diagnostico): temporary on-device diagnostics for T-027. Delete this file and its
// line in CountdownView once the widget / Live Activity issue is understood.
import ActivityKit
import Foundation

@MainActor
enum DiagnosticsInfo {
    static func summary() -> String {
        let info = Bundle.main.infoDictionary ?? [:]
        let version = info["CFBundleShortVersionString"] as? String ?? "?"
        let build = info["CFBundleVersion"] as? String ?? "?"
        let appID = Bundle.main.bundleIdentifier ?? "?"

        let activities = Activity<CountdownActivityAttributes>.activities
        let active = activities.filter { $0.activityState == .active }.count
        let stale = activities.filter { $0.activityState == .stale }.count
        let enabled = ActivityAuthorizationInfo().areActivitiesEnabled

        return """
        v\(version) (\(build)) · \(appID) · \(signatureSummary(Bundle.main.bundleURL))
        LA permitidas: \(enabled ? "sim" : "não") · activities: \(active) active, \(stale) stale, \(activities.count) total
        LA última ação: \(LiveActivityController.lastAction)
        LA último erro: \(LiveActivityController.lastError ?? "nenhum")
        extensões: \(extensionsSummary(appID: appID))
        """
    }

    /// Bundle ID of each embedded extension, whether it keeps the app's prefix, and its signature,
    /// so a missing or badly re-signed widget extension shows up on screen.
    private static func extensionsSummary(appID: String) -> String {
        guard let pluginsURL = Bundle.main.builtInPlugInsURL,
              let items = try? FileManager.default.contentsOfDirectory(at: pluginsURL, includingPropertiesForKeys: nil),
              !items.isEmpty
        else { return "nenhuma (PlugIns vazio)" }

        return items.map { url in
            let id = Bundle(url: url)?.bundleIdentifier ?? url.lastPathComponent
            let prefix = id.hasPrefix(appID + ".") ? "prefixo ok" : "PREFIXO ERRADO"
            return "\(id) [\(prefix), \(signatureSummary(url))]"
        }
        .joined(separator: "; ")
    }

    private static func signatureSummary(_ bundleURL: URL) -> String {
        let fileManager = FileManager.default
        let signed = fileManager.fileExists(atPath: bundleURL.appendingPathComponent("_CodeSignature").path)
        let profile = fileManager.fileExists(atPath: bundleURL.appendingPathComponent("embedded.mobileprovision").path)
        return "assinatura \(signed ? "sim" : "NÃO"), perfil \(profile ? "sim" : "não")"
    }
}
