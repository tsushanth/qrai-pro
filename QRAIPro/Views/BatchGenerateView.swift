// BatchGenerateView.swift
// QRAI Pro

import SwiftUI
import SwiftData

struct BatchGenerateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PremiumManager.self) private var premiumManager
    @State private var viewModel = BatchGenerateViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.items.isEmpty {
                    emptyState
                } else {
                    itemsList
                }
            }
            .navigationTitle("Batch Generate")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.showAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.items.isEmpty {
                        Button("Clear All", role: .destructive) {
                            viewModel.clearAll()
                        }
                        .tint(.red)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddItem) {
                addItemSheet
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Batch Generate")
                .font(.title2.bold())
            Text("Add multiple items to generate QR codes at once")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: { viewModel.showAddItem = true }) {
                Label("Add Item", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 80)
            Spacer()
        }
    }

    private var itemsList: some View {
        VStack(spacing: 0) {
            List {
                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                    BatchItemRow(item: item)
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.removeItem(at: index)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)

            // Progress
            if viewModel.isGenerating {
                ProgressView(value: viewModel.progress)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
            }

            // Actions
            VStack(spacing: 10) {
                Button(action: {
                    Task { await viewModel.generateAll() }
                }) {
                    HStack {
                        if viewModel.isGenerating {
                            ProgressView().tint(.white)
                        }
                        Text(viewModel.isGenerating ? "Generating \(viewModel.completedCount)/\(viewModel.items.count)..." : "Generate All")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.canGenerate && !viewModel.isGenerating ? AppConstants.Colors.gradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!viewModel.canGenerate || viewModel.isGenerating)

                if !viewModel.generatedImages.isEmpty {
                    Button(action: { viewModel.saveAll(to: modelContext) }) {
                        Label("Save All to History", systemImage: "square.and.arrow.down")
                            .font(.headline)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    private var addItemSheet: some View {
        NavigationStack {
            Form {
                Section("Content") {
                    Picker("Type", selection: $viewModel.newItemType) {
                        ForEach(QRType.allCases.filter { !$0.isPremium || premiumManager.isPremium }) { type in
                            Label(type.displayName, systemImage: type.icon).tag(type)
                        }
                    }
                    TextField("Content", text: $viewModel.newItemContent)
                        .autocorrectionDisabled()
                    TextField("Label (optional)", text: $viewModel.newItemTitle)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { viewModel.showAddItem = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        viewModel.addItem()
                    }
                    .disabled(viewModel.newItemContent.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct BatchItemRow: View {
    let item: BatchQRItem

    var body: some View {
        HStack(spacing: 12) {
            if let image = item.generatedImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: item.qrType.icon)
                    .foregroundStyle(item.qrType.color)
                    .frame(width: 44, height: 44)
                    .background(item.qrType.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(item.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            statusIcon(for: item.status)
        }
    }

    @ViewBuilder
    private func statusIcon(for status: BatchItemStatus) -> some View {
        switch status {
        case .pending:
            Image(systemName: "clock")
                .foregroundStyle(.secondary)
        case .generating:
            ProgressView()
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        }
    }
}
