import SwiftUI

struct ContentView: View {
    
    // Zustandsvariablen, die die UI-Elemente steuern
    @State private var inputText: String = ""
    @State private var sliderValue: Double = 50.0
    @State private var selectedItem: String?
    
    // Die Daten für die Liste
    let listItems = ["Apfel", "Birne", "Banane", "Orange", "Traube"]
    
    var body: some View {
        VStack(spacing: 10) {
            
            // 1. Texteingabefeld
            TextField("Gib hier Text ein...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // 2. Schieberegler
            VStack(alignment: .leading) {
                Text("Slider-Wert: \(Int(sliderValue))")
                    .font(.headline)
                Slider(value: $sliderValue, in: 0...100)
            }
            .padding()
            
            // 3. Liste mit Textauswahl
            List(listItems, id: \.self, selection: $selectedItem) { item in
                Text(item)
            }
            .frame(minHeight: 150)
            
            // Zeigt die ausgewählten Werte an
            VStack(alignment: .leading) {
                Text("Eingegebener Text: \(inputText)")
                Text("Aktueller Slider-Wert: \(Int(sliderValue))")
                if let selected = selectedItem {
                    Text("Ausgewähltes Element: \(selected)")
                } else {
                    Text("Kein Element ausgewählt")
                }
            }
            .padding()
            .font(.footnote)
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
