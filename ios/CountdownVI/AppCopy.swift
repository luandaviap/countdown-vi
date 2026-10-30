import Foundation

/// Every user-facing string of the main screen, in one place so the copy is easy to change (D-015).
enum AppCopy {
    static let title = "Esperando por Leonida"
    static let subtitle = "Dias para viajar para Leonida"
    static let released = "Disponível agora"
    static let provisionalDate = "Data provisória"

    static let unitDays = "Dias"
    static let unitHours = "Horas"
    static let unitMinutes = "Minutos"
    static let unitSeconds = "Segundos"

    static let startLiveActivity = "Ativar Live Activity"
    static let startLiveActivityHint = "Mostra a contagem na Tela Bloqueada e na Dynamic Island"
    static let notifyMilestones = "Avisar nos marcos"
    static let notifyMilestonesHint = "Receba avisos conforme o lançamento se aproxima"
    static let notificationsDenied = "Avisos desativados. Ativar nos Ajustes"
    static let notificationsDeniedHint = "Abre os Ajustes do app"

    static func progressLabel(windowDays: Int) -> String {
        "Progresso dos últimos \(windowDays) dias até o lançamento"
    }

    static func progressValue(percent: Int) -> String {
        "\(percent)%"
    }

    /// VoiceOver text for the countdown. Seconds are left out so it does not churn every tick.
    static func timeLeft(days: Int, hours: Int, minutes: Int) -> String {
        let daysText = plural(days, "dia", "dias")
        let hoursText = plural(hours, "hora", "horas")
        let minutesText = plural(minutes, "minuto", "minutos")
        return "Faltam \(daysText), \(hoursText) e \(minutesText) para o lançamento"
    }

    private static func plural(_ count: Int, _ singular: String, _ plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }
}
