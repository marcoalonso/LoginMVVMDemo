//
//  ApiClient.swift
//  LoginMVVM
//
//  Created by Marco Alonso Rodriguez on 03/03/23.
//

import Foundation

enum BackendError: String, Error {
    case invalidEmail = "Comprueba el Email"
    case invalidPassword = "Comprueba tu password"
}

final class ApiClient {
    
    func login(withEmail email: String, password: String) async throws -> User {
        ///Simular peticion HTTP y esperar 1 seg
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
        return try simulateBackendLogic(email: email, password: password)
    }
}

/// Backend ficticio que compara si las credenciales son válidas y retorna un JSON
func simulateBackendLogic(email: String, password: String) throws  -> User {
    guard email == "marco@gmail.com" else {
        throw BackendError.invalidEmail
    }
    
    guard password == "123456" else {
        throw BackendError.invalidPassword
    }
    print("Success")
    return .init(name: "Marco Alonso", token: "12309854", sessionStart: .now)
}
