import SwiftUI

struct ContentView: View {
    @State private var isGameActive = false
    @State private var selectedTable = 2
    @State private var questionCount = 10

    var body: some View {
        if isGameActive {
            QuizView(selectedTable: selectedTable, questionCount: questionCount) {
                isGameActive = false  // Return to settings after the game ends
            }
        } else {
            SettingsView(selectedTable: $selectedTable, questionCount: $questionCount, startGame: {
                isGameActive = true
            })
        }
    }
}

struct SettingsView: View {
    @Binding var selectedTable: Int
    @Binding var questionCount: Int
    var startGame: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Multiplication Table")) {
                    Stepper("Table: \(selectedTable)", value: $selectedTable, in: 0...12)
                }
                
                Section(header: Text("Number of Questions")) {
                    Stepper("Questions: \(questionCount)", value: $questionCount, in: 5...20, step: 5)
                }
                
                Button("Start Quiz") {
                    startGame()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Quiz Settings")
        }
    }
}

import SwiftUI

struct QuizView: View {
    let selectedTable: Int
    let questionCount: Int
    let onGameEnd: () -> Void

    @State private var score = 0
    @State private var currentQuestion = 1
    @State private var currentAnswer = ""
    @State private var firstNumber = 0
    @State private var secondNumber = 0
    @State private var showFinalScore = false

    var body: some View {
        VStack {
            Text("Score: \(score)")
                .font(.title.bold())
                .padding()

            Text("Question \(currentQuestion) of \(questionCount)")
                .font(.headline)

            Text("\(firstNumber) × \(secondNumber) = ?")
                .font(.largeTitle.bold())

            TextField("Your answer", text: $currentAnswer)
                .frame(height: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .multilineTextAlignment(.center)
                .disabled(true) // Prevents system keyboard
                .padding()

            NumericKeypad(input: $currentAnswer)
            
            Button("Submit") {
                checkAnswer()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            if showFinalScore {
                Text("Final Score: \(score)")
                    .font(.title)
                Button("New Game") {
                    onGameEnd()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear(perform: generateQuestion)
    }

    func generateQuestion() {
        firstNumber = selectedTable
        secondNumber = Int.random(in: 0...12)
    }

    func checkAnswer() {
        if Int(currentAnswer) == firstNumber * secondNumber {
            score += 1
        }
        currentAnswer = ""
        if currentQuestion < questionCount {
            currentQuestion += 1
            generateQuestion()
        } else {
            showFinalScore = true
        }
    }
}

struct NumericKeypad: View {
    @Binding var input: String

    let keys = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["←", "0", "✔"]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            handleKeyPress(key)
                        }) {
                            Text(key)
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func handleKeyPress(_ key: String) {
        switch key {
        case "←":
            if !input.isEmpty { input.removeLast() }
        case "✔":
            // Do nothing for now, will handle submission in main view
            break
        default:
            input.append(key)
        }
    }
}


#Preview {
    ContentView()
}
