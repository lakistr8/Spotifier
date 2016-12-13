import Foundation
import CoreData

@objc(Track)
public class Track: ManagedObject {
    
    // MARK: - Life cycle methods
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init?(managedObjectContext moc: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Track.entityName, in: moc) else { return nil }
        super.init(entity: entity, insertInto: moc)
    }
}


extension Track {
    
    convenience init?(json: JSON, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        do {
            guard let trackId = json["id"] as? String else { throw DataImportError.typeMismatch(expected: String.self, actual: type(of: json["id"]), key: "id") }
            guard let name = json["name"] as? String else { throw DataImportError.typeMismatch(expected: String.self, actual: type(of: json["name"]), key: "name") }
            
            self.trackId = trackId
            self.name = name
            
            if let discNum = json["disc_number"] as? Int16 {
                self.discNumber = discNum
            }
            if let durationMilliseconds = json["duration_ms"] as? Int64 {
                self.durationMilliseconds = durationMilliseconds
            }
            
        } catch(let error) {
            switch error {
            case is DataImportError:
                print(error)
            default:
                print("some other error")
            }
            
            //	if processing fails, then throw it out
            context.delete(self)
        }
    }
}
