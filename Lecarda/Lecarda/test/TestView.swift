//
//  TestView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI

struct TestView: View {
    /// current question
    @State var question = Question(question: "Question", answer: "Answer", wrongAnswer: "Wrong Answer", wrongAnswer2: "Wrong Answer 2")
    
    /// answers
    @State var answers = ["Answer", "WrongAnswer", "WrongAnswer2"]
    
    /// current question index
    @State var currentQuestion = -1
    
    /// questions
    @State var randomQuestions = [Int]()
    
    @State var isTestHidden = true
    @State var isAlertPresented = false
    @State var alertText = ""
    
    @State private var correctAnswers = 0
    
    @State private var alertButtonText = "Devam et"
    
    var body: some View {
        ZStack {
            /// change the background color
            Color(red: 0.914, green: 0.973, blue: 0.976).ignoresSafeArea()
            
            Button("Teste başla", action: {
                generateRandomQuestions()
                createQuestion()
                isTestHidden = false
            })
            .font(Font.title.weight(.bold))
            .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
            .isHidden(!isTestHidden)
            
            VStack(spacing: 34) {
                Text(question.question)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .font(Font.largeTitle.weight(.bold))
                    .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                    .padding()
                
                Button(answers[0], action: {
                    checkAnswer(answer: answers[0])
                })
                .buttonStyle(AnswerButtonStyle())
                .alert(alertText, isPresented: $isAlertPresented) {
                    Button(alertButtonText, role: .cancel) {
                        checkFinish()
                    }
                }
                
                Button(answers[1], action: {
                    checkAnswer(answer: answers[1])
                })
                .buttonStyle(AnswerButtonStyle())
                .alert(alertText, isPresented: $isAlertPresented) {
                    Button(alertButtonText, role: .cancel) {
                        checkFinish()
                    }
                }
                
                Button(answers[2], action: {
                    checkAnswer(answer: answers[2])
                })
                .buttonStyle(AnswerButtonStyle())
                .alert(alertText, isPresented: $isAlertPresented) {
                    Button(alertButtonText, role: .cancel) {
                        checkFinish()
                    }
                }
            }
            .isHidden(isTestHidden)
        }
    }
    
    func generateRandomQuestions() {
        while randomQuestions.count < 10 {
            let randomNumber = Int.random(in: 0..<WordViewModel.words.count)
            
            if !randomQuestions.contains(randomNumber) {
                randomQuestions.append(randomNumber)
            }
        }
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
        
        question = Question(question: WordViewModel.words[randomQuestions[currentQuestion]].word, answer: WordViewModel.words[randomQuestions[currentQuestion]].translation, wrongAnswer: WordViewModel.words[randomAnswers[0]].translation, wrongAnswer2: WordViewModel.words[randomAnswers[1]].translation)
        
        answers.removeAll()
        answers.append(question.answer)
        answers.append(question.wrongAnswer)
        answers.append(question.wrongAnswer2)
        answers.shuffle()
    }
    
    func checkFinish() {
        if alertButtonText == "Tamam" {
            currentQuestion = -1
            alertButtonText = "Devam et"
            alertText = ""
            isTestHidden = true
            randomQuestions.removeAll()
            correctAnswers = 0
        } else {
            createQuestion()
        }
    }
    
    func checkAnswer(answer: String) {
        if answer == question.answer {
            correctAnswers += 1
            alertText = "Harika, doğru cevap! 🤩"
        } else {
            alertText = "Yanlış, doğru cevap \"\(question.answer)\". 🫣"
        }
        
        if currentQuestion == 9 {
            alertText += "\n\n Test bitti, sonuç 10/\(correctAnswers) 🥳"
            alertButtonText = "Tamam"
        }
        
        isAlertPresented = true
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
