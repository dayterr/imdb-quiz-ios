//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by Ruth Dayter on 03.04.2023.
//

import Foundation
import UIKit

class ResultAlertPresenter: ResultAlertPresenterProtocol {
    
    weak var controller: UIViewController?
    
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    internal func createAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion
            
        )
        
        alert.view.accessibilityIdentifier = "Game results"
        
        alert.addAction(action)
        
        self.controller?.present(alert, animated: true)
    }
}

