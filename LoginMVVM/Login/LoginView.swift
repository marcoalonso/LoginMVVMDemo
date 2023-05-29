//
//  ViewController.swift
//  LoginMVVM
//
//  Created by Marco Alonso Rodriguez on 03/03/23.
//

import UIKit
import Combine

class LoginView: UIViewController {
    
    private let loginViewModel = LoginViewModel(apiClient: ApiClient())
    
    var cancellables = Set<AnyCancellable>()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Correo"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Contraseña"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Login"
        configuration.subtitle = "Visita ios bootcamp mx"
        configuration.image = UIImage(systemName: "play.circle.fill")
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = UIColor.red
        
        let button = UIButton(type: .system, primaryAction: UIAction(handler: { [weak self] action in
            //Action
            self?.startLogin()
        }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = configuration
        
        return button
    }()
    
    private let errorLabel: UILabel = {
       let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        label.textColor = .red
        label.font = .systemFont(ofSize: 20, weight: .regular, width: .condensed)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Primero se necesita hacer el binding (establecer las conexiones vista ---> viewModel ---> vista
        createBindingViewWithViewModel()
        
        
        
        [
            emailTextField,
            passwordTextField,
            loginButton,
            errorLabel
        ].forEach(view.addSubview)
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emailTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -20),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            passwordTextField.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -20),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
        ])
    }
    
    ///-* Se manda llamar al pulsar el boton de la vista
    func startLogin() {
        loginViewModel.userLogin(withEmail: emailTextField.text?.lowercased() ?? "", password: passwordTextField.text?.lowercased() ?? "")
    }

    ///* Con estos bindings escuchamos todos los cambios del viewModel a pesar de que el viewModel no tiene idea de la view, y en base a esos cambios actualizamos la UI
    func createBindingViewWithViewModel(){
        emailTextField.textPublisher
            .assign(to: \LoginViewModel.email, on: loginViewModel)
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .assign(to: \LoginViewModel.password, on: loginViewModel)
            .store(in: &cancellables)
        
        ///Se crea el binding del viewModel hacia un elemento de esta vista(loginButton)
        ///Queremos conectar la propiedad $isEnabled del viewModel con la propiedad isEnabled de loginButton
        loginViewModel.$isEnabled
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables) ///Se guarda la referencia en una variable
        
        ///Se crea un binding de la propiedad showLoading para mostrar/ocultar un activity indicator
        loginViewModel.$showLoading
            .assign(to: \.configuration!.showsActivityIndicator, on: loginButton)
            .store(in: &cancellables)
        
        ///Se crea un binding de la propiedad errorMessage para mostrar/ocultar si hay un error en el login
        loginViewModel.$errorMessage
            .assign(to: \UILabel.text!, on: errorLabel)
            .store(in: &cancellables)
    }

}

extension UITextField {
    ///Puede publicar 1 notificacion cada vez que se cambia el valor del textField string y no retornara error
    var textPublisher: AnyPublisher<String, Never> {
        return NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self).map { notification in
            return (notification.object as? UITextField)?.text ?? ""
        }
        .eraseToAnyPublisher()
    }
}
