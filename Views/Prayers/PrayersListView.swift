//
//  PrayersListView.swift
//  ThirdCounselor
//
//  Created by Dean Wagstaff on 8/24/23.
//

import SwiftUI

struct PrayersListView: View, AddButtonDelegate {
    @Environment(\.branding) var branding
    
    @ObservedObject var membersViewModel: MembersViewModel
    @ObservedObject var viewModel: PrayersViewModel
    
    @State private var showCloseButton = true
    @State private var memberName = ""
    @State private var alphaToMember = [String]()
    @State private var scrollTarget: String?
    @State private var filterSelection = "History"
    @State private var showAddToViewModel: Bool
    @State private var showAddItemButton: Bool
    @State private var currentInvocation = ""
    @State private var currentBenediction = ""
    
    var headingTitleTopPadding: CGFloat {
        if filterSelection == "History" {
            return CGFloat(0)
        }
        
        return(-50)
    }
    
    var currentOrNextWeekPrayersFrameHeight: CGFloat {
        if filterSelection == "History" {
            return CGFloat(0)
        }
        
        return(632)
    }
    
    let filters = ["History", "Current"]
    
    init(membersViewModel: MembersViewModel,
         viewModel: PrayersViewModel,
         showCloseButton: Bool = true,
         showAddToViewModel: Bool = false,
         showAddItemButton: Bool = false,
         currentInvocation: String = "",
         currentBenediction: String = "") {
        self.membersViewModel = membersViewModel
        self.viewModel = viewModel
        self.showCloseButton = showCloseButton
        self.showAddItemButton = showAddItemButton
        self.currentInvocation = currentInvocation
        self.currentBenediction = currentBenediction
        self.showAddToViewModel = showAddToViewModel
        
        self.viewModel.addButtonDelegate = self
    }
    
    var currentOrNextWeekPrayers: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Current/Next Sunday's")
                .customText(color: branding.labels,
                            font: branding.paragraphTextAndLinks_Semibold_17pt,
                            btmPad: 0,
                            topPad: -60,
                            leadPad: 0,
                            trailPad: 0,
                            width: .infinity,
                            alignment: .center)
                .underline()
            HStack(spacing: 40) {
                Text("Invocation:")
                    .customText(color: branding.labels,
                                font: branding.paragraphTextAndLinks_Semibold_17pt,
                                btmPad: 0,
                                topPad: 0,
                                leadPad: 450,
                                trailPad: 0,
                                width: .infinity,
                                alignment: .leading)
                
                Text("Benediction:")
                    .customText(color: branding.labels,
                                font: branding.paragraphTextAndLinks_Semibold_17pt,
                                btmPad: 0,
                                topPad: 0,
                                leadPad: 0,
                                trailPad: 0,
                                width: .infinity,
                                alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 40) {
                Text($viewModel.invocation.wrappedValue)
                    .customText(color: branding.contentTextColor,
                                font: branding.paragraphTextAndLinks_Regular_17pt,
                                btmPad: 0,
                                topPad: 0,
                                leadPad: 450,
                                trailPad: 0,
                                width: .infinity,
                                alignment: .leading)
                
                Text($viewModel.benediction.wrappedValue)
                    .customText(color: branding.contentTextColor,
                                font: branding.paragraphTextAndLinks_Regular_17pt,
                                btmPad: 0,
                                topPad: 0,
                                leadPad: 0,
                                trailPad: 0,
                                width: .infinity,
                                alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onViewDidLoad {
            viewModel.showAddPrayerView = false
        }
    }
    
    var body: some View {
        VStack {
            ListHeaderView(headingTitle: ListHeadingTitles.prayers.rawValue,
                           showCloseButton: $showCloseButton,
                           isInnerListHeader: .constant(false),
                           showConfirmDeleteOrganization: .constant(false),
                           membersViewModel: membersViewModel,
                           prayersViewModel: viewModel,
                           backgroundClr: branding.backgroundColor,
                           addButtonAction: {_ in })
            
            Picker("Prayer Filters", selection: $filterSelection) {
                ForEach(filters, id:\.self) {
                    Text($0)
                        .customText(color: branding.destructiveButton,
                                    font: branding.paragraphTextAndLinks_Semibold_17pt,
                                    btmPad: 0,
                                    topPad: 0,
                                    leadPad: 0,
                                    trailPad: 0,
                                    width: .infinity,
                                    alignment: .leading)
                }
            }
            .padding([.leading, .trailing], 20)
            .pickerStyle(.segmented)
            
            if filterSelection == "History" {
                NavigationView {
                    List(viewModel.disclosureGroupSectionTitles, id: \.self) {  sectionTitle in
                        CustomDisclosureGroupView(isExpanded: false,
                                                  prayers: viewModel.getPrayers(for: sectionTitle),
                                                  sectionTitle: sectionTitle,
                                                  headingTitles: viewModel.disclosureGroupColumnHeadings,
                                                  contentType: .prayers)
                    }
                    .listStyle(SidebarListStyle())
                    .navigationBarTitleDisplayMode(.automatic)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .onViewDidLoad {
                    viewModel.showAddPrayerView = false
                }
                .onAppear {
                    viewModel.fetchData {
                        viewModel.filterPrayers()
                        
                        sortPrayers()
                        
                        viewModel.getCurrentOrNextPrayers {
                            viewModel.getMembersGivingCurrentOrNextSundaysPrayByType()
                        }
                    }
                }
                .padding([.leading, .trailing], 10)
                .cornerRadius(25.0)
            } else {
                NavigationView {
                    currentOrNextWeekPrayers
                        .frame(height: currentOrNextWeekPrayersFrameHeight)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .padding([.leading, .trailing], 10)
                .cornerRadius(25.0)
            }
        }
        
        if viewModel.showAddPrayerView {
            BottomSheetView(isOpen: $viewModel.showAddPrayerView, maxHeight: UIScreen.main.bounds.height * 0.40) {
                AddPrayerView(membersViewModel: membersViewModel,
                              viewModel: PrayersViewModel.shared,
                              currentInvocation: .constant(""),
                              currentBenediction: .constant(""), addPrayersActionHandler: { prayers in
                    
                })
                .background(.white)
                .preferredColorScheme(.light)
                .environment(\.colorScheme, .light)
            }
            .cornerRadius(25.0)
            .environment(\.colorScheme, .light)
        }
    }
    
    func addButtonAction() {
        viewModel.showAddPrayerView = true
    }
    
    //MARK: functions
    
    private func searchForMember(_ txt: String) -> Bool {
        return (txt.lowercased(with: .current).hasPrefix(memberName.lowercased(with: .current)) || memberName.isEmpty)
    }
    
    private func searchForSection(_ txt: String) -> Bool {
        return (txt.prefix(1).lowercased(with: .current).hasPrefix(memberName.prefix(1).lowercased(with: .current)) || memberName.isEmpty)
    }
    
    func sortPrayers() {
        viewModel.prayers = viewModel.prayers.sorted { prayer, prayer in
            prayer.name < prayer.name
        }
    }
}
