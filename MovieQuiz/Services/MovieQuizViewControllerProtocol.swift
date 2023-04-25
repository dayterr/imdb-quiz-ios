//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Ruth Dayter on 24.04.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    func showEndAlert()
    
    func deactivateButtons()
    func unsetImageBorder()
    func activateButtons()
    func turnOffActiviryIndicator()
}
