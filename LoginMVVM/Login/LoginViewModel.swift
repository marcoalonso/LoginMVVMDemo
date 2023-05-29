//
//  LoginViewModel.swift
//  LoginMVVM
//
//  Created by Marco Alonso Rodriguez on 03/03/23.
// https://www.youtube.com/watch?v=1uYp2cuzkFk&t=133s, continuar en minuto 32:00
/// - * La comunicacion entre el ViewModel hacia la vista es a traves de bindins, en lugar de un DelegationPattern o closures como normalmente se hace en otras arquitecturas.

import Foundation
import Combine

class LoginViewModel {
    @Published var email = ""
    @Published var password = ""
    @Published var isEnabled = false
    
    var cancellables = Set<AnyCancellable>()
    
    let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
        
        formValidation()
    }
    
    func formValidation() {
        Publishers.CombineLatest($email, $password)
            .filter { email, password in
                return email.count > 5 && password.count > 5
            }
            .sink { value in
                self.isEnabled = true
        }.store(in: &cancellables)
    }
    
    @MainActor
    func userLogin(withEmail email: String,
                   password: String) {
        Task {
            do {
                let userModel = try await apiClient.login(withEmail: email, password: password)
            } catch let error as BackendError {
                print("Debug: error \(error.localizedDescription)")
            }
        }
    }
    
}
