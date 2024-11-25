
//

import UIKit
import SafariServices

class EOLItemViewController: UIViewController {

    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var licenseButton: UIButton!
    @IBOutlet var taxonomyLabel: UILabel!
    @IBOutlet var scientificNameLabel: UILabel!
    @IBOutlet var kingdomLabel: UILabel!
    @IBOutlet var phylumLabel: UILabel!
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var orderLabel: UILabel!
    @IBOutlet var familyLabel: UILabel!
    @IBOutlet var genusLabel: UILabel!
    @IBOutlet var attributionLabel: UILabel!
    
    var loadInfoTask: Task<Void, Never>? = nil
    
    let item: EOLItem
    var license: String? = nil
    
    init?(coder: NSCoder, item: EOLItem) {
        self.item = item
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = item.commonName
        
        loadInfoTask = Task {
            do {
                let itemDetailRequest = EOLItemDetailAPIRequest(item: item)
                let details = try await EOLController.shared.sendRequest(itemDetailRequest)
                
                let taxonConcept = details.details.taxonConcepts?.first
                let dataObject = details.details.dataObjects?.first
                
                async let hierarchy = classificationDetails(for: taxonConcept)
                async let image = image(for: dataObject)
                
                update(hierarchy: try await hierarchy, image: try await image)
                
                scientificNameLabel.text = details.details.scientificName
                taxonomyLabel.text = taxonConcept?.accordingTo ?? ""
                updateMediaDetail(with: dataObject)
                
                loadInfoTask = nil
            } catch {
                print(error)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadInfoTask?.cancel()
    }
    
    func update(hierarchy: EOLHierarchy?, image: UIImage?) {
        if let hierarchy = hierarchy {
            updateClassificationDetails(with: hierarchy)
        }
        if let image = image {
            imageView.image = image
        }
    }
    
    func classificationDetails(for taxonConcept: TaxonConcept?) async throws -> EOLHierarchy? {
        guard let taxonConcept = taxonConcept else {
            return nil
        }
        let hierarchyRequest = EOLHierarchyAPIRequest(identifier: taxonConcept.identifier)
        let hierarchy = try await EOLController.shared.sendRequest(hierarchyRequest)
        return hierarchy
    }
    
    func updateClassificationDetails(with hierarchy: EOLHierarchy) {
        if let ancestors = hierarchy.ancestors {
            kingdomLabel.text = ancestors.first(where: {$0.taxonRank == "kingdom"})?.scientificName
            phylumLabel.text = ancestors.first(where: {$0.taxonRank == "phylum"})?.scientificName
            classLabel.text = ancestors.first(where: { $0.taxonRank == "class" })?.scientificName
            orderLabel.text = ancestors.first(where: { $0.taxonRank == "order" })?.scientificName
            familyLabel.text = ancestors.first(where: { $0.taxonRank == "family" })?.scientificName
            genusLabel.text = ancestors.first(where: { $0.taxonRank == "gunus" })?.scientificName
        }
    }
    
    func image(for dataObject: DataObject?) async throws -> UIImage? {
        guard let mediaURL = dataObject?.eolMediaURL else {
            return nil
        }
        let imageRequest = EOLImageAPIRequest(url: mediaURL)
        let image = try await EOLController.shared.sendRequest(imageRequest)
        
        return image
    }
    
    func updateMediaDetail(with dataObject: DataObject?) {
        guard let dataObject = dataObject else { return }
        if let rightsHolder = dataObject.rightsHolder {
            attributionLabel.text = rightsHolder
        } else if let agent = dataObject.agents?.first {
            if let fullName = agent.fullName {
                if let role = agent.role {
                    attributionLabel.text = fullName + ", " + role
                } else {
                    attributionLabel.text = fullName
                }
            }
        }
        
        if let license = dataObject.license {
            self.license = license
            var config = UIButton.Configuration.plain()
            config.title = license
            config.buttonSize = .small
            config.titleAlignment = .trailing
            licenseButton.configuration = config
            licenseButton.isEnabled = true
        }
        
    }
    
    @IBAction func licenseButtonTapped(_ sender: Any) {
        if let licenseStr = license, let url = URL(string: licenseStr) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
}
