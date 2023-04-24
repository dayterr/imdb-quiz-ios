import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertModel: AlertModel?
    private var alertPresenter: ResultAlertPresenterProtocol?
    private var statisticsService: StatisticServiceProtocol?
    
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setToZeros()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        activityIndicator.hidesWhenStopped = true
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        statisticsService = StatisticServiceImplementation()
        alertPresenter = ResultAlertPresenter(controller: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка", message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] _ in
                guard let self = self else { return }
                
                self.presenter.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.loadData()
            }
            
        alertPresenter?.createAlert(alertModel: alertModel)
    }
    
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
            
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
        }
    }
    
    func showAlert(alert: UIAlertController?) {
        guard let alert = alert else {
            return
        }
        
        present(alert, animated: true)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showEndAlert() {
        let msg = """
        Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
        Количество сыгранных квизов: \(String(describing: statisticsService!.gamesCount))
        Рекорд: \(String(describing: statisticsService!.bestGame.correct))/\(String(describing: statisticsService!.bestGame.total)) (\(String(describing: statisticsService!.bestGame.date.dateTimeString)))
        Средняя точность: \(String(format: "%.2f", statisticsService!.totalAccuracy))%
        """
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: msg,
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] _ in
                self?.presenter.currentQuestionIndex = 0
                self?.questionFactory?.requestNextQuestion()
                self?.correctAnswers = 0
            })
        
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
            correctAnswers += 1
        }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.imageView.layer.borderWidth = 0
            
                self?.yesButton.isEnabled = true
                self?.noButton.isEnabled = true
            
                self?.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.currentQuestionIndex == presenter.questionsAmount - 1 {
            statisticsService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            showEndAlert()
        } else {
            presenter.currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        
    }
    
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = currentQuestion?.text
        counterLabel.text = "\(presenter.currentQuestionIndex+1)/\(presenter.questionsAmount)"
        imageView.image = step.image
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
        presenter.currentQuestionIndex = 0
        correctAnswers = 0
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
