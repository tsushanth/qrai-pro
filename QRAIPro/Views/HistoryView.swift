// HistoryView.swift
// QRAI Pro

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanResult.scannedAt, order: .reverse) private var scanResults: [ScanResult]
    @Query(sort: \QRCodeItem.createdAt, order: .reverse) private var qrCodes: [QRCodeItem]
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("History", selection: $viewModel.selectedTab) {
                    ForEach(HistoryTab.allCases, id: \.self) { tab in
                        Label(tab.rawValue, systemImage: tab.icon).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                // Favorites toggle
                Toggle("Favorites Only", isOn: $viewModel.showFavoritesOnly)
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                // Content
                switch viewModel.selectedTab {
                case .scanned:
                    scannedList
                case .generated:
                    generatedList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search history...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            if viewModel.selectedTab == .scanned {
                                HistoryService.shared.clearAllScans(from: modelContext)
                            } else {
                                HistoryService.shared.clearAllQRCodes(from: modelContext)
                            }
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                AnalyticsService.shared.track(.historyViewed)
            }
        }
    }

    private var scannedList: some View {
        let filtered = viewModel.filteredScans(scanResults)
        return Group {
            if filtered.isEmpty {
                emptyState(
                    icon: "qrcode.viewfinder",
                    title: "No Scans Yet",
                    subtitle: "Start scanning QR codes and barcodes"
                )
            } else {
                List {
                    ForEach(filtered) { scan in
                        NavigationLink(destination: QRDetailView(scanResult: scan)) {
                            ScanHistoryRow(scan: scan)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteScan(scan, from: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.toggleFavorite(scan: scan, in: modelContext)
                            } label: {
                                Label(scan.isFavorite ? "Unfavorite" : "Favorite",
                                      systemImage: scan.isFavorite ? "heart.slash" : "heart")
                            }
                            .tint(.pink)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private var generatedList: some View {
        let filtered = viewModel.filteredCodes(qrCodes)
        return Group {
            if filtered.isEmpty {
                emptyState(
                    icon: "qrcode",
                    title: "No Generated Codes",
                    subtitle: "Create your first QR code"
                )
            } else {
                List {
                    ForEach(filtered) { code in
                        NavigationLink(destination: QRDetailView(qrCode: code)) {
                            GeneratedQRRow(code: code)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteQRCode(code, from: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.toggleFavorite(code: code, in: modelContext)
                            } label: {
                                Label(code.isFavorite ? "Unfavorite" : "Favorite",
                                      systemImage: code.isFavorite ? "heart.slash" : "heart")
                            }
                            .tint(.pink)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}
