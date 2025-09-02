import SwiftUI

struct ContentView: View {
    @State private var selectedIndex: Int = 0
    // Adjustable top padding for the menu bar
    var menuBarTopPadding: CGFloat {
        #if os(iOS)
        return isPad ? 20 : 6
        #else
        return 12
        #endif
    }

    var isPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }

    var body: some View {
        VStack {
            HStack(spacing: isPad ? 15 : 5) {
                Button(action: { selectedIndex = 0 }) {
                    Label("Schule", systemImage: "house")
                }
                Button(action: { selectedIndex = 1 }) {
                    Label("Notizen", systemImage: "star")
                }
                Button(action: { selectedIndex = 2 }) {
                    Label("Stundenplan", systemImage: "gear")
                }
                Button(action: { selectedIndex = 3 }) {
                    Label("Taschenrechner", systemImage: "function")
                }
            }
            .padding(.vertical, isPad ? 16 : 8)
            .padding(.horizontal, isPad ? 60 : 30)
            .background(Color.gray.opacity(0.2))
            .clipShape(Capsule())
            .padding(.top, menuBarTopPadding) // Use adjustable property
            .padding(.horizontal, isPad ? 32 : 16)
            #if os(iOS)
            .font(isPad ? .title2 : .footnote)
            #endif
            #if os(macOS)
            .font(.body)
            #endif

            Spacer()

            ScrollView {
                Group {
                    if selectedIndex == 0 {
                        Text("Seite 1")
                    } else if selectedIndex == 1 {
                        Text("Seite 2")
                    } else if selectedIndex == 2 {
                        Text("Seite 3")
                    } else if selectedIndex == 3 {
                        CalculatorView(isPad: isPad)
                    }
                }
                .font(isPad ? .system(size: 48) : .largeTitle)
                .padding(isPad ? 32 : 16)
            }

            Spacer()
        }
    }
}

struct CalculatorView: View {
    @State private var input: String = ""
    @State private var result: String = ""
    var isPad: Bool = false
    // Adjustable button size for iOS
    var buttonSize: CGFloat {
        #if os(iOS)
        return isPad ? 88 : 64 // Change 64 to your preferred size
        #else
        return isPad ? 88 : 44
        #endif
    }

    var buttons: [[String]] {
        #if os(macOS)
        return [
            ["1", "2", "3", "/"],
            ["4", "5", "6", "C"],
            ["7", "8", "9", "*"],
            ["" , "", "0", "=", "", ""]
        ]
        #else
        return [
            ["1", "2", "3", "+"],
            ["4", "5", "6", "-"],
            ["7", "8", "9", "*"],
            ["0", "/", "C", "="]
        ]
        #endif
    }

    var body: some View {
        VStack(spacing: isPad ? 32 : 16) {
            TextField("Eingabe", text: $input)
                .disabled(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.trailing)
            if !result.isEmpty {
                Text("Ergebnis: \(result)")
                    .font(isPad ? .title2 : .headline)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: isPad ? 24 : 12) {
                    ForEach(row, id: \.self) { symbol in
                        if symbol.isEmpty {
                            Spacer()
                        } else {
                            Button(symbol) {
                                buttonAction(symbol)
                            }
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(isPad ? 16 : 10)
                        }
                    }
                }
            }
        }
        .padding(isPad ? 32 : 16)
        .font(isPad ? .title2 : .body)
    }

    func buttonAction(_ symbol: String) {
        switch symbol {
        case "=":
            let exp = NSExpression(format: input)
            if let value = exp.expressionValue(with: nil, context: nil) as? NSNumber {
                result = "\(value)"
            } else {
                result = "Fehler"
            }
        case "C":
            input = ""
            result = ""
        default:
            result = ""
            input += symbol
        }
    }
}

#Preview {
    ContentView()
}
