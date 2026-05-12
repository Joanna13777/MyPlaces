

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    // MARK: - Properties
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    var rating = 0

   // MARK: - Initializator
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: - Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed 👍")
    }


    // MARK: - Private Methods
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
    for _ in 0..<starCount {
        
    // Create the Button
    let button = UIButton()
    button.backgroundColor = .red
        
    // Add constraints
    button.translatesAutoresizingMaskIntoConstraints = false
    // высота и ширина кнопки
        button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
        
    // Setup the button action
    button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
        
    // Поместим кнопку в StackView
    addArrangedSubview(button)
    // Добавим новую кнопку в массив кнопок рейтинга.
    ratingButtons.append(button)

            }
        }
    }
