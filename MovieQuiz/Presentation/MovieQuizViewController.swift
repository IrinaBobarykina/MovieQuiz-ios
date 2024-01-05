import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    //общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    //вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    //фабрика вопросов - rонтроллер будет обращаться за вопросами к ней
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterDelegate?
    private var statisticService: StatisticService?


    //тема статус бара
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate:self)
        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        questionFactory?.requestNextQuestion()
    }
     
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showQuizStep(quiz: viewModel)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        guard let currentQuestion = currentQuestion else { return }
        let myAnswer = false
        checkAnswerCorrectness(isCorrect: myAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        guard let currentQuestion = currentQuestion else { return }
        let myAnswer = true
        checkAnswerCorrectness(isCorrect: myAnswer == currentQuestion.correctAnswer)
    }
    
    //преобразуем модель вопроса, в те данные, которые надо показать на экране приложения в состояни «Вопрос задан»
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    //метод, который будет брать данные из вью модели вопроса и отрисовывать их на экране
    private func showQuizStep(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //метод, который проверяет корректность ответа - окрашивает рамку и засчитывает правильные баллы
    private func checkAnswerCorrectness(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect == true {
            imageView.layer.borderColor =  UIColor.ypGreen.cgColor
            correctAnswers += 1
        }else{
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        if currentQuestionIndex == questionsAmount - 1 {
            let result = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть еще раз")
            
            didGameFinished(quiz: result)
            
        }else{
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()

        }
    }
    
    private func getCurrentDate (date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy hh:mm"
            let dateFormatted = dateFormatter.string(from: date)
            return dateFormatted
        }

    private func makeResultMessage() -> String {
            guard let statisticService = statisticService else {
                assertionFailure("Error. Can't get statisticService")
                return ""
            }
        
        let date = getCurrentDate(date: statisticService.bestGame.date)
                
                let resultMessage = [
                    "Ваш результат: \(correctAnswers)/10",
                    "Количество сыгранных квизов: \(statisticService.gamesCount)",
                    "Рекорд \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))",
                    "Средняя точность \(String(format: "%.2f",statisticService.totalAccuracy))%"].joined(separator: "\n")
                
                return resultMessage
            }
    
    private func didGameFinished(quiz result: QuizResultViewModel) {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            let alertModel = AlertModel(
                title: result.title,
                message: makeResultMessage(),
                buttonText: result.buttonText,
                completion: {
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                })
            
            alertPresenter?.showResultAlert(alertModel: alertModel)
        }
        
}
