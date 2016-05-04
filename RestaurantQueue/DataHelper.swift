import Foundation

class DataHelper {
    
    private static var baseUrl = "http://robertmasen.pizza/api/RestaurantQueue"
    
    static func requestReservations(completionHandler: (reservations: [Reservation]?, error: ErrorType?) -> ()) {
        let nsURL = NSURL(string: baseUrl)
        let request = NSMutableURLRequest(URL: nsURL!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, res, err in
            if let responseData = data {
                let dict = processResponse(responseData)
                let reservations = processDict(dict)
                completionHandler(reservations: reservations, error: err)
            }
        }
        task.resume()
        
    }
    
    static func processResponse(data: NSData) -> [Int:[String]] {
        var reservations = [Int: [String]]()
        if let responseString = String(data: data, encoding: 8) {
            let lines = responseString.componentsSeparatedByString("\n")
            for line in lines {
                var id: Int?
                let splitLine = line.componentsSeparatedByString(",")
                for component in splitLine {
                    if component.containsString("id:") && !component.containsString("isReady") {
                        let idString = component.componentsSeparatedByString(":")[1]
                        id = Int(idString)
                        reservations[id!] = [String]()
                    } else if component.containsString("time") {
                        let timeArray = component.componentsSeparatedByString(":")
                        let time = "\(timeArray[1]):\(timeArray[2]):\(timeArray[3])"
                        reservations[id!]?.append(time)
                    } else if component.containsString(":") {
                        let element = component.componentsSeparatedByString(":")[1]
                        reservations[id!]?.append(element)
                    }
                }
            }
        }
        return reservations
    }

    static func processDict(dict: [Int:[String]]) -> [Reservation] {
        var reservations = [Reservation]()
        for (key, value) in dict {
            let name = value[0]
            let size = Int(value[1])
            let stripedTime = value[2].componentsSeparatedByString(" ")
            let formatter = NSDateFormatter()
            let combinedTime = stripedTime[0] + " " + stripedTime[1]
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let ready = value[3] == "true"
            //the server calculates the time GMT, this corrects for that
            let arrivalTime = formatter.dateFromString(combinedTime)?.dateByAddingTimeInterval(-18000)
            
            
            let reservation = Reservation(id: key, name: name, size: size!, arrivalTime: arrivalTime!, isReady: ready)
            reservation.id = key
            reservations.append(reservation)
        }
        return reservations
    }
    
    static func postReservation(name: String, partySize: Int, completionHandler: (reservations: [Reservation]?, error: ErrorType?) -> ()) {
        let urlString = baseUrl+"/\(name)/\(partySize)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, res, err in
            let dict = processResponse(data!)
            let reservations = processDict(dict)
            completionHandler(reservations: reservations, error: err)
        }
        task.resume()
    }
    
    static func seatReservation(id: Int, completionHandler: (reservations: [Reservation]?, error: ErrorType?) -> ()) {
        let urlString = baseUrl+"/seat/\(id)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, res, err in
            let dict = processResponse(data!)
            let reservations = processDict(dict)
            completionHandler(reservations: reservations, error: err)
        }
        task.resume()
    }
    
    static func removeReservation(id: Int, completionHandler: (reservations: [Reservation]?, error: ErrorType?) -> ()) {
        let urlString = baseUrl+"/remove/\(id)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, res, err in
            let dict = processResponse(data!)
            let reservations = processDict(dict)
            completionHandler(reservations: reservations, error: err)
        }
        task.resume()

    }
}

enum Error: ErrorType {
    case ResponseError
}