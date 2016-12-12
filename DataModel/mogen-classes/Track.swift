import Foundation
import CoreData

@objc(Track)
public class Track: ManagedObject {
    
    enum Attributes: String {
        
        case name
        
    }
}


extension Track {
    
    convenience init?(json: [String: Any], in context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = (json["name"] as? String) ?? ""
        if let discNum = json["disc_number"] as? Int16 {
            self.discNumber = discNum
        }
    }
}


// MARK: - Life cycle methods

extension Track {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init?(managedObjectContext moc: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: moc) else { return nil }
        super.init(entity: entity, insertInto: moc)
    }
    
}
