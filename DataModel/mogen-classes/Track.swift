import Foundation
import CoreData

@objc(Track)
public class Track: ManagedObject {

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

	required public init?(managedObjectContext moc: NSManagedObjectContext) {
		guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: moc) else { return nil }
		super.init(entity: entity, insertInto: moc)
	}
}
