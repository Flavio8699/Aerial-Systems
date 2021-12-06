//
//  MissionHistory.swift
//  Aerial Systems
//
//  Created by Flavio Matias on 19/11/2021.
//

import SwiftUI

struct MissionHistory: View {
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        ScrollView (.vertical) {
            if let user = session.user {
                VStack (spacing: 20) {
                    if session.loadingMissions {
                        ProgressView("Loading missions ...")
                    } else {
                        ForEach (user.getMissions(), id: \.id) { mission in
                            MissionHistoryRowView(mission: mission)
                        }
                    }
                }.padding(20)
            }
        }
        .navigationTitle("Mission history")
    }
}
