
import UIKit

class CustomTableViewCell: UITableViewCell {
    
    
    @IBOutlet var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cellRatingControl: RatingControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Устанавливаем компактный размер для каждой звезды (например, 22 на 22 точки)
        cellRatingControl.starSize = CGSize(width: 14, height: 14)
        
        // Уменьшаем расстояние между звездами, чтобы они не растягивались
        cellRatingControl.starSpacing = 5
    }
}
