import UIKit
import LinkPresentation

class LinkPresentationItemSource: NSObject, UIActivityItemSource {
    var linkMetaData = LPLinkMetadata()
    
    //Prepare data to share
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return linkMetaData
    }
    
    //Placeholder for real data, we don't care in this example so just return a simple string
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Placeholder"
    }
    
    /// Return the data will be shared
    /// - Parameters:
    ///   - activityType: Ex: mail, message, airdrop, etc..
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return linkMetaData.originalURL
    }
    
    init(metaData: LPLinkMetadata) {
        self.linkMetaData = metaData
    }
    
    static func metaData(title: String, url: URL, fileName: String, fileType: String) -> LPLinkMetadata {
        let linkMetaData = LPLinkMetadata()
        let path = Bundle.main.path(forResource: fileName, ofType: fileType)
        linkMetaData.imageProvider = NSItemProvider(contentsOf: URL(fileURLWithPath: path ?? ""))
        linkMetaData.originalURL = url
        linkMetaData.title = title
        return linkMetaData
    }
}
