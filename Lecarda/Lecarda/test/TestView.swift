//
//  TestView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI
import FirebaseFirestore
import AuthenticationServices
import FirebaseAuth
import CoreHaptics
import AVFoundation
import StoreKit

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
    
    @State private var showingSheet = false
    
    @State private var isTimerHidden = true
    
    @State private var progress = 1.0
    @State private var count = 5
    
    @State private var startTimer = false
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var isScoreHidden = true
    
    @State private var isChartHidden = false
    
    @State private var testOverText = ""
    
    @State private var isTimeOver = false
        
    @State private var score = 0
    
    @AppStorage("shouldRequestReview", store: .standard) var shouldRequestReview: Bool = true
            
    var body: some View {
        ZStack {
            /// change the background color
            Color(red: 0.914, green: 0.973, blue: 0.976).ignoresSafeArea()
            
            Button("Teste başla", action: {
                generateRandomQuestions()
                createQuestion()
                isTestHidden = false
                
                progress = 1.0
                count = 5
                isTimerHidden = false
                startTimer = true
                
                isScoreHidden = false
                
                isChartHidden = true
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
                .sheet(isPresented: $showingSheet, content: {
                    SheetView(correctAnswers: correctAnswers, restart: restart, isTimeOver: isTimeOver)
                })
                
                Button(answers[1], action: {
                    checkAnswer(answer: answers[1])
                })
                .buttonStyle(AnswerButtonStyle())
                .alert(alertText, isPresented: $isAlertPresented) {
                    Button(alertButtonText, role: .cancel) {
                        checkFinish()
                    }
                }
                .sheet(isPresented: $showingSheet, content: {
                    SheetView(correctAnswers: correctAnswers, restart: restart, isTimeOver: isTimeOver)
                })
                
                Button(answers[2], action: {
                    checkAnswer(answer: answers[2])
                })
                .buttonStyle(AnswerButtonStyle())
                .alert(alertText, isPresented: $isAlertPresented) {
                    Button(alertButtonText, role: .cancel) {
                        checkFinish()
                    }
                }
                .sheet(isPresented: $showingSheet, content: {
                    SheetView(correctAnswers: correctAnswers, restart: restart, isTimeOver: isTimeOver)
                })
            }
            .isHidden(isTestHidden)
            
            Text("Puan: \(score)")
                .frame(maxWidth:.infinity, maxHeight:.infinity, alignment:.topLeading)
                .padding()
                .isHidden(isScoreHidden)
            
            /// image
            VStack {
                NavigationLink(destination: ScoreView()) {
                    Image(systemName: "chart.bar.xaxis")
                        .resizable()
                        .frame(width: 33, height: 33)
                        .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                }
            }
            .frame(maxWidth:.infinity, maxHeight:.infinity, alignment:.topTrailing)
            .padding()
            .isHidden(isChartHidden)
            
            VStack {
                ZStack {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.pink, lineWidth: 10)
                        .padding(-2)
                }
                .padding()
                .frame(height: 80)
                .animation(.spring(), value: progress)
                .overlay(
                    Text("\(count)")
                )
                .onReceive(timer) { _ in
                    if startTimer {
                        progress -= 0.2
                        count -= 1
                        if progress <= 0.0 || count <= 0 {
                            timer.upstream.connect().cancel()
                            
                            showingSheet = true
                            isTimerHidden = true
                            isTimeOver = true
                            
                            vibration(type: .error)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                restart()
                            }
                        }
                        
                    }
                }
            }
            .frame(maxWidth:.infinity, maxHeight:.infinity, alignment:.topTrailing)
            .padding()
            .isHidden(isTimerHidden)
            
            
        }
        .onAppear() {
            if Auth.auth().currentUser != nil {
                getScore()
            } else {
                score = 0
            }
            
            if shouldRequestReview {
                requestReview()
                shouldRequestReview.toggle()
            }
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
            startTimer = false
            
            isTimeOver = false
            showingSheet = true
            isTimerHidden = true
            
            saveScore()
        } else {
            progress = 1.0
            count = 5
                        
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            
            createQuestion()
        }
    }
    
    func restart() {
        currentQuestion = -1
        alertButtonText = "Devam et"
        alertText = ""
        isTestHidden = true
        randomQuestions.removeAll()
        correctAnswers = 0
        isScoreHidden = true
        isChartHidden = false
        
        startTimer = false
    }
    
    func checkAnswer(answer: String) {
        timer.upstream.connect().cancel()
        
        if answer == question.answer {
            correctAnswers += 1
            alertText = "Harika 🤩\nDoğru cevap!"
            score += 10
            vibration(type: .success)
        } else {
            alertText = "Yanlış 🫣\nDoğru cevap \"\(question.answer)\"."
        }
        
        isAlertPresented.toggle()
        
        if currentQuestion == 9 {
            alertButtonText = "Tamam"
        }
    }
    
    func getScore() {
        var innerUsers = [User]()
        
        var email = "\(Auth.auth().currentUser!.email!)"
        
        Firestore.firestore().collection("Users").document(email).getDocument(completion: { (document, error) in
            
            if let document = document, document.exists {
                
                if document["score"] != nil {
                    score = document["score"] as! Int
                }
                } else {
                    print("Document does not exist")
                }
        })
    }
    
    func vibration(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func saveScore() {
        if Auth.auth().currentUser != nil {
            var db = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.email!)
            
            db.setData(["email": Auth.auth().currentUser!.email!, "score": score]) { error in
                
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
        
    }
    
    func requestReview() {
        guard let scene = UIApplication.shared.foregroundActiveScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var correctAnswers: Int
    
    var restart: () -> ()
    
    var isTimeOver: Bool
    
    var body: some View {
        if isTimeOver {
            VStack {
                Image(systemName: "timer")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                
                Text("Süre doldu 🫣").padding()
                
                Button("Geri dön", action: {
                    dismiss()
                    
                })
                .buttonStyle(AnswerButtonStyle())
            }
            .interactiveDismissDisabled()
        } else {
            VStack {
                Text("Test bitti, sonuç 10/\(correctAnswers) 🥳")
                
                Button("Geri dön", action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        restart()
                    }
                })
                .buttonStyle(AnswerButtonStyle())
                
                Text("Puan: \(String(correctAnswers*10))")
                    .padding()
            }
            .interactiveDismissDisabled()
        }
    }
}

extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}
