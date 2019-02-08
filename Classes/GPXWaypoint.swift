//
//  GPXWaypoint.swift
//  GPXKit
//
//  Created by Vincent on 19/11/18.
//

import Foundation

open class GPXWaypoint: GPXElement {
    
    public var links = [GPXLink]()
    public var elevation: Double?
    public var time: Date?
    public var magneticVariation: Double?
    public var geoidHeight: Double?
    public var name: String?
    public var comment: String?
    public var desc: String?
    public var source: String?
    public var symbol: String?
    public var type: String?
    public var fix: Int?
    public var satellites: Int?
    public var horizontalDilution: Double?
    public var verticalDilution: Double?
    public var positionDilution: Double?
    public var ageofDGPSData: Double?
    public var DGPSid: Int?
    public var extensions: GPXExtensions?
    public var latitude: Double?
    public var longitude: Double?
    
    public var latitudeString = String()
    public var longitudeString = String()
    public var elevationString = String()
    public var timeString = String()
    public var magneticVariationString = String()
    public var geoidHeightString = String()
    public var fixString = String()
    public var satellitesString = String()
    public var hdopString = String()
    public var vdopString = String()
    public var pdopString = String()
    public var ageofDGPSDataString = String()
    public var DGPSidString = String()
    
    public required init() {
        self.time = Date()
        super.init()
    }
    
    public init(latitude: Double, longitude: Double) {
        self.time = Date()
        super.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    let waypointProcess = DispatchQueue(label: "pointTypeProcess", qos: .userInitiated, attributes: .concurrent)
    
    public init(dictionary: [String:String]) {
        self.time = ISO8601DateParser.parse(dictionary ["time"])
        super.init()
        waypointProcess.async(flags: .barrier) {
            self.elevation = self.number(from: dictionary["ele"])
            self.latitude = self.number(from: dictionary["lat"])
            self.longitude = self.number(from: dictionary["lon"])
            self.magneticVariation = self.number(from: dictionary["magvar"])
            self.geoidHeight = self.number(from: dictionary["geoidheight"])
            self.name = dictionary["name"]
            self.comment = dictionary["cmt"]
            self.desc = dictionary["desc"]
            self.source = dictionary["src"]
            self.symbol = dictionary["sym"]
            self.type = dictionary["type"]
            self.fix = self.integer(from: dictionary["fix"])
            self.satellites = self.integer(from: dictionary["sat"])
            self.horizontalDilution = self.number(from: dictionary["hdop"])
            self.verticalDilution = self.number(from: dictionary["vdop"])
            self.positionDilution = self.number(from: dictionary["pdop"])
            self.DGPSid = self.integer(from: dictionary["dgpsid"])
        }
    }
    
    // MARK:- Public Methods
   
    func number(from string: String?) -> Double? {
        guard let NonNilString = string else {
            return nil
        }
        return Double(NonNilString)
    }
    
    func integer(from string: String?) -> Int? {
        guard let NonNilString = string else {
            return nil
        }
        return Int(NonNilString)
    }
    
    open func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink().link(with: href)
        return link
    }
    
    open func add(link: GPXLink?) {
        if link != nil {
            let contains = links.contains(link!)
            if contains == false {
                link?.parent = self
                links.append(link!)
            }
        }
    }
    
    open func add(links: [GPXLink]) {
        for link in links {
            add(link: link)
        }
    }
    
    open func remove(Link link: GPXLink) {
        let contains = links.contains(link)
        
        if contains == true {
            link.parent = nil
            if let index = links.firstIndex(of: link) {
                links.remove(at: index)
            }
        }
    }

    // MARK:- Tag
    
    override func tagName() -> String! {
        return "wpt"
    }
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        
        if latitude != nil {
            attribute.appendFormat(" lat=\"%f\"", latitude!)
        }
        
        if longitude != nil {
            attribute.appendFormat(" lon=\"%f\"", longitude!)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forDoubleValue: elevation, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: GPXType().value(forDateTime: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: magneticVariation, gpx: gpx, tagName: "magvar", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: geoidHeight, gpx: gpx, tagName: "geoidheight", indentationLevel: indentationLevel)
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source, gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        
        for link in links {
            link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: symbol, gpx: gpx, tagName: "sym", indentationLevel: indentationLevel)
        self.addProperty(forValue: type, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        self.addProperty(forIntegerValue: fix, gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        self.addProperty(forIntegerValue: satellites, gpx: gpx, tagName: "sat", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: horizontalDilution, gpx: gpx, tagName: "hdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: verticalDilution, gpx: gpx, tagName: "vdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: positionDilution, gpx: gpx, tagName: "pdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: ageofDGPSData, gpx: gpx, tagName: "ageofdgpsdata", indentationLevel: indentationLevel)
        self.addProperty(forIntegerValue: DGPSid, gpx: gpx, tagName: "dgpsid", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}


// MARK:- Date Parser
// code from http://jordansmith.io/performant-date-parsing/
// edited for use in CoreGPX

class ISO8601DateParser {
    
    private static var calendarCache = [Int : Calendar]()
    private static var components = DateComponents()
    
    private static let year = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let month = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let day = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let hour = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let minute = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let second = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    
    static func parse(_ dateString: String?) -> Date? {
        guard let NonNilString = dateString else {
            return nil
        }
            _ = withVaList([year, month, day, hour, minute,
                            second], { pointer in
                                vsscanf(NonNilString, "%d-%d-%dT%d:%d:%dZ", pointer)
                                
            })
            
            components.year = year.pointee
            components.minute = minute.pointee
            components.day = day.pointee
            components.hour = hour.pointee
            components.month = month.pointee
            components.second = second.pointee
            
            if let calendar = calendarCache[0] {
                return calendar.date(from: components)
            }
            
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            calendarCache[0] = calendar
            return calendar.date(from: components)
        }
    
}

