//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ruth Dayter on 03.04.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    
}
