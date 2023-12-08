//
//  ContentView.swift
//  WordScramble
//
//  Created by Batuhan Akdemir on 8.12.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
  
    var body: some View {
        
        NavigationStack {
            List {
                
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section(content: {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                                .foregroundStyle( chooseColorForWord(word.count))
                            Text(word)
                        }
                    }
                }, header: {
                    Text("Score: \(score)")
                        .font(.title3.bold())
                        .foregroundStyle(.black)
                })
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar {
                Button("Change Word") {
                    startGame()
                }
            }
            .alert(errorTitle, isPresented: $showingError){
                Button("OK"){ }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else {
            wordError(title: "Too Short", message: "You cannot create words of less than 3 letters")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            score =  score + calculateScor(answer)
        }
        newWord = ""
    }
    
    func startGame() {
        
        usedWords.removeAll()
        score = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound

    }
    
    
    func wordError(title: String , message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    private func chooseColorForWord(_ length: Int) -> Color {
          switch length {
          case 3, 4:
              return .blue
          case 5, 6:
              return .green
          case 7, 8:
              return .orange
          default:
              return .gray
          }
      }
    
    private func calculateScor(_ word: String) -> Int {
        
        let length = word.count
        switch length {
        case 3,4:
            return word.count
        case 5,6:
            return word.count * 2
            
        case 7,8:
            return word.count * 3
            
        default:
            return 0
            
        }
    }

}

/*#Preview {
    ContentView()
}
*/
