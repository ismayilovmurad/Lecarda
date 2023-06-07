//
//  SettingsView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.04.23.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    @State var currentNonce: String?
    
    var auth = Authentication()
    
    @AppStorage("dailyReminderEnabled")
    var dailyReminderEnabled = false
    
    @State var dailyReminderTime = Date(timeIntervalSince1970: 0)
    
    @AppStorage("dailyReminderTime")
    var dailyReminderTimeShadow: Double = 0
    
    @State var isAlertPresented = false
        
    var body: some View {
        ZStack {
            /// change the background color
            Color(red: 0.914, green: 0.973, blue: 0.976).ignoresSafeArea()
            
            List {
                Text("Ayarlar")
                    .font(.largeTitle)
                    .padding(.bottom, 8)
                
                Section(header: Text("Bildirimler")) {
                    HStack {
                        Toggle("Günlük hatırlatma", isOn: $dailyReminderEnabled).onChange(of: dailyReminderEnabled, perform: {_ in configureNotification()})
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.325, green: 0.498, blue: 0.906)))
                        DatePicker(
                            "",
                            selection: $dailyReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .disabled(dailyReminderEnabled == false)
                        /// .onChange(of:perform:) is part of the View protocol, so you can use it on any view.
                        .onChange(of: dailyReminderTime, perform: { newValue in
                            /// This copies the number of seconds since the midnight of Jan 1, 1970, as a double value, into the shadow property for the App Storage.
                            dailyReminderTimeShadow = newValue.timeIntervalSince1970
                            configureNotification()})
                        .onAppear {
                            /// With it, every time the Section is displayed, the value stored in the shadow property is converted to a date and stored into dailyReminderTime.
                            dailyReminderTime = Date(timeIntervalSince1970: dailyReminderTimeShadow)
                        }
                    }
                }
                
                if userAuth.isLoggedin {
                    VStack(spacing: 20) {
                        Text("\(Auth.auth().currentUser?.email ?? "-")")
                        Button("Çıkış yap") {
                            isAlertPresented = true
                        }
                        .alert("Çıkış yapmak istediğinden emin misin?", isPresented: $isAlertPresented, actions: {
                            Button("Evet", role: .cancel, action: {
                                do {
                                    try Auth.auth().signOut()
                                    userAuth.logout()
                                } catch let error {
                                    // handle the error
                                    print(error.localizedDescription)
                                }
                            })
                            
                            Button("Hayır", action: {
                                isAlertPresented = false
                            })
                        })
                    }
                    .centerHorizontally()
                } else {
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = auth.randomNonceString()
                            currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = auth.sha256(nonce)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:

                                    guard let nonce = currentNonce else {
                                        fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                    }
                                    guard let appleIDToken = appleIDCredential.identityToken else {
                                        fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                    }
                                    guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                        return
                                    }

                                    let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                                    Auth.auth().signIn(with: credential) { (authResult, error) in
                                        if (error != nil) {
                                            // Error. If error.code == .MissingOrInvalidNonce, make sure
                                            // you're sending the SHA256-hashed nonce as a hex string with
                                            // your request to Apple.
                                            print(error?.localizedDescription as Any)
                                            return
                                        }
                                        userAuth.login()
                                    }
                                default:
                                    break
                                }
                            default:
                                break
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                }
                
                
                
            }
            .background(Color(red: 0.914, green: 0.973, blue: 0.976))
            .scrollContentBackground(.hidden)
            .onAppear() {
                userAuth.isLoggedin = Auth.auth().currentUser != nil
            }
        }
    }
    
    func configureNotification() {
        if dailyReminderEnabled {
            LocalNotifications.shared.createReminder(
                time: dailyReminderTime)
        } else {
            LocalNotifications.shared.deleteReminder()
        }
    }
}
