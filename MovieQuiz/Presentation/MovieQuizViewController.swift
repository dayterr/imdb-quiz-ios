import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestion: QuizQuestion?
    
    private var alertModel: AlertModel?
    private var alertPresenter: ResultAlertPresenterProtocol?
    
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        restartGame()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        activityIndicator.hidesWhenStopped = true
        
        alertPresenter = ResultAlertPresenter(controller: self)
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка", message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] _ in
                guard let self = self else { return }
                
                self.presenter.currentQuestionIndex = 0
                self.presenter.correctAnswers = 0
                self.presenter.questionFactory?.loadData()
            }
            
        alertPresenter?.createAlert(alertModel: alertModel)
    }
    
    func showAlert(alert: UIAlertController?) {
        guard let alert = alert else {
            return
        }
        
        present(alert, animated: true)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showEndAlert() {
        
        var message = presenter.makeResultsMessage()
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] _ in
                self?.presenter.currentQuestionIndex = 0
                self?.presenter.questionFactory?.requestNextQuestion()
                self?.presenter.correctAnswers = 0
            })
        
        alertPresenter?.createAlert(alertModel: alertModel)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    func deactivateButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func unsetImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func activateButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func show(quiz step: QuizStepViewModel) {
        textLabel.text = presenter.currentQuestion?.text
        counterLabel.text = "\(presenter.currentQuestionIndex+1)/\(presenter.questionsAmount)"
        imageView.image = step.image
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in
            self.restartGame()
            self.presenter.questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func restartGame() {
        presenter.currentQuestionIndex = 0
        presenter.correctAnswers = 0
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
