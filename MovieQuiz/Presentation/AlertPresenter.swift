//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Ruth Dayter on 03.04.2023.
//

import Foundation
import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var alertDelegate: AlertPresenterDelegate?
    
    init(alertDelegate: AlertPresenterDelegate) {
        self.alertDelegate = alertDelegate
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
        
        alert.addAction(action)
        
        alertDelegate?.showAlert(alert: alert)
        
    }
}

