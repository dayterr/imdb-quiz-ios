import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertModel: AlertModel?
    private var alertPresenter: ResultAlertPresenterProtocol?
    private var statisticsService: StatisticServiceProtocol?
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
            self.setToZeros()
        
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 20
        
            questionFactory = QuestionFactory(delegate: self)
            questionFactory?.requestNextQuestion()
        
            statisticsService = StatisticServiceImplementation()
        }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
        }
    }
    
    func showAlert(alert: UIAlertController?) {
        guard let alert = alert else {
            return
        }
        
        self.present(alert, animated: true)
    }
    
    func showEndAlert() {
        let msg = """
        Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)
        Количество сыгранных квизов: \(String(describing: statisticsService!.gamesCount))
        Рекорд: \(String(describing: statisticsService!.bestGame.correct))/\(String(describing: statisticsService!.bestGame.total)) (\(String(describing: statisticsService!.bestGame.date.dateTimeString)))
        Средняя точность: \(String(format: "%.2f", statisticsService!.totalAccuracy))%
        """
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: msg,
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] _ in
                self?.currentQuestionIndex = 0
                self?.questionFactory?.requestNextQuestion()
                self?.correctAnswers = 0
            })
        
        alertPresenter = ResultAlertPresenter(controller: self)
        alertPresenter?.createAlert(alertModel: alertModel)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let userAnswer = true
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let userAnswer = false
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }

    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            self.correctAnswers += 1
        }
        
        self.yesButton.isEnabled = false
        self.noButton.isEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.imageView.layer.borderWidth = 0
            
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
            
                self.showNextQuestionOrResults()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showNextQuestionOrResults() {
        if self.currentQuestionIndex == self.questionsAmount - 1 {
            statisticsService?.store(correct: self.correctAnswers, total: self.questionsAmount)
            self.showEndAlert()
        } else {
            self.currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        
    }
    
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = self.currentQuestion?.text
        counterLabel.text = "\(self.currentQuestionIndex+1)/\(self.questionsAmount)"
        imageView.image = UIImage(named: self.currentQuestion?.image ?? "Oy")
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in
            self.setToZeros()
            self.questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setToZeros() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
    }

}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
