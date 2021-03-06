import Foundation
import CoreData

@objc(Album)
public final class Album: ManagedObject {
    
    // MARK: - Life cycle methods
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required public init?(managedObjectContext moc: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Album.entityName, in: moc) else { return nil }
        super.init(entity: entity, insertInto: moc)
    }
}

extension Album: JSONProcessing {
    
    func update(with json: JSON) throws {
        guard let albumId = json["id"] as? String else { throw DataImportError.typeMismatch(expected: String.self, actual: type(of: json["id"]), key: "id") }
        guard let name = json["name"] as? String else { throw DataImportError.typeMismatch(expected: String.self, actual: type(of: json["name"]), key: "name") }
        
        self.albumId = albumId
        self.name = name
        
        if let arr = json["available_markets"] as? [String] {
            self.csvAvailableMarkets = arr.joined(separator: ",")
        }
        
        if let images = json["images"] as? [JSON], let url = images.first?["url"] as? String {
            self.imageLink = url
        }
        
        if let uri = json["uri"] as? String {
            self.spotifyURI = uri
        }
        
        if let str = json["label"] as? String {
            self.labelName = str
        }
        
        if let str = json["release_date"] as? String {
            self.dateReleased = DateFormatter.spotifyDayFormatter.date(from: str)
        }
        
        //		self.tracks..?
        //		self.artist..?
    }
}
