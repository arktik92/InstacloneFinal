//
//  StoryView.swift
//  Instaclone
//
//  Created by Esteban SEMELLIER on 20/05/2025.
//


import SwiftUI

struct StoryView: View {
    @ObservedObject var viewModel: StoryViewModel
    let storyItems: [(user: User, story: Story, state: UserStoryState)]
    @State var currentIndex: Int
    @Binding var isPresented: Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var longPressActive = false
    @State private var isLoading = true
    @State private var heartScale: CGFloat = 1.0
    @State private var showHeartAnimation = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let url = viewModel.story.currentImageURL {
                GeometryReader { geometry in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                                .onAppear {
                                    isLoading = true
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .onAppear {
                                    isLoading = false
                                    viewModel.refreshLikeState()
                                }
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                                .onAppear {
                                    isLoading = false
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .opacity(longPressActive ? 0.5 : 1.0)
                    .offset(dragOffset)
                }
            }
            
            if showHeartAnimation {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .opacity(showHeartAnimation ? 1.0 : 0)
            }
            
            VStack(spacing: 0) {
                StoryProgressView(
                    totalStories: viewModel.story.imageURLs.count,
                    currentIndex: viewModel.story.currentIndex,
                    progress: viewModel.progress
                )
                
                HStack {
                    StoryAvatarView(
                        user: viewModel.user,
                        state: viewModel.state,
                        size: 40
                    )
                    
                    Text(viewModel.user.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        viewModel.togglePlayPause()
                    } label: {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                HStack {
                    Button {
                        likeStory()
                    } label: {
                        Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isLiked ? .red : .white)
                            .font(.system(size: 24))
                            .frame(width: 60, height: 60)
                            .scaleEffect(heartScale)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.leading)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .opacity(isLoading ? 0.7 : 1.0)
            
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.previousStory()
                    }
                    .frame(width: UIScreen.main.bounds.width / 3)
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        doubleTapAction()
                    }
                    .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                        withAnimation {
                            longPressActive = pressing
                            viewModel.isPlaying = !pressing
                        }
                    }, perform: {})
                    .frame(width: UIScreen.main.bounds.width / 3)
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.nextStory()
                    }
                    .frame(width: UIScreen.main.bounds.width / 3)
            }
            .frame(height: UIScreen.main.bounds.height * 0.8)
            .offset(y: -60)
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if viewModel.isPlaying {
                        viewModel.togglePlayPause()
                    }
                    
                    if abs(gesture.translation.height) > abs(gesture.translation.width) {
                        dragOffset = gesture.translation
                    } else {
                        dragOffset = CGSize(
                            width: gesture.translation.width * 0.2,
                            height: 0
                        )
                    }
                }
                .onEnded { gesture in
                    if !viewModel.isPlaying {
                        viewModel.togglePlayPause()
                    }
                    
                    if gesture.translation.height > 100 {
                        closeStory()
                    }
                    else if gesture.translation.width < -50 && currentIndex < storyItems.count - 1 {
                        handleTransition(toNext: true)
                    }
                    else if gesture.translation.width > 50 && currentIndex > 0 {
                        handleTransition(toNext: false)
                    }
                    else {
                        withAnimation(.interactiveSpring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .onAppear {
            viewModel.startTimer()
            viewModel.refreshLikeState()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onChange(of: viewModel.shouldMoveToNextUser) { shouldMove in
            if shouldMove {
                handleUserChange()
            }
        }
    }
    
    private func closeStory() {
        viewModel.stopTimer()
        
        withAnimation(.easeInOut(duration: 0.2)) {
            dragOffset = CGSize(width: 0, height: 500)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
    
    private func likeStory() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            heartScale = 1.3
            viewModel.toggleLike()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    heartScale = 1.0
                }
            }
        }
    }
    
    private func doubleTapAction() {
        if !viewModel.isLiked {
            viewModel.toggleLike()
        }
        
        showLikeAnimation()
    }
    
    private func showLikeAnimation() {
        showHeartAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                showHeartAnimation = false
            }
        }
    }
    
    private func handleTransition(toNext: Bool) {
        withAnimation {
            dragOffset = .zero
            
            if toNext {
                currentIndex += 1
            } else {
                currentIndex -= 1
            }
            
            updateViewModel()
        }
    }
    
    private func updateViewModel() {
        let item = storyItems[currentIndex]
        viewModel.user = item.user
        viewModel.story = item.story
        viewModel.state = item.state
        viewModel.startTimer()
        viewModel.refreshLikeState()
    }
    
    private func handleUserChange() {
        viewModel.resetShouldMoveToNextUser()
        
        if viewModel.story.currentIndex >= viewModel.story.imageURLs.count - 1 {
            if currentIndex < storyItems.count - 1 {
                handleTransition(toNext: true)
            } else {
                closeStory()
            }
        }
        else if viewModel.story.currentIndex <= 0 {
            if currentIndex > 0 {
                withAnimation {
                    currentIndex -= 1
                    
                    let previousItem = storyItems[currentIndex]
                    viewModel.user = previousItem.user
                    viewModel.story = previousItem.story
                    viewModel.state = previousItem.state
                    viewModel.story.currentIndex = previousItem.story.imageURLs.count - 1
                    viewModel.startTimer()
                    viewModel.refreshLikeState()
                }
            }
        }
    }
}

#Preview {
    if let url = URL(string: "https://i.pravatar.cc/300?u=1") {
        let user = User(id: 1, name: "Neo", profilePictureURL: url)
        let imageURLs = [URL(string: "https://picsum.photos/400/800?random=1")!]
        let story = Story(userId: 1, imageURLs: imageURLs)
        let state = UserStoryState(userId: 1, seen: false, liked: false, lastViewedIndex: 0)
        
        return StoryView(
            viewModel: StoryViewModel(user: user, story: story, state: state),
            storyItems: [(user: user, story: story, state: state)],
            currentIndex: 0,
            isPresented: .constant(true)
        )
    } else {
        return Text("Erreur de prévisualisation")
    }
}
