import SwiftUI

struct ContentView: View {
    // Liste der Menüpunkte mit Beschriftungen und Icon-Namen
    let menuItems: [(label: String, icon: String)] = [
        ("Schule", "house"),
        ("Notizen", "star"),
        ("Stundenplan", "gear"),
        ("Taschenrechner", "function"),
        ("Einstellungen", "slider.horizontal.3")
    ]
    
    // Zustandsvariablen für die Benutzeroberfläche
    @State private var selectedIndex: Int = 0
    @AppStorage("menuBarScale") private var menuBarScaleRaw: Double = 1.0
    @AppStorage("iconOnlyThreshold") private var iconOnlyThresholdRaw: Double = 800
    @AppStorage("menuBarShrinkFactor") private var menuBarShrinkFactorRaw: Double = 1.0
    @AppStorage("iconOnlySize") private var iconOnlySizeRaw: Double = 28.0

    // Fügt einen Namespace hinzu, um die Geometrie für die Animation zu verfolgen
    @Namespace private var namespace

    // Computed Properties für die Skalierung
    var menuBarScale: CGFloat { CGFloat(menuBarScaleRaw) }
    var iconOnlyThreshold: CGFloat { CGFloat(iconOnlyThresholdRaw) }
    var menuBarShrinkFactor: CGFloat { CGFloat(menuBarShrinkFactorRaw) }
    var iconOnlySize: CGFloat { CGFloat(iconOnlySizeRaw) }

    // Bestimmt, ob es sich um ein iPad handelt
    var isPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                let w = geo.size.width
                let baseFontSize = isPad ? 32 : 20
                let baseHPad = isPad ? 60 : 30
                let baseWidth: CGFloat = 800
                
                let shrink = pow(max(w, 1) / baseWidth, menuBarShrinkFactor)
                let fontSize = max(min(shrink * menuBarScale * CGFloat(baseFontSize), CGFloat(baseFontSize * 2)), 12)
                let hPad = max(min(shrink * menuBarScale * CGFloat(baseHPad), CGFloat(baseHPad * 2)), 8)
                let showText = w > iconOnlyThreshold

                HStack(spacing: isPad ? fontSize : fontSize / 2) {
                    ForEach(menuItems.indices, id: \.self) { idx in
                        Button(action: {
                            withAnimation {
                                selectedIndex = idx
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: menuItems[idx].icon)
                                    .font(.system(size: showText ? fontSize : iconOnlySize))
                                if showText {
                                    Text(menuItems[idx].label)
                                }
                            }
                            .padding(.vertical, showText ? 8 : 4)
                            .padding(.horizontal, showText ? 12 : 8)
                            .animation(showText ? .easeIn(duration: 0.3) : .easeOut(duration: 0.3), value: showText)
                            // Fügt den animierten Hintergrund nur dem ausgewählten Button hinzu
                            .background(
                                ZStack {
                                    if selectedIndex == idx {
                                        if #available(iOS 26.0, *) {
                                            Capsule()
                                                .fill(Color.white.opacity(0.4))
                                                .matchedGeometryEffect(id: "selectedTab", in: namespace, isSource: true)
                                                .glassEffect(in: Capsule())
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, fontSize / 2)
                .padding(.horizontal, hPad)
                .background(Capsule().fill(Color.gray.opacity(0.2)))
                .font(showText ? .system(size: fontSize) : .none)
                .frame(maxWidth: .infinity, alignment: .center)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let buttonWidth = (geo.size.width - hPad * 2 - CGFloat(menuItems.count - 1) * (isPad ? fontSize : fontSize / 2)) / CGFloat(menuItems.count)
                            let newIndex = Int(value.location.x / (buttonWidth + (isPad ? fontSize : fontSize / 2)))
                            if newIndex >= 0 && newIndex < menuItems.count {
                                withAnimation {
                                    selectedIndex = newIndex
                                }
                            }
                        }
                )
            }
            .frame(height: isPad ? 64 : 44)
            .animation(.easeOut(duration: 0.3), value: menuBarShrinkFactorRaw)

            // Hauptinhaltsbereich der App
            GeometryReader { geometry in
                ScrollView {
                    Group {
                        if selectedIndex == 0 {
                            Text("Seite 1")
                        } else if selectedIndex == 1 {
                            Text("Seite 2")
                        } else if selectedIndex == 2 {
                            Text("Seite 3")
                        } else if selectedIndex == 3 {
                            CalculatorView(
                                isPad: isPad,
                                availableWidth: geometry.size.width,
                                availableHeight: geometry.size.height
                            )
                        } else if selectedIndex == 4 {
                            VStack(spacing: 24) {
                                Text("Menüleisten-Größe")
                                    .font(.title2)
                                Slider(value: $menuBarScaleRaw, in: 0.5...2.0, step: 0.01)
                                Text(String(format: "Skalierung: %.2f", menuBarScale))
                                    .font(.body)
                                Divider()
                                Text("Icon-Only Schwelle (px)")
                                    .font(.title2)
                                Slider(value: $iconOnlyThresholdRaw, in: 200...1200, step: 1)
                                Text("Schwelle: \(Int(iconOnlyThreshold)) px")
                                    .font(.body)
                                Divider()
                                Text("Verkleinerungsfaktor")
                                    .font(.title2)
                                Slider(value: $menuBarShrinkFactorRaw, in: 0.5...1.5, step: 0.01)
                                Text(String(format: "Faktor: %.2f", menuBarShrinkFactor))
                                    .font(.body)
                                Divider()
                                Text("Icon-Größe (Icon-Only)")
                                    .font(.title2)
                                Slider(value: $iconOnlySizeRaw, in: 16...64, step: 1)
                                Text("Größe: \(Int(iconOnlySize)) pt")
                                    .font(.body)
                            }
                            .padding(isPad ? 32 : 16)
                            .frame(maxWidth: 400)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                    }
                    .font(isPad ? .system(size: 48) : .largeTitle)
                    .padding(isPad ? 32 : 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CalculatorView: View {
    @State private var input: String = ""
    @State private var result: String = ""
    var isPad: Bool = false
    var availableWidth: CGFloat
    var availableHeight: CGFloat

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
        let buttonRows = buttons.count
        let buttonCols = buttons[0].count
        let spacingV: CGFloat = isPad ? 32 : 16
        let spacingH: CGFloat = isPad ? 24 : 12
        let totalSpacingV = CGFloat(buttonRows - 1) * spacingV
        let totalSpacingH = CGFloat(buttonCols - 1) * spacingH

        // Set reasonable max/min button sizes
        let maxButtonWidth: CGFloat = isPad ? 88 : 64
        let maxButtonHeight: CGFloat = isPad ? 88 : 64
        let minButtonWidth: CGFloat = 44
        let minButtonHeight: CGFloat = 44

        let rawButtonWidth = (availableWidth - totalSpacingH) / CGFloat(buttonCols)
        let rawButtonHeight = (availableHeight - totalSpacingV - (isPad ? 120 : 80)) / CGFloat(buttonRows)
        let buttonWidth = min(max(rawButtonWidth, minButtonWidth), maxButtonWidth)
        let buttonHeight = min(max(rawButtonHeight, minButtonHeight), maxButtonHeight)

        VStack(spacing: spacingV) {
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
                HStack(spacing: spacingH) {
                    ForEach(row, id: \.self) { symbol in
                        if symbol.isEmpty {
                            Spacer()
                        } else {
                            Button(symbol) {
                                buttonAction(symbol)
                            }
                            .frame(width: buttonWidth, height: buttonHeight)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(isPad ? 16 : 10)
                        }
                    }
                }
            }
        }
        .padding(isPad ? 32 : 16)
        .font(isPad ? .title2 : .body)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
