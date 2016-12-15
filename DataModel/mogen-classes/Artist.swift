import Foundation
import CoreData

@objc(Artist)
public final class Artist: ManagedObject {
    
    // MARK: - Life cycle methods
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init?(managedObjectContext moc: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Artist.entityName, in: moc) else { return nil }
        super.init(entity: entity, insertInto: moc)
    }
}

extension Artist: JSONProcessing {
    
    convenience init?(json: JSON, in context: NSManagedObjectContext) {
        self.init(context: context)
        
        do {
            try update(with: json)
            
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
    
    func update(with json: JSON) throws {
        guard let artistId = json["id"] as? String else { throw DataImportError.typeMismatch(expected: String.self, actual: type(of: json["id"]), key: "id") }
        guard let name = json["name"] as? String else { throw DataImportError.typeMismatch(expected: String.self, actual: type(of: json["name"]), key: "name") }
        
        self.artistId = artistId
        self.name = name
        
        //	..	go through all other properties
    }
}
