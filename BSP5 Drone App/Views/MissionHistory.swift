//
//  MissionHistory.swift
//  BSP5 Drone App
//
//  Created by Flavio Matias on 19/11/2021.
//

import SwiftUI

struct MissionHistory: View {
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        ScrollView (.vertical) {
            if let user = session.user {
                VStack (spacing: 30) {
                    ForEach (user.getMissions(), id: \.id) { mission in
                        MissionHistoryRowView(mission: mission)
                    }
                }.padding(30)
            }
        }
        .navigationTitle("Mission history")
    }
}

struct MissionHistory_Previews: PreviewProvider {
    static var previews: some View {
        MissionHistory()
    }
}
