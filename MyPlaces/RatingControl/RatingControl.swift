import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    // MARK: - Properties
    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
            // Вызываем замыкание и передаем новый рейтинг наружу
                    onRatingChange?(rating)
        }
    }
    // ТУТ ОБЪЯВЛЯЕМ ЗАМЫКАНИЕ:
        // Оно принимает Int (новый рейтинг) и ничего не возвращает (Void)
    var onRatingChange: ((Int) -> Void)?
    
    @IBInspectable var starSize: CGSize = CGSize(width: 30.0, height: 30.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starSpacing: CGFloat = 26.0 {
        didSet {
            self.spacing = starSpacing
        }
    }

    // MARK: - Initializator
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
   
    // MARK: - Private Methods
    private func setupButtons() {
        
        // Очистка старых компонентов
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        self.distribution = .fillEqually // Равномерно распределяет кнопки
            self.spacing = starSpacing       // Увеличиваем расстояние
        
        
        // Настройка ресурсов (SF Symbols)
        
        let config = UIImage.SymbolConfiguration(pointSize: starSize.height)
        let filledStar = UIImage(systemName: "star.fill", withConfiguration: config)
        let emptyStar = UIImage(systemName: "star", withConfiguration: config)

        for _ in 0..<starCount {
            
            let button = UIButton(type: .system) // Используем системный тип для корректной работы конфигураций
        
            
            // Обработчик обновления состояний
            var buttonConfig = UIButton.Configuration.plain()
            buttonConfig.imagePadding = 0
            buttonConfig.baseBackgroundColor = .clear
            button.configuration = buttonConfig
            
            // Обработчик обновления состояний
            button.configurationUpdateHandler = { button in
                            var updatedConfig = button.configuration
                            
                            let isSelected = button.isSelected
                            let isHighlighted = button.isHighlighted
                            
                            if isHighlighted {
                                updatedConfig?.image = filledStar
                                button.tintColor = .systemBlue // Цвет в момент удержания пальца
                            } else {
                                updatedConfig?.image = isSelected ? filledStar : emptyStar
                                button.tintColor = isSelected ? .systemOrange : .systemGray
                            }
                            button.configuration = updatedConfig
                        }
            
            // Констреинты размеров кнопок
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
                        
            // Разрешаем кнопке реагировать на клики
            button.isUserInteractionEnabled = true

                // Добавляем экшен нажатия
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
           
            addArrangedSubview(button) // Поместим кнопку в StackView
            ratingButtons.append(button) // Добавим новую кнопку в массив кнопок рейтинга.
        }
        
        updateButtonSelectionStates() // Обновляем вид в соответствии с текущим рейтингом
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // Если индекс кнопки меньше рейтинга, то кнопка должна быть выделена
            button.isSelected = index < rating
            print("✅ Успешно сохранено в Core Data")
        }
    }
    // MARK: - Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        print("Нажата звезда!")
        
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        // Вычисляем выбранный рейтинг
        let selectedRating = index + 1
        
        if selectedRating == rating {
            // Если нажали на ту же звезду, что уже выбрана — сбрасываем в 0
            rating = 0
        } else {
            // Иначе присваиваем номер выбранной звезды
            rating = selectedRating
        }
        
    }
}

