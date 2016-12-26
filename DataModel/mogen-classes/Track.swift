import Foundation
import CoreData

@objc(Track)
public final class Track: ManagedObject {
    
    // MARK: - Life cycle methods
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init?(managedObjectContext moc: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Track.entityName, in: moc) else { return nil }
        super.init(entity: entity, insertInto: moc)
    }
}

extension Track: JSONProcessing {
    
    static func make(with json: JSON, into context: NSManagedObjectContext) -> Self? {
        let mo = self.init(context: context)
        
        do {
            try mo.update(with: json)
            return mo
            
        } catch(let error) {
            switch error {
            case is DataImportError:
                print(error)
            default:
                print("some other error")
            }
            
            //	if processing fails, then throw it out
            context.delete(mo)
            return nil
        }
    }
    
    func update(with json: JSON) throws {
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
        
        if let arr = json["available_markets"] as? [String] {
            self.csvAvailableMarkets = arr.joined(separator: ",")
        }
        
        if let images = json["images"] as? [JSON], let url = images.first?["url"] as? String {
            self.imageLink = url
        }
        
        if let b = json["explicit"] as? Bool {
            self.isExplicit = b
        }
        
        if let num = json["track_number"] as? Int16 {
            self.trackNumber = num
        }
        
        if let uri = json["uri"] as? String {
            self.spotifyURI = uri
        }
        
        //		self.album..?
    }
}


