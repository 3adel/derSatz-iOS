//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

protocol DataClient {
    func translate(_ sentence: String, to: Language, completion: @escaping ResultHandler)
    func translate(_ sentences: [String], to: Language, completion: @escaping ResultHandler)
    func getArticle(at url: String, completion: @escaping (AnyResult) -> Void)
    func cancelAllOperations()
}
