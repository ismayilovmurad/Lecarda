//
//  ScoreView.swift
//  Lecarda
//
//  Created by Murad Ismayilov on 04.06.23.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

struct ScoreView: View {
    @EnvironmentObject var userAuth: UserAuth
    
    @State var currentNonce: String?
    
    var auth = Authentication()
    
    
    
    @State private var users = [User]()
    
    @State private var place = 0
    
    @State private var currentUser: User? = nil
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var isAlertPresented = false
    
    @State private var isSignInHidden = true
    
    @State private var isTryAgainHidden = true
    
    @State private var isListHidden = true
        
    var body: some View {
        
        ZStack {
            
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
                                
                                checkAppear()
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
            .isHidden(isSignInHidden)
            
            List {
                
                Section("Senin puanın") {
                    HStack {
                        Text("\(currentUser?.place ?? 0).").bold()
                        Text("\(currentUser?.email ?? "")")
                        Spacer()
                        Text("\(currentUser?.score ?? 0)").bold()
                    }
                }.foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                
                Section("Diğer kullanıcılar") {
                    ForEach(users, id: \.self) { item in
                        HStack {
                            Text("\(item.place).").bold()
                            Text(item.email)
                            Spacer()
                            Text("\(item.score)").bold()
                        }
                    }
                }
                
            }
            .listStyle(.sidebar)
            .navigationTitle("Puan tablosu")
            .isHidden(isListHidden)
            
            VStack {
                Button("Yeniden dene", action: {
                    checkAppear()
                })
                .font(Font.title.weight(.bold))
                .foregroundColor(Color(red: 0.325, green: 0.498, blue: 0.906))
                .alert("İnternet bağlantısı yok", isPresented: $isAlertPresented) {
                    Button("Tamam", role: .cancel) {
                        isTryAgainHidden = false
                    }
                }
            }
            .isHidden(isTryAgainHidden)
            
        }
        .onAppear(){
            checkAppear()
        }
    }
    
    func checkAppear() {
        if !networkMonitor.isConnected {
            isAlertPresented = true
        } else {
            if !isTryAgainHidden {
                isTryAgainHidden.toggle()
            }
            if Auth.auth().currentUser != nil {
                fetchUsers()
                isListHidden = false
            } else {
                isSignInHidden = false
            }
        }
    }
    
    func fetchUsers() {
        
        var innerUsers = [User]()
        
        Firestore.firestore().collection("Users").getDocuments(completion: {snapshot, error in
            
            if error == nil {
                
                if snapshot != nil {
                    
                    for i in snapshot!.documents {
                        var user = User(email: "\(i["email"]!)", score: i["score"] as! Int)
                        
                        if user.email == Auth.auth().currentUser!.email! {
                            currentUser = user
                            print("here")
                        }
                                                
                        innerUsers.append(user)
                    }
                    
                    users = innerUsers.sorted(by: {$0.score > $1.score})
                    
                    for i in 0..<users.count {
                        users[i].updatePlace(newPlace: i+1)
                        
                        if users[i].email == Auth.auth().currentUser!.email! {
                            currentUser?.updatePlace(newPlace: i+1)
                            print("here as well")
                        }
                    }
                    
                    
                } else{
                    print("Error")
                }
            } else {
                print("Error")
            }
        })
    }
}
