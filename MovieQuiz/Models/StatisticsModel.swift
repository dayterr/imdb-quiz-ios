//
//  StatisticsModel.swift
//  MovieQuiz
//
//  Created by Ruth Dayter on 03.04.2023.
//

import Foundation

struct StatisticsModel {
    var correctAnswers: Int
    var totalAnswers: Int
    var gameDate: Date
    
    init(correctAnswers: Int, totalAnswers: Int) {
        self.correctAnswers = correctAnswers
        self.totalAnswers = totalAnswers
        self.gameDate = Date()
    }
}
