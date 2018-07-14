//
//  API.swift
//  Jane
//
//  Created by Rujal on 5/31/18.
//  Copyright © 2018 Nikunj. All rights reserved.
//

import UIKit

class API: NSObject {
    static var serverURL = "http://67.205.107.224:6223/jane"
    static var login = API.serverURL + "/mobile/signIn"
    static var beforeSigningUp = API.serverURL + "/mobile/beforeSigningUp"
    static var signUp = API.serverURL + "/mobile/signUp"
    static var profile = API.serverURL + "/mobile/profile?"
    static var notification = API.serverURL + "/mobile/notifications?"
    static var beforeEdit = API.serverURL + "/mobile/users/profile/beforeEdit"
    static var edit = API.serverURL + "/mobile/users/profile/edit"
    static var gradesInstances = API.serverURL + "/mobile/gradesInstances?"
    static var medals = API.serverURL + "/mobile/users/medals"
    static var payments = API.serverURL + "/mobile/users/payments"
    static var monthPayments = API.serverURL + "/mobile/users/payments/"
    static var monthEvents = API.serverURL + "/mobile/agenda/events?"
    static var agendaDetail = API.serverURL + "/mobile/agenda/events/"
    static var albums = API.serverURL + "/mobile/gallery/albums"
    static var photoList = API.serverURL + "/mobile/gallery/albums/"
    static var allPhoto = API.serverURL + "/mobile/gallery/albums/photos"
    static var recoveryPassword = API.serverURL + "/mobile/recoveryPassword?appHash=KSMRERN_OPD_2018_BSOFSTVRTYP&userName="
    static var news = API.serverURL + "/mobile/news"
    static var routine = API.serverURL + "/mobile/learners/"
    static var permissions = API.serverURL + "/mobile/users/permissions"
    static var routineAdd = API.serverURL + "/mobile/learners/"
    static var messages = API.serverURL + "/mobile/chat/messages"
    static var departmentMessages = API.serverURL + "/mobile/chat/departments/"
    static var educatorsMessages = API.serverURL + "/mobile/chat/educators/"
    static var educatorsList = API.serverURL + "/mobile/educators"
    
}
