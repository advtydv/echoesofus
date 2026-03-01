import SwiftUI

struct ConversationSimView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showTypingIndicator = false
    @State private var showCharacterLine = false
    @State private var showOptions = false
    @State private var chatHistory: [ChatBubble] = []
    @State private var optionAppearFlags: [Bool] = []

    var body: some View {
        StageShell(
            title: "Echo Chamber",
            subtitle: "Apply your phrases in a realistic conversation."
        ) {
            if appState.isConversationComplete {
                summaryCard
            } else if let conv = appState.currentConversation {
                scenarioHeader(conv)
                chatArea
                turnControls
            } else {
                noDataCard
            }
        }
        .onAppear {
            if !appState.isConversationComplete {
                presentTurn()
            }
        }
        .onChange(of: appState.conversationTurnIndex) { _, _ in
            presentTurn()
        }
    }

    private func scenarioHeader(_ conv: Conversation) -> some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(palette.badgeBackground)
                        .frame(width: 46, height: 46)
                    Image(systemName: conv.characterIcon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(palette.badgeIcon)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(conv.characterName)
                        .font(.headline)
                        .foregroundStyle(palette.cardText)
                    Text(conv.scenarioTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(palette.cardSubtext)
                }

                Spacer()

                InlineBadge(
                    title: "Turn \(appState.conversationProgressLabel)",
                    systemImage: "bubble.left.and.bubble.right",
                    highContrast: appState.learnerProfile.highContrast
                )
            }

            Text(conv.scenarioContext)
                .font(.subheadline)
                .foregroundStyle(palette.cardSubtext)
                .readableText(appState.learnerProfile.readingSupport)
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Scenario: \(conv.scenarioTitle). \(conv.scenarioContext)")
    }

    private var chatArea: some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 10) {
            ForEach(chatHistory) { bubble in
                chatBubbleView(bubble, palette: palette)
            }

            if showTypingIndicator && !showCharacterLine {
                typingIndicator
                    .transition(.opacity)
            }

            if showCharacterLine, let turn = appState.currentConversationTurn {
                characterBubbleView(turn.characterLine, palette: palette)
                    .transition(.opacity.combined(with: .offset(y: 6)))
            }

            if let reaction = appState.conversationReaction {
                reactionBubbleView(reaction, palette: palette)
                    .transition(.opacity.combined(with: .offset(y: 6)))
            }
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
        .animation(appState.learnerProfile.focusMode ? nil : .easeOut(duration: 0.3), value: chatHistory.count)
        .animation(appState.learnerProfile.focusMode ? nil : .easeOut(duration: 0.3), value: showCharacterLine)
        .animation(appState.learnerProfile.focusMode ? nil : .easeOut(duration: 0.3), value: showTypingIndicator)
    }

    private var turnControls: some View {
        VStack(spacing: 10) {
            if showOptions, let turn = appState.currentConversationTurn,
               appState.conversationSelectedOptionID == nil {
                ForEach(Array(turn.options.enumerated()), id: \.element.id) { index, option in
                    if index < optionAppearFlags.count && optionAppearFlags[index] {
                        Button {
                            selectOption(option)
                        } label: {
                            HStack {
                                Text(option.nativeText)
                                Spacer()
                            }
                        }
                        .buttonStyle(
                            OptionChipStyle(
                                isSelected: false,
                                highContrast: appState.learnerProfile.highContrast
                            )
                        )
                        .transition(.opacity.combined(with: .offset(y: 8)))
                        .accessibilityLabel("Respond with: \(option.nativeText)")
                    }
                }
            }

            if appState.conversationSelectedOptionID != nil && appState.conversationReaction != nil {
                Button(isLastTurn ? "View results" : "Continue conversation") {
                    advanceTurn()
                }
                .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
                .accessibilityHint(isLastTurn ? "Shows conversation summary" : "Moves to the next turn")
            }
        }
    }

    private var summaryCard: some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 14) {
            Label("Conversation complete", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(palette.cardText)

            if let conv = appState.currentConversation {
                VStack(alignment: .leading, spacing: 8) {
                    summaryRow(title: "Scenario", value: conv.scenarioTitle, palette: palette)
                    summaryRow(title: "Turns completed", value: "\(conv.turns.count) / \(conv.turns.count)", palette: palette)
                    summaryRow(title: "Correct responses", value: "\(appState.conversationCorrectCount)", palette: palette)
                    summaryRow(title: "Conversation fluency", value: "\(Int((appState.conversationFluencyScore * 100).rounded()))%", palette: palette)
                }

                ConfidenceMeter(
                    confidence: appState.conversationFluencyScore,
                    highContrast: appState.learnerProfile.highContrast
                )
            }

            Button("Continue to reflection") {
                appState.advanceStep()
            }
            .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
            .accessibilityHint("Advances to the next step in the guided flow")
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private var noDataCard: some View {
        let palette = appState.learnerProfile.palette

        return VStack(alignment: .leading, spacing: 10) {
            Text("No conversation data available.")
                .foregroundStyle(palette.cardText)

            Button("Continue") {
                appState.advanceStep()
            }
            .buttonStyle(PrimaryActionButton(highContrast: appState.learnerProfile.highContrast))
        }
        .echoCard(highContrast: appState.learnerProfile.highContrast)
    }

    private func summaryRow(title: String, value: String, palette: EchoPalette) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
        .foregroundStyle(palette.cardText)
        .font(.subheadline)
    }

    private func characterBubbleView(_ text: String, palette: EchoPalette) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: appState.currentConversation?.characterIcon ?? "person.crop.circle.fill")
                .font(.caption)
                .foregroundStyle(palette.badgeIcon)
                .frame(width: 24, height: 24)
                .background(Circle().fill(palette.badgeBackground))

            Text(text)
                .font(.subheadline)
                .foregroundStyle(palette.cardText)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(palette.badgeBackground)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(appState.currentConversation?.characterName ?? "Character") says: \(text)")
    }

    private func chatBubbleView(_ bubble: ChatBubble, palette: EchoPalette) -> some View {
        Group {
            if bubble.isCharacter {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: appState.currentConversation?.characterIcon ?? "person.crop.circle.fill")
                        .font(.caption)
                        .foregroundStyle(palette.badgeIcon)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(palette.badgeBackground))

                    Text(bubble.text)
                        .font(.subheadline)
                        .foregroundStyle(palette.cardText)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(palette.badgeBackground)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                HStack {
                    Spacer()
                    Text(bubble.text)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(bubble.isCorrect ? EchoTheme.moss : EchoTheme.clay)
                        )
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func reactionBubbleView(_ text: String, palette: EchoPalette) -> some View {
        let isCorrect = appState.conversationTurnResults[appState.currentConversationTurn?.id ?? ""] ?? false
        let bgColor = isCorrect
            ? EchoTheme.moss.opacity(appState.learnerProfile.highContrast ? 0.3 : 0.12)
            : EchoTheme.clay.opacity(appState.learnerProfile.highContrast ? 0.3 : 0.12)

        return HStack(alignment: .top, spacing: 8) {
            Image(systemName: appState.currentConversation?.characterIcon ?? "person.crop.circle.fill")
                .font(.caption)
                .foregroundStyle(palette.badgeIcon)
                .frame(width: 24, height: 24)
                .background(Circle().fill(palette.badgeBackground))

            Text(text)
                .font(.subheadline)
                .italic()
                .foregroundStyle(palette.cardText)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(bgColor)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reaction: \(text)")
    }

    private var typingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(appState.learnerProfile.highContrast ? Color.white.opacity(0.7) : EchoTheme.clay.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(showTypingIndicator ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.15),
                        value: showTypingIndicator
                    )
            }
        }
        .padding(10)
        .accessibilityLabel("\(appState.currentConversation?.characterName ?? "Character") is typing")
    }

    private var isLastTurn: Bool {
        guard let conv = appState.currentConversation else { return true }
        return appState.conversationTurnIndex >= conv.turns.count - 1
    }

    private func presentTurn() {
        showTypingIndicator = false
        showCharacterLine = false
        showOptions = false
        optionAppearFlags = []

        guard let turn = appState.currentConversationTurn else { return }

        if appState.learnerProfile.focusMode {
            showCharacterLine = true
            showOptions = true
            optionAppearFlags = Array(repeating: true, count: turn.options.count)
            return
        }

        Task { @MainActor in
            withAnimation { showTypingIndicator = true }

            try? await Task.sleep(for: .milliseconds(600))

            withAnimation(.easeOut(duration: 0.3)) {
                showTypingIndicator = false
                showCharacterLine = true
            }

            try? await Task.sleep(for: .milliseconds(300))
            showOptions = true
            optionAppearFlags = Array(repeating: false, count: turn.options.count)

            for i in turn.options.indices {
                try? await Task.sleep(for: .milliseconds(100))
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if i < optionAppearFlags.count {
                        optionAppearFlags[i] = true
                    }
                }
            }
        }
    }

    private func selectOption(_ option: ConversationOption) {
        guard let turn = appState.currentConversationTurn else { return }

        chatHistory.append(ChatBubble(
            id: "char_\(turn.id)",
            text: turn.characterLine,
            isCharacter: true,
            isCorrect: true
        ))

        chatHistory.append(ChatBubble(
            id: "user_\(turn.id)",
            text: option.nativeText,
            isCharacter: false,
            isCorrect: option.isCorrect
        ))

        showCharacterLine = false
        showOptions = false

        appState.submitConversationOption(option.id)
    }

    private func advanceTurn() {
        if let reaction = appState.conversationReaction,
           let turnID = appState.currentConversationTurn?.id {
            chatHistory.append(ChatBubble(
                id: "reaction_\(turnID)",
                text: reaction,
                isCharacter: true,
                isCorrect: true
            ))
        }

        appState.advanceConversationTurn()
    }
}

private struct ChatBubble: Identifiable {
    let id: String
    let text: String
    let isCharacter: Bool
    let isCorrect: Bool
}
