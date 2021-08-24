//
//  NewsStoryTableViewCell.swift
//  Stocks
//
//  Created by Anh Dinh on 8/24/21.
//

import UIKit
import SDWebImage

class NewsStoryTableViewCell: UITableViewCell {
    static let identifier = "NewsStoryTableViewCell"
    
    static let preferredHeight: CGFloat = 140
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: URL?
        
        /*
         Có nghĩa là khi ta call cell.configure(), parameter ta muốn sẽ là ViewModel, nhưng ViewModel này sẽ lấy info từ NewsStory object.
         **/
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            // convert TimeInterval from JSON to String using extension
            self.dateString = .string(from: model.datetime)
            self.imageUrl = URL(string: model.image)
        }
    }

//MARK: - Variable
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .blue
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .gray
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.backgroundColor = .red
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private let storyImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .white
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 6
        image.layer.masksToBounds = true
        return image
    }()

//MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemGreen
        backgroundColor = .systemGreen
        addSubviews(sourceLabel,headlineLabel,dateLabel,storyImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height - 6
        storyImageView.frame = CGRect(x: contentView.width - imageSize - 10,
                                      y: 3,
                                      width: imageSize,
                                      height: imageSize)
        
        // dateLabel
        let availableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 15
        dateLabel.frame = CGRect(x: separatorInset.left,
                                 y: contentView.height - 40,
                                 width: availableWidth,
                                 height: 40)
        
        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(x: separatorInset.left,
                                 y: 4,
                                 width: availableWidth,
                                 height: sourceLabel.height)
        
        headlineLabel.frame = CGRect(x: separatorInset.left,
                                     y: sourceLabel.bottom + 5,
                                     width: availableWidth,
                                     height: contentView.height - sourceLabel.bottom - dateLabel.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }

//MARK: - Function
    public func configure(with viewModel: ViewModel){
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        storyImageView.sd_setImage(with: viewModel.imageUrl, completed: nil)
    }
}
