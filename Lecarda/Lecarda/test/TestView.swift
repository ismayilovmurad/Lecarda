//
//  TestView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI

struct TestView: View {
    @State var question = Question(question: "Question", answer: "Answer", wrongAnswer: "Wrong Answer", wrongAnswer2: "Wrong Answer 2")
    
    @State var currentQuestion = -1
    
    @State var randomQuestions = [Int]()
    
    @State var isTestHidden = true
    
    @State var answers = ["Answer", "WrongAnswer", "WrongAnswer2"]
    
    @State var isAlertPresented = false
    
    @State var alertText = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center){
                Button("START", action: {
                    generateRandomQuestions()
                    createQuestion()
                    isTestHidden = false
                })
                .isHidden(!isTestHidden)
                
                VStack(spacing: 40) {
                    Text(question.question)
                        .padding()
                        .font(.largeTitle)
                    
                    Button(answers[0], action: {
                        checkAnswer(answer: answers[0])
                    })
                    .buttonStyle(BlueButton())
                    .alert(alertText, isPresented: $isAlertPresented) {
                        Button("Okay", role: .cancel) {
                            createQuestion()
                        }
                    }
                    
                    Button(answers[1], action: {
                        checkAnswer(answer: answers[1])
                    })
                    .buttonStyle(BlueButton())
                    .alert(alertText, isPresented: $isAlertPresented) {
                        Button("Okay", role: .cancel) {
                            createQuestion()
                        }
                    }
                    
                    Button(answers[2], action: {
                        checkAnswer(answer: answers[2])
                    })
                    .buttonStyle(BlueButton())
                    .alert(alertText, isPresented: $isAlertPresented) {
                        Button("Okay", role: .cancel) {
                            createQuestion()
                        }
                    }
                    
                }.isHidden(isTestHidden)
            }
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
        
    }
    
    func checkAnswer(answer: String) {
        if answer == question.answer {
            alertText = "Fantastic"
        } else {
            alertText = "The correct answer is \"\(question.answer)\""
        }
        
        isAlertPresented = true
    }
    
    func createQuestion() {
        
        currentQuestion += 1
        
        var randomAnswers = [Int]()
        
        while randomAnswers.count < 2 {
            let randomNumber = Int.random(in: 0..<WordViewModel.words.count)
            
            if !randomQuestions.contains(randomNumber) && !randomAnswers.contains(randomNumber) {
                randomAnswers.append(randomNumber)
            }
        }
        
        question = Question(question: WordViewModel.words[randomQuestions[currentQuestion]].word!, answer: WordViewModel.words[randomQuestions[currentQuestion]].translation!, wrongAnswer: WordViewModel.words[randomAnswers[0]].translation!, wrongAnswer2: WordViewModel.words[randomAnswers[1]].translation!)
        
        answers.removeAll()
        answers.append(question.answer)
        answers.append(question.wrongAnswer)
        answers.append(question.wrongAnswer2)
        answers.shuffle()
    }
    
    func generateRandomQuestions() {
        while randomQuestions.count < 8 {
            let randomNumber = Int.random(in: 0..<WordViewModel.words.count)
            
            if !randomQuestions.contains(randomNumber) {
                randomQuestions.append(randomNumber)
            }
        }
    }
}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(rgba: 0x2596be))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
