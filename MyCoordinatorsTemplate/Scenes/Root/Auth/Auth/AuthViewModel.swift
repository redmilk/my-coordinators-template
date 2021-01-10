//
//  AuthViewModel.swift
//  MyCoordinatorsTemplate
//
//  Created by Danyl Timofeyev on 03.01.2021.
//  Copyright © 2021 Danyl Timofeyev. All rights reserved.
//

import Foundation

protocol AuthViewModelProtocol {
    var user: User { get }
    var title: String { get set }
    
    func performLogIn(completion: @escaping () -> Bool)
    func deleteUser()
    func dismissAuthFlow()
}

extension AuthViewModel: Sessionable { }

struct AuthViewModel: AuthViewModelProtocol {
    
    let user: User
    var coordinator: AuthCoordinatorProtocol
    var title: String
    
    init(coordinator: AuthCoordinatorProtocol,
         vcTitle: String,
         user: User
    ) {
        self.coordinator = coordinator
        self.title = vcTitle
        self.user = user
    }
    
    func performLogIn(completion: @escaping () -> Bool) {
        /// Pseudo log in
        let accessToken = AccessToken(token: "666777888999-TOKEN-111", uid: "190")
        user.accessToken = accessToken
        auth.setupUser(user, onSuccess: {
            if completion() {
                self.coordinator.end()
            }
        })
    }
    
    func deleteUser() {
        guard let user = auth.user else {
            Logger.log("Not logged in", entity: nil, symbol: "❕")
            return
        }
        auth.logout(user: user, completion: {
            self.coordinator.end()
        })
    }
    
    func dismissAuthFlow() {
        coordinator.end()
    }
    
}
