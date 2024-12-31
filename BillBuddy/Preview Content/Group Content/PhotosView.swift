//
//  PhotosView.swift
//  BillBuddy
//
//  Created by Michele Mariniello on 09/12/24.
//
import SwiftUI
import PhotosUI

struct PhotosView: View {
    @ObservedObject var groupStore: GroupsModel
    var group: Group
    @State private var cards: [String] = []
    @State private var cardToDelete: String? = nil
    @State private var showDeleteConfirmation = false
    @State private var showSheet = false
    @State private var newAlbumName = ""

    init(groupStore: GroupsModel, group: Group) {
        self.groupStore = groupStore
        self.group = group
        self._cards = State(initialValue: loadCards())
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    showSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
                .accessibilityHint("Button plus, Tap to add a new album")
                .padding()
            }
            .background(Color.accentColor5)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 15) {
                    ForEach(cards, id: \.self) { card in
                        NavigationLink(destination: AlbumDetailView(albumName: card)) {
                            VStack {
                                Text(card)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(width: 180, height: 180)
                                    .background(Color.accentColor3)
                                    .cornerRadius(15)
                                    .foregroundColor(.accentColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.accentColor, lineWidth: 2)
                                    )
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                cardToDelete = card
                                showDeleteConfirmation = true
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
        .background(Color.accentColor5.ignoresSafeArea())
        .confirmationDialog(
            "Are you sure you want to delete this card?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let card = cardToDelete {
                    deleteCard(card)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showSheet) {
            VStack {
                Text("Enter album name:")
                    .font(.headline)
                TextField("Album Name", text: $newAlbumName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Button("Cancel") {
                        showSheet = false
                    }
                    .padding()

                    Button("Save") {
                        addCard(with: newAlbumName)
                        showSheet = false
                    }
                    .padding()
                    .disabled(newAlbumName.isEmpty)
                }
            }
            .padding()
        }
    }

    func addCard(with name: String) {
        cards.append(name)
        updateGroupStore()
    }

    func deleteCard(_ card: String) {
        if let index = cards.firstIndex(of: card) {
            cards.remove(at: index)
            updateGroupStore()
        }
    }

    func updateGroupStore() {
        if let groupIndex = groupStore.groups.firstIndex(where: { $0.id == group.id }) {
            groupStore.groups[groupIndex].photos = cards
            saveCards()
        }
    }

    func saveCards() {
        UserDefaults.standard.set(cards, forKey: "Photos_\(group.id.uuidString)")
    }

    func loadCards() -> [String] {
        if let savedCards = UserDefaults.standard.array(forKey: "Photos_\(group.id.uuidString)") as? [String] {
            return savedCards
        }
        return []
    }
}

struct AlbumDetailView: View {
    let albumName: String
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false
    @State private var selectedSource: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }

            HStack {
                Button(action: {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        selectedSource = .camera
                        showImagePicker = true
                    } else {
                        // Notifica all'utente che la fotocamera non è disponibile.
                        print("Fotocamera non disponibile su questo dispositivo.")
                    }
                }) {
                    Label("Take Photo", systemImage: "camera")
                }
                .padding()
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                Button(action: {
                    selectedSource = .photoLibrary
                    showImagePicker = true
                }) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                }
                .padding()
            }

        }
        .navigationTitle(albumName)
        .onAppear(perform: loadImages)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: selectedSource) { image in
                if let image = image {
                    images.append(image)
                    saveImages()
                }
            }
        }
    }

    // Funzione per salvare immagini
    func saveImages() {
        let fileManager = FileManager.default
        let albumPath = getAlbumPath()

        if !fileManager.fileExists(atPath: albumPath.path) {
            try? fileManager.createDirectory(at: albumPath, withIntermediateDirectories: true)
        }

        for (index, image) in images.enumerated() {
            if let data = image.jpegData(compressionQuality: 0.8) {
                let fileURL = albumPath.appendingPathComponent("\(index).jpg")
                try? data.write(to: fileURL)
            }
        }
    }

    // Funzione per caricare immagini
    func loadImages() {
        let fileManager = FileManager.default
        let albumPath = getAlbumPath()

        if let files = try? fileManager.contentsOfDirectory(at: albumPath, includingPropertiesForKeys: nil) {
            images = files.compactMap { fileURL in
                if let data = try? Data(contentsOf: fileURL),
                   let image = UIImage(data: data) {
                    return image
                }
                return nil
            }
        }
    }

    // Percorso per salvare le immagini dell'album
    func getAlbumPath() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(albumName)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Assicuriamoci che il sourceType venga aggiornato correttamente.
        if uiViewController.sourceType != sourceType {
            uiViewController.sourceType = sourceType
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onImagePicked: (UIImage?) -> Void

        init(onImagePicked: @escaping (UIImage?) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            onImagePicked(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onImagePicked(nil)
            picker.dismiss(animated: true)
        }
    }
}


//struct PhotosView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotosView()
//    }
//}
