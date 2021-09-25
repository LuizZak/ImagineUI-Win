internal extension Array where Element: AnyObject {
    mutating func remove(_ element: Element) {
        removeAll(where: { $0 === element })
    }
}
