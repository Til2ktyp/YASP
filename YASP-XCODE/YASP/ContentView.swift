import SwiftUI

// A Codable struct to save timetable data
struct Timetable: Codable {
    var entries: [[String]]
}

// A Codable struct to save notes
struct Note: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var title: String
    var content: String
}

struct ContentView: View {
    // List of menu items with labels and icon names
    let menuItems: [(label: String, icon: String)] = [
        ("Schule", "house"),
        ("Notizen", "star"),
        ("Stundenplan", "gear"),
        ("Taschenrechner", "function"),
        ("Einstellungen", "slider.horizontal.3")
    ]
    
    // State variables for the user interface
    @State private var selectedIndex: Int = 0
    @AppStorage("menuBarScale") private var menuBarScaleRaw: Double = 1.0
    @AppStorage("iconOnlyThreshold") private var iconOnlyThresholdRaw: Double = 800
    @AppStorage("menuBarShrinkFactor") private var menuBarShrinkFactorRaw: Double = 1.0
    @AppStorage("iconOnlySize") private var iconOnlySizeRaw: Double = 28.0
    @AppStorage("menuBarTopPadding") private var menuBarTopPaddingRaw: Double = 16.0
    @AppStorage("maxMenuBarSize") private var maxMenuBarSizeRaw: Double = 2.0
    // AppStorage variable for timetable font size
    @AppStorage("timetableFontSize") private var timetableFontSizeRaw: Double = 16.0

    // AppStorage variables for calculator settings
    @AppStorage("calculatorFontSize") private var calculatorFontSizeRaw: Double = 30.0
    @AppStorage("calculatorButtonWidth") private var calculatorButtonWidthRaw: Double = 60.0
    @AppStorage("calculatorButtonHeight") private var calculatorButtonHeightRaw: Double = 60.0
    
    // AppStorage for calculator display font size
    @AppStorage("calculatorDisplayFontSize") private var calculatorDisplayFontSizeRaw: Double = 50.0
    // AppStorage for calculator display height
    @AppStorage("calculatorDisplayHeight") private var calculatorDisplayHeightRaw: Double = 80.0

    // AppStorage variable for the settings menu width
    @AppStorage("settingsMenuWidth") private var settingsMenuWidthRaw: Double = 2.0
    
    // AppStorage for the menu bar height
    @AppStorage("menuBarHeight") private var menuBarHeightRaw: Double = 50.0
    
    // MARK: - Notes Settings
    // AppStorage for the notes menu width
    @AppStorage("notesMenuWidth") private var notesMenuWidthRaw: Double = 250.0
    // AppStorage for the notes main text font size
    @AppStorage("notesFontSize") private var notesFontSizeRaw: Double = 14.0
    // AppStorage for the notes list font size
    @AppStorage("notesListFontSize") private var notesListFontSizeRaw: Double = 16.0
    // NEW: AppStorage for the notes button font size
    @AppStorage("notesButtonFontSize") private var notesButtonFontSizeRaw: Double = 16.0
    // NEW: AppStorage for the notes button padding
    @AppStorage("notesButtonPadding") private var notesButtonPaddingRaw: Double = 12.0
    // NEW: AppStorage for the notes button corner radius
    @AppStorage("notesButtonCornerRadius") private var notesButtonCornerRadiusRaw: Double = 10.0


    // State for the settings sub-menus
    @State private var selectedSettingsMenuIndex: Int = 0
    let settingsMenus: [(label: String, icon: String)] = [
        ("Menüeinstellungen", "slider.horizontal.3"),
        ("Stundenplan", "gear"),
        ("Taschenrechner", "function"),
        ("Notizen", "note.text")
    ]

    // Calculated properties for scaling
    var menuBarScale: CGFloat { CGFloat(menuBarScaleRaw) }
    var iconOnlyThreshold: CGFloat { CGFloat(iconOnlyThresholdRaw) }
    var menuBarShrinkFactor: CGFloat { CGFloat(menuBarShrinkFactorRaw) }
    var iconOnlySize: CGFloat { CGFloat(iconOnlySizeRaw) }
    var menuBarTopPadding: CGFloat { CGFloat(menuBarTopPaddingRaw) }
    var maxMenuBarSize: CGFloat { CGFloat(maxMenuBarSizeRaw) }
    var timetableFontSize: CGFloat { CGFloat(timetableFontSizeRaw) }
    var calculatorFontSize: CGFloat { CGFloat(calculatorFontSizeRaw) }
    var calculatorButtonWidth: CGFloat { CGFloat(calculatorButtonWidthRaw) }
    var calculatorButtonHeight: CGFloat { CGFloat(calculatorButtonHeightRaw) }
    // Calculated property for calculator display font size
    var calculatorDisplayFontSize: CGFloat { CGFloat(calculatorDisplayFontSizeRaw) }
    // Calculated property for calculator display height
    var calculatorDisplayHeight: CGFloat { CGFloat(calculatorDisplayHeightRaw) }
    var settingsMenuWidth: CGFloat { CGFloat(settingsMenuWidthRaw) }
    
    // Calculated property for menu bar height
    var menuBarHeight: CGFloat { CGFloat(menuBarHeightRaw) }
    
    // Calculated property for notes menu width
    var notesMenuWidth: CGFloat { CGFloat(notesMenuWidthRaw) }
    // Calculated property for the notes main text font size
    var notesFontSize: CGFloat { CGFloat(notesFontSizeRaw) }
    // Calculated property for the notes list font size
    var notesListFontSize: CGFloat { CGFloat(notesListFontSizeRaw) }
    // NEW: Calculated property for the notes button font size
    var notesButtonFontSize: CGFloat { CGFloat(notesButtonFontSizeRaw) }
    // NEW: Calculated property for the notes button padding
    var notesButtonPadding: CGFloat { CGFloat(notesButtonPaddingRaw) }
    // NEW: Calculated property for the notes button corner radius
    var notesButtonCornerRadius: CGFloat { CGFloat(notesButtonCornerRadiusRaw) }


    // Calculated font size based on height and scale of the menu bar
    var menuBarFontSize: CGFloat {
        let baseSize = isPad ? 32.0 : 20.0
        let scaledSize = menuBarHeight * menuBarScale
        // Ensures that the size stays within the defined limits
        return max(min(scaledSize, baseSize * maxMenuBarSize), 12.0)
    }

    // Determines if it is an iPad
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
                let baseHPad = isPad ? 60 : 30
                let baseWidth: CGFloat = 800
                
                let shrink = pow(max(w, 1) / baseWidth, menuBarShrinkFactor)
                // The font size is now calculated directly from `menuBarFontSize` and `menuBarScale`.
                let fontSize = max(min(menuBarFontSize, CGFloat(menuBarFontSize) * maxMenuBarSize), 12)
                let hPad = max(min(shrink * menuBarScale * CGFloat(baseHPad), CGFloat(baseHPad * 2)), 8)

                // Main menu bar with a segmented picker
                Picker("Menü", selection: $selectedIndex) {
                    ForEach(menuItems.indices, id: \.self) { idx in
                        // Logic added to show icons or text based on the width
                        if w > iconOnlyThreshold {
                            Label(menuItems[idx].label, systemImage: menuItems[idx].icon)
                                .font(.system(size: fontSize)) // Uses the calculated font size
                                .tag(idx)
                        } else {
                            Image(systemName: menuItems[idx].icon)
                                .font(.system(size: iconOnlySize)) // Uses the settings size for icons
                                .tag(idx)
                        }
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, hPad)
                .labelsHidden() // Hides the "Menü" label on all platforms
            }
            // Dynamic height based on the setting
            .frame(height: menuBarHeight)
            .animation(.easeOut(duration: 0.3), value: menuBarShrinkFactorRaw)

            // Main content area of the app
            GeometryReader { geometry in
                ScrollView {
                    Group {
                        switch selectedIndex {
                        case 0:
                            Text("Willkommen auf der Startseite.")
                        case 1:
                            NotesView(notesMenuWidth: notesMenuWidth, notesFontSize: notesFontSize, notesListFontSize: notesListFontSize, notesButtonFontSize: notesButtonFontSize, notesButtonPadding: notesButtonPadding, notesButtonCornerRadius: notesButtonCornerRadius)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case 2:
                            TimetableView(isPad: isPad, timetableFontSize: timetableFontSize)
                                .frame(maxWidth: .infinity)
                        case 3:
                            CalculatorView(
                                isPad: isPad,
                                fontSize: calculatorFontSize,
                                buttonWidth: calculatorButtonWidth,
                                buttonHeight: calculatorButtonHeight,
                                calculatorDisplayFontSize: calculatorDisplayFontSize,
                                calculatorDisplayHeight: calculatorDisplayHeight // Passing the new property
                            )
                        case 4:
                            VStack(spacing: 24) {
                                Text("Personalisierung")
                                    .font(.title).fontWeight(.bold)
                                
                                // Menu for sub-menus with the segmented picker
                                Picker("Untermenü", selection: $selectedSettingsMenuIndex) {
                                    ForEach(settingsMenus.indices, id: \.self) { idx in
                                        Text(settingsMenus[idx].label)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden() // Hides the "Untermenü" label on macOS
                                .padding(.horizontal)
                                .frame(width: geometry.size.width * settingsMenuWidth / 4)

                                // Content of the sub-menu
                                switch selectedSettingsMenuIndex {
                                case 0:
                                    VStack(spacing: 24) {
                                        Divider()
                                        Text("Abstand oben")
                                            .font(.title2)
                                        Slider(value: $menuBarTopPaddingRaw, in: 0...50, step: 1)
                                        Text("Abstand: \(Int(menuBarTopPadding)) pt")
                                            .font(.body)
                                        Divider()
                                        
                                        // Slider for the menu bar height
                                        Text("Menüleisten-Höhe")
                                            .font(.title2)
                                        Slider(value: $menuBarHeightRaw, in: 40...100, step: 1)
                                        Text("Höhe: \(Int(menuBarHeight)) pt")
                                            .font(.body)
                                        Divider()

                                        Text("Menüleisten-Größe")
                                            .font(.title2)
                                        Slider(value: $menuBarScaleRaw, in: 0.5...2.0, step: 0.01)
                                        Text(String(format: "Skalierung: %.2f", menuBarScale))
                                            .font(.body)
                                        Divider()
                                        
                                        Text("Maximale Menüleisten-Größe")
                                            .font(.title2)
                                        Slider(value: $maxMenuBarSizeRaw, in: 1.0...5.0, step: 0.1)
                                        Text(String(format: "Maximale Größe: %.1fx", maxMenuBarSize))
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
                                        Divider()
                                    }
                                case 1:
                                    VStack(spacing: 24) {
                                        Text("Stundenplan Textgröße")
                                            .font(.title2)
                                        Slider(value: $timetableFontSizeRaw, in: 12...24, step: 1)
                                        Text("Größe: \(Int(timetableFontSizeRaw)) pt")
                                            .font(.body)
                                    }
                                case 2:
                                    VStack(spacing: 24) {
                                        Text("Taschenrechner-Einstellungen")
                                            .font(.title2)
                                        Slider(value: $calculatorFontSizeRaw, in: 20...50, step: 1)
                                        Text("Schriftgröße: \(Int(calculatorFontSizeRaw)) pt")
                                            .font(.body)
                                        Divider()
                                        
                                        Slider(value: $calculatorButtonWidthRaw, in: 40...100, step: 1)
                                        Text("Tastenbreite: \(Int(calculatorButtonWidthRaw)) pt")
                                            .font(.body)
                                        Divider()
                                        
                                        Slider(value: $calculatorButtonHeightRaw, in: 40...100, step: 1)
                                        Text("Tastenhöhe: \(Int(calculatorButtonHeightRaw)) pt")
                                            .font(.body)
                                        Divider()

                                        // New setting for display font size
                                        Text("Taschenrechner Anzeige-Schriftgröße")
                                            .font(.title2)
                                        Slider(value: $calculatorDisplayFontSizeRaw, in: 30...80, step: 1)
                                        Text("Größe: \(Int(calculatorDisplayFontSizeRaw)) pt")
                                            .font(.body)
                                        Divider()

                                        // Slider for display field height
                                        Text("Anzeige-Feld Höhe")
                                            .font(.title2)
                                        Slider(value: $calculatorDisplayHeightRaw, in: 50...150, step: 1)
                                        Text("Höhe: \(Int(calculatorDisplayHeightRaw)) pt")
                                            .font(.body)
                                        Divider()
                                        
                                        // New setting for the width of the settings menu
                                        Text("Breite des Menü-Segments")
                                            .font(.title2)
                                        Slider(value: $settingsMenuWidthRaw, in: 1.0...4.0, step: 0.1)
                                        Text(String(format: "Faktor: %.1fx", settingsMenuWidth))
                                            .font(.body)
                                        Divider()
                                    }
                                case 3:
                                    VStack(spacing: 24) {
                                        Text("Notizen-Einstellungen")
                                            .font(.title2)
                                        Divider()

                                        // Slider for the notes menu width
                                        Text("Notizmenü-Breite")
                                            .font(.title2)
                                        Slider(value: $notesMenuWidthRaw, in: 150...400, step: 1)
                                        Text("Breite: \(Int(notesMenuWidthRaw)) pt")
                                            .font(.body)
                                        Divider()
                                        
                                        Text("Schriftgröße des Notiztexts")
                                            .font(.title2)
                                        Slider(value: $notesFontSizeRaw, in: 10...30, step: 1)
                                        Text("Schriftgröße: \(Int(notesFontSizeRaw)) pt")
                                            .font(.body)
                                        Divider()

                                        // Slider for the notes list font size
                                        Text("Schriftgröße der Notizen-Liste")
                                            .font(.title2)
                                        Slider(value: $notesListFontSizeRaw, in: 12...24, step: 1)
                                        Text("Schriftgröße: \(Int(notesListFontSizeRaw)) pt")
                                            .font(.body)
                                        Divider()

                                        // NEW: Slider for notes button font size
                                        Text("Schriftgröße des Buttons")
                                            .font(.title2)
                                        Slider(value: $notesButtonFontSizeRaw, in: 12...24, step: 1)
                                        Text("Größe: \(Int(notesButtonFontSizeRaw)) pt")
                                            .font(.body)
                                        Divider()

                                        // NEW: Slider for notes button padding
                                        Text("Polsterung des Buttons")
                                            .font(.title2)
                                        Slider(value: $notesButtonPaddingRaw, in: 5...25, step: 1)
                                        Text("Polsterung: \(Int(notesButtonPaddingRaw)) pt")
                                            .font(.body)
                                        Divider()

                                        // NEW: Slider for notes button corner radius
                                        Text("Ecken-Rundung des Buttons")
                                            .font(.title2)
                                        Slider(value: $notesButtonCornerRadiusRaw, in: 0...20, step: 1)
                                        Text("Rundung: \(Int(notesButtonCornerRadiusRaw)) pt")
                                            .font(.body)
                                        Divider()
                                    }
                                default:
                                    EmptyView()
                                }
                            }
                            .padding(isPad ? 32 : 16)
                            .frame(maxWidth: 400)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        default:
                            EmptyView()
                        }
                    }
                    .font(isPad ? .system(size: 48) : .largeTitle)
                    .padding(isPad ? 32 : 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .padding(.top, menuBarTopPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TimetableCellView: View {
    var isPad: Bool
    var fontSize: CGFloat
    @Binding var text: String

    var body: some View {
        TextField("Fach", text: $text)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.system(size: fontSize))
            .padding(isPad ? 12 : 8)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .frame(width: isPad ? 140 : 100)
            .autocorrectionDisabled(true)
    }
}

private struct TimetableRowView: View {
    var isPad: Bool
    var hour: String
    var timetableFontSize: CGFloat
    @Binding var rowData: [String]

    var body: some View {
        HStack(spacing: isPad ? 8 : 4) {
            Text(hour)
                .font(.headline)
                .frame(width: isPad ? 100 : 70)
            ForEach(0..<5, id: \.self) { col in
                TimetableCellView(isPad: isPad, fontSize: timetableFontSize, text: $rowData[col])
            }
        }
    }
}


struct TimetableView: View {
    var isPad: Bool
    var timetableFontSize: CGFloat
    
    // Key for AppStorage
    @AppStorage("timetableData") private var timetableData: Data = Data()
    
    // Calculated property to manage and decode the data
    @State private var timetable: [[String]] = []
    
    // Weekdays
    let days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]
    // Hours
    let hours = ["1.", "2.", "3.", "4.", "5.", "6.", "7.", "8."]
    
    // Initializes the timetable and loads data from AppStorage
    init(isPad: Bool, timetableFontSize: CGFloat) {
        self.isPad = isPad
        self.timetableFontSize = timetableFontSize
        do {
            let decoder = JSONDecoder()
            let decodedTimetable = try decoder.decode([[String]].self, from: timetableData)
            _timetable = State(initialValue: decodedTimetable)
        } catch {
            // If loading fails, initialize an empty table
            _timetable = State(initialValue: Array(repeating: Array(repeating: "", count: 5), count: 8))
        }
    }
    
    // Function to save data to AppStorage
    private func saveData() {
        do {
            let encoder = JSONEncoder()
            self.timetableData = try encoder.encode(timetable)
        } catch {
            print("Error saving timetable: \(error.localizedDescription)")
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: isPad ? 16 : 8) {
            Text("Dein Stundenplan")
                .font(isPad ? .largeTitle : .title)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            // ScrollView for horizontal movement
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    VStack(spacing: isPad ? 8 : 4) {
                        // Row for weekdays
                        HStack(spacing: isPad ? 8 : 4) {
                            Text("Stunde")
                                .font(.headline)
                                .frame(width: isPad ? 100 : 70)
                            ForEach(days, id: \.self) { day in
                                Text(day)
                                    .font(.headline)
                                    .frame(width: isPad ? 140 : 100)
                            }
                        }
                        
                        // Rows for hours
                        ForEach(0..<8, id: \.self) { row in
                            TimetableRowView(isPad: isPad, hour: hours[row], timetableFontSize: timetableFontSize, rowData: $timetable[row])
                        }
                    }
                    .padding(.horizontal, 20) // Add padding to prevent content from touching the edges
                }
            }
        }
        .padding(isPad ? 32 : 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Align content to the top
        // Save data on every change
        .onChange(of: timetable) { newTimetable in
            saveData()
        }
    }
}

struct CalculatorView: View {
    @State private var display: String = "0"
    var isPad: Bool = false
    var fontSize: CGFloat
    var buttonWidth: CGFloat
    var buttonHeight: CGFloat
    var calculatorDisplayFontSize: CGFloat
    // Property for the height of the display field
    var calculatorDisplayHeight: CGFloat

    // Buttons for the calculator
    var topButtons: [[String]] {
        return [
            ["1", "2", "3", "+"],
            ["4", "5", "6", "-"],
            ["7", "8", "9", "*"]
        ]
    }
    
    var body: some View {
        let spacingV: CGFloat = isPad ? 16 : 12
        let spacingH: CGFloat = isPad ? 16 : 12
        
        VStack(spacing: spacingV) {
            
            // Display for input and result
            Text(display)
                .font(.system(size: calculatorDisplayFontSize))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, minHeight: calculatorDisplayHeight, maxHeight: calculatorDisplayHeight, alignment: .trailing)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            
            VStack(spacing: spacingV) {
                ForEach(topButtons, id: \.self) { row in
                    HStack(spacing: spacingH) {
                        ForEach(row, id: \.self) { symbol in
                            CalculatorButton(symbol: symbol, width: buttonWidth, height: buttonHeight, fontSize: fontSize, action: buttonAction)
                        }
                    }
                }
                
                // Last row with a wide "0" button
                HStack(spacing: spacingH) {
                    CalculatorButton(symbol: "0", width: buttonWidth * 2 + spacingH, height: buttonHeight, fontSize: fontSize, action: buttonAction)
                    CalculatorButton(symbol: "/", width: buttonWidth, height: buttonHeight, fontSize: fontSize, action: buttonAction)
                    CalculatorButton(symbol: "C", width: buttonWidth, height: buttonHeight, fontSize: fontSize, action: buttonAction)
                    CalculatorButton(symbol: "=", width: buttonWidth, height: buttonHeight, fontSize: fontSize, action: buttonAction)
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer() // This pushes the content up
        }
        .padding(isPad ? 32 : 16)
    }

    func buttonAction(_ symbol: String) {
        let operators: Set<Character> = ["+", "-", "*", "/"]

        switch symbol {
        case "=":
            // Check if the input is invalid (e.g., ends with an operator)
            if display.isEmpty || operators.contains(display.last!) {
                display = "Syntax-Fehler"
                return
            }
            
            // Try to evaluate the expression and catch errors
            let exp = NSExpression(format: display)
            guard let value = exp.expressionValue(with: nil, context: nil) as? NSNumber else {
                display = "Fehler"
                return
            }
            
            display = "\(value)"
        case "C":
            display = "0"
        default:
            // Prevent two operators from being entered one after the other
            if let lastChar = display.last, operators.contains(lastChar) && operators.contains(symbol.first!) {
                display.removeLast()
            }
            if display == "0" {
                display = symbol
            } else {
                display += symbol
            }
        }
    }
}

// A separate view for the calculator buttons to keep the code cleaner
struct CalculatorButton: View {
    var symbol: String
    var width: CGFloat
    var height: CGFloat
    var fontSize: CGFloat
    var action: (String) -> Void
    
    var body: some View {
        Button(action: {
            action(symbol)
        }) {
            Text(symbol)
                .font(.system(size: fontSize))
                .fontWeight(.bold)
                .frame(width: width, height: height)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: width / 2))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notes View
struct NotesView: View {
    var notesMenuWidth: CGFloat
    var notesFontSize: CGFloat
    var notesListFontSize: CGFloat
    // NEW: Properties for button customization
    var notesButtonFontSize: CGFloat
    var notesButtonPadding: CGFloat
    var notesButtonCornerRadius: CGFloat

    @AppStorage("notesData") private var notesData: Data = Data()
    @State private var notes: [Note] = []
    // Using a selection binding is the more robust way to handle this with NavigationSplitView
    @State private var selectedNote: Note?
    
    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationSplitView {
                VStack(spacing: 0) {
                    // Using selection: $selectedNote and .tag() for robust selection
                    List(selection: $selectedNote) {
                        ForEach(notes) { note in
                            Text(note.title)
                                .font(.system(size: notesListFontSize))
                            // .onTapGesture { selectedNote = note } <-- Removed as it's not the correct pattern for NavigationSplitView
                                .tag(note)
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .navigationTitle("Deine Notizen")
                    .frame(minWidth: notesMenuWidth)
                    
                    Button(action: addNote) {
                        Label("Neue Notiz", systemImage: "plus.circle")
                            .font(.system(size: notesButtonFontSize)) // Applied new font size
                            .frame(maxWidth: .infinity)
                            .padding(notesButtonPadding) // Applied new padding
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(notesButtonCornerRadius) // Applied new corner radius
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity) // Fills the available vertical space
            } detail: {
                // The detail view now shows the selected note if it exists
                if let selectedNoteBinding = Binding($selectedNote) {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Titel", text: selectedNoteBinding.title)
                            .font(.largeTitle)
                            .padding()
                        
                        TextEditor(text: selectedNoteBinding.content)
                            .font(.system(size: notesFontSize))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding()
                    }
                    .navigationTitle(selectedNoteBinding.title.wrappedValue)
                    .onChange(of: selectedNote) { newNote in
                        if let newNote = newNote {
                            // Find the index of the updated note and save it
                            if let index = notes.firstIndex(where: { $0.id == newNote.id }) {
                                notes[index] = newNote
                                saveData()
                            }
                        }
                    }
                } else {
                    VStack {
                        Text("Wähle eine Notiz aus oder erstelle eine neue.")
                            .font(.headline)
                        Button(action: addNote) {
                            Label("Neue Notiz", systemImage: "plus.circle")
                        }
                    }
                }
            }
            .onAppear(perform: loadData)
        } else {
            // Fallback on earlier versions
        }
    }
    
    // Functions to manage notes
    private func loadData() {
        do {
            let decoder = JSONDecoder()
            notes = try decoder.decode([Note].self, from: notesData)
        } catch {
            print("Error loading notes: \(error.localizedDescription)")
            notes = [] // Ensure notes is empty on error
        }

        // Check if the previously selected note still exists. If not, select the first one.
        if !notes.contains(where: { $0.id == selectedNote?.id }) {
            selectedNote = notes.first
        }
        
        // Always ensure there is at least one note to select
        if notes.isEmpty {
            addNote()
        }
    }
    
    private func saveData() {
        do {
            let encoder = JSONEncoder()
            notesData = try encoder.encode(notes)
        } catch {
            print("Error saving notes: \(error.localizedDescription)")
        }
    }
    
    private func addNote() {
        let newNote = Note(title: "Neue Notiz \(notes.count + 1)", content: "Schreib hier deine Notiz...")
        notes.append(newNote)
        selectedNote = newNote
        saveData()
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        // Correction: Use the remove(atOffsets:) method, which is correct for a List
        notes.remove(atOffsets: offsets)
        saveData()
        // If the selected note was deleted, select the first one again
        if selectedNote != nil && !notes.contains(selectedNote!) {
            selectedNote = notes.first
        }
    }
}

#Preview {
    ContentView()
}
