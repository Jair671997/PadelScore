
import SwiftUI

struct MatchState {
    var points = [0, 0]
    var games = [0, 0]
    var sets = [0, 0]
    var setHistory: [String] = []
}

@main
struct PadelScoreApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var match = MatchState()
    @State private var undoStack: [MatchState] = []
    @State private var message = "Partido listo"

    private let pointLabels = ["0", "15", "30", "40"]

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("PADELSCORE")
                    .font(.headline)
                    .foregroundStyle(.green)

                Text("SET \(match.sets[0] + match.sets[1] + 1)")
                    .font(.caption)

                Text("SETS \(match.sets[0]) - \(match.sets[1])")
                    .font(.caption2)

                HStack(spacing: 8) {
                    teamColumn(0, name: "NOSOTROS")
                    teamColumn(1, name: "RIVALES")
                }

                Text(message)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.green)

                Button("↩ Deshacer") {
                    undo()
                }
                .tint(.orange)
                .disabled(undoStack.isEmpty)

                Button("Reiniciar partido", role: .destructive) {
                    match = MatchState()
                    undoStack.removeAll()
                    message = "Partido listo"
                }

                if !match.setHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HISTORIAL")
                            .font(.caption.bold())

                        ForEach(
                            Array(match.setHistory.enumerated()),
                            id: \.offset
                        ) { index, result in
                            Text("Set \(index + 1): \(result)")
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
    }

    private func teamColumn(
        _ team: Int,
        name: String
    ) -> some View {
        VStack(spacing: 7) {
            Text(name)
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(pointLabel(team))
                .font(.system(size: 30, weight: .bold))
                .monospacedDigit()

            Text("Juegos \(match.games[team])")
                .font(.caption2)

            Button("+ Punto") {
                addPoint(team)
            }
            .tint(.green)
        }
        .frame(maxWidth: .infinity)
    }

    private func pointLabel(_ team: Int) -> String {
        let own = match.points[team]
        let other = match.points[1 - team]

        if own >= 3 && other >= 3 {
            if own == other { return "40" }
            return own > other ? "AD" : "40"
        }

        return pointLabels[min(own, 3)]
    }

    private func addPoint(_ team: Int) {
        undoStack.append(match)

        match.points[team] += 1

        // Juego: al menos 4 puntos y 2 de diferencia.
        if match.points[team] >= 4 &&
            match.points[team] - match.points[1 - team] >= 2 {

            match.games[team] += 1
            match.points = [0, 0]

            // Set: al menos 6 juegos y 2 de diferencia.
            if match.games[team] >= 6 &&
                match.games[team] - match.games[1 - team] >= 2 {

                let result = "\(match.games[0])-\(match.games[1])"
                match.setHistory.append(result)
                match.sets[team] += 1
                match.games = [0, 0]

                message = "¡Set \(result) para \(team == 0 ? "nosotros" : "los rivales")!"
            } else {
                message = "¡Juego para \(team == 0 ? "nosotros" : "los rivales")!"
            }
        } else {
            message = "Punto añadido"
        }
    }

    private func undo() {
        guard let previous = undoStack.popLast() else { return }
        match = previous
        message = "Último punto deshecho"
    }
}
