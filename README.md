
### Flutter  Card Scanner App Documentation

#### Overview:
The Flutter Business Card Scanner app is designed to capture images of business cards, extract key details using Optical Character Recognition (OCR), and save the extracted information for future reference. The app is divided into three main screens:
1. **Card Capture**: Allows users to take a photo of a business card or select an image from their gallery.
2. **Card Details Extraction**: Displays the captured image and provides an option to extract the card's details such as name, phone number, and email.
3. **Saved Cards**: Shows all the previously saved cards with their extracted details.

#### Key Components:
1. **Card Capture Screen**:
    - Users can either use the camera to capture a photo of the business card or pick one from the device’s gallery.
    - The selected image is processed and passed to the next screen for OCR extraction.

2. **Card Details Extraction Screen**:
    - Once an image is selected, the app uses Google's ML Kit Text Recognition to extract text from the image.
    - Extracted text is parsed to detect key information such as name, phone number, and email address using regular expressions (regex).
    - A dialog box is presented to the user to confirm or select a name from the extracted text. This is necessary since detecting names via OCR can be unreliable.
    - After extracting and confirming the card details, they are saved and displayed on this screen.

3. **Saved Cards Screen**:
    - This screen lists all the saved business cards. Users can view the extracted details such as name, phone number, and email address.
    - The app uses a `ListView` to dynamically display all saved cards.
    - Cards are saved using shared preferences, ensuring persistence across app sessions.

#### Controllers and Logic:
1. **CardController**:
    - The `CardController` manages the business logic, including saving cards, handling OCR processing, and managing error states.
    - It uses `Rx` observables from the `GetX` package to manage the state of the app reactively, including:
        - `savedCards`: A list of all saved business card details.
        - `isProcessing`: A flag indicating whether the app is currently processing an image for OCR.
        - `errorMessage`: A string to display errors encountered during image processing or extraction.
        - `extractedCardDetails`: Stores the details of the currently extracted card.

2. **OCR Processing**:
    - The app uses Google's ML Kit's `TextRecognizer` to extract text from the image.
    - The extracted text is then parsed line by line. Regular expressions are used to detect phone numbers and email addresses.
    - The app then shows a dialog for the user to select a name from the text since OCR accuracy for names can vary.

3. **Error Handling**:
    - If no text or important details like phone or email are detected, appropriate error messages are displayed.
    - The app provides a dialog-based interface for users to select or correct missing details, particularly the name.

4. **Persistence**:
    - The extracted details are saved locally using shared preferences through a service class (`SharedPreferencesService`).
    - Each card's details are stored as a `CardDetails` object and retrieved when the app is reopened, ensuring data persistence.

#### UI Components:
1. **GradientText**:
    - A custom widget used to render text with a gradient effect, enhancing the visual appeal of the UI, especially in dialogs where the user selects the name.

2. **ContactCard**:
    - A reusable widget that displays the saved card details (name, phone number, and email) in the Saved Cards screen.

3. **Custom Dialog**:
    - A dialog box is used when selecting a name. It provides a list of possible name options extracted from the card, allowing users to manually choose the correct one.

#### Key Packages:
1. **GetX**:
    - Used for state management and navigation. The `GetX` package helps manage the app’s reactive state, making the app responsive to changes in data.

2. **Google ML Kit**:
    - Provides text recognition functionality, which is key for extracting text from the card images.

3. **Shared Preferences**:
    - Ensures persistence of saved cards between app sessions by storing and retrieving data locally.

#### Conclusion:
This Flutter Business Card Scanner app combines a simple UI with powerful backend logic using OCR, regex-based text extraction, and persistent local storage. It leverages the `GetX` package for state management, making the app responsive and easy to navigate. The ability to save and view extracted card details provides a convenient and user-friendly experience for managing business contacts.






### Documentation for `CardController` class

The `CardController` class in this Flutter project is responsible for managing the process of extracting text from an image (scanned business cards), processing the extracted details, and saving the card details using `GetX` for state management.

#### Properties:
- **`savedCards`**: An observable list of `CardDetails` that holds all saved business cards.
- **`isProcessing`**: An observable boolean that tracks whether the app is currently processing the image for text extraction.
- **`errorMessage`**: An observable string to store error messages.
- **`image`**: An observable that holds the selected image (as a `File`) for scanning.
- **`extractedCardDetails`**: An observable that holds the extracted details (`CardDetails`) of the current card.
- **`_prefsService`**: An instance of `SharedPreferencesService` used to store and retrieve card details from local storage.

#### Methods:

1. **`onInit()`**:
   - Called when the controller is initialized.
   - It loads saved cards from local storage into `savedCards`.

2. **`addCard(CardDetails card)`**:
   - Adds a new card to the `savedCards` list and saves it to local storage using `_prefsService`.

3. **`loadSavedCards()`**:
   - Loads all saved card details from local storage and assigns them to `savedCards`.

4. **`clearError()`**:
   - Clears the current error message by setting `errorMessage` to an empty string.

5. **`setError(String message)`**:
   - Sets a specific error message to `errorMessage`.

6. **`processImageForOCR()`**:
   - Processes the selected image for Optical Character Recognition (OCR) to extract text from the image.
   - Clears previously extracted details and error messages.
   - Uses Google’s ML Kit to recognize text in the image.
   - Extracts phone numbers and email addresses using regular expressions and allows the user to select the name from the recognized text.
   - Saves the successfully extracted card details to `savedCards` and updates the UI accordingly.
   - If extraction fails, an appropriate error message is shown.

7. **`extractDetailsFromText(String text)`**:
   - Takes the extracted text from the image and processes it to retrieve card details such as name, phone number, and email.
   - Uses regular expressions to find phone numbers and email addresses in the text.
   - Prompts the user to select a name from the available lines of text using a dialog.
   - Returns a `CardDetails` object if name, phone, and email are successfully extracted.

8. **`showNameSelectionDialog()`**:
   - Displays a dialog to allow the user to select a name from the extracted lines of text.
   - The user must select a name in order to save the card details.

#### Dependencies:
- **Google ML Kit**: Used for text recognition.
- **GetX**: Used for state management and navigation.
- **SharedPreferencesService**: For saving and loading card details to/from local storage.
- **Regular Expressions**: Used to extract phone numbers and email addresses from the text.

#### Usage:
This controller is meant to be used in a Flutter app that processes business cards. It allows users to:
- Pick an image for scanning.
- Extract relevant details (name, phone, email) using OCR.
- Select a name from the text and automatically save the card to local storage.




# VisitingCardScannerView Screen Documentation

## Overview
`VisitingCardScannerView` is a Flutter `StatelessWidget` that allows users to scan visiting cards by capturing images from either the camera or gallery, and also provides access to a screen where saved card details can be viewed. The widget is part of a multi-screen Flutter app, where the first screen is dedicated to selecting the source of the image (camera or gallery), and the second screen handles extracting details from the scanned image.

## Widget Structure

### Key Features:
- **Gradient Text**: Uses a custom `GradientText` widget to display text with a gradient color effect.
- **Image Picker**: Allows users to select an image either from the camera or gallery using the `image_picker` package.
- **Controller**: A `CardController` is used to manage state and handle logic like image picking and navigation.
- **GetX Integration**: The widget relies on `GetX` for state management and navigation between views.

### UI Components:
1. **Scan Button**: A button that lets users take a photo using the camera to scan a visiting card.
2. **Scan from Gallery Button**: A button that lets users pick an image from their gallery to scan a card.
3. **Saved Cards Button**: A button that navigates to a screen showing previously saved visiting card details.

### Gesture Detectors:
- **Camera Gesture Detector**: Triggers image capture from the camera.
- **Gallery Gesture Detector**: Allows selecting an image from the gallery.
- **Saved Cards Gesture Detector**: Navigates to a screen where users can view previously saved cards.

## Dependencies

### Packages Used:
- **image_picker**: To allow image selection from the camera or gallery.
- **GetX**: For state management and navigation between screens.
- **gradient_text**: Custom widget used for displaying text with a gradient color effect.

### Custom Files:
- **GradientText**: A custom widget for rendering gradient-colored text.
- **CardController**: Manages the image, handles errors, and stores extracted card details.
- **ExtractCardView**: The view for displaying the card image and performing OCR (Optical Character Recognition) to extract details.
- **SavedCardsView**: The view for showing all saved visiting card details.

## Methods

### `_pickImage(ImageSource source)`
This method is responsible for picking an image from the specified source (`camera` or `gallery`). It does the following:
- Clears any previously extracted card details.
- Opens the image picker to let the user select an image.
- Updates the `CardController` with the selected image.
- Clears any error messages.
- Navigates to the `ExtractCardView` screen where the image details will be processed.

### `build(BuildContext context)`
The main build method returns a `Scaffold` containing the layout with:
- A `SafeArea` widget for proper screen alignment.
- A `Container` for setting up the layout, padding, and alignment.
- A `Column` widget with buttons for scanning and navigating saved cards.

## Notes
- **Image Assets**: The widget assumes that there are assets named `scan.png` and `gallery.png` in the `assets/images/` folder for displaying scan and gallery icons respectively.
- **Navigation**: `GetX` is used for navigating between the current view, the `ExtractCardView` for extracting details, and the `SavedCardsView` for viewing saved details.

## Usage Example
VisitingCardScannerView();





# ExtractCardView Screen Documentation

## Overview
`ExtractCardView` is a Flutter `StatelessWidget` that allows users to view a scanned visiting card image and extract details such as the name, phone number, and email address using Optical Character Recognition (OCR). It interacts with a `CardController` (using `GetX` for state management) to handle the image processing and to display either the extracted details or error messages.

## Widget Structure

### Key Features:
- **Image Display**: Displays the image of the visiting card that was selected or captured on the previous screen.
- **Extract Button**: Users can click this button to initiate the OCR process to extract details from the card.
- **Loading Indicator**: Shows a `CircularProgressIndicator` while the OCR process is running.
- **Error Display**: Displays error messages in case something goes wrong during the OCR process.
- **Extracted Details Display**: Once the OCR process is successful, the extracted card details (name, phone, and email) are shown.
- **Navigation to Saved Cards**: A button allows users to navigate to the saved cards screen.

### UI Components:
1. **Picked Image**: The visiting card image selected by the user is displayed on the screen.
2. **Extract Button**: Displays a button that initiates the OCR process to extract details from the image.
3. **Processing Indicator**: If OCR is in progress, a circular loading indicator is displayed.
4. **Extracted Details**: Once the OCR process is complete, the extracted name, phone number, and email are shown inside a custom `ContactCard` widget.
5. **Error Message**: If an error occurs during the OCR process, a red error message is displayed.
6. **Saved Cards Button**: A button that allows the user to navigate to the screen displaying saved visiting card details.

### Gesture Detectors:
- **Extract Button Gesture Detector**: Triggers the OCR process when tapped.
- **Saved Cards Gesture Detector**: Navigates to the `SavedCardsView` to display saved card details.

## Dependencies

### Packages Used:
- **GetX**: For state management and navigation between views.
- **scancard/utils/contact_card.dart**: Custom widget for displaying the extracted contact details in a card format.
- **scancard/utils/gradient_text.dart**: Custom widget to display gradient-colored text.
- **CardController**: Manages the image processing, OCR extraction, and error handling.

### Custom Widgets:
- **ContactCard**: Used to display the name, phone number, and email in a card format after extraction.
- **GradientText**: Renders text with a gradient color effect.

## Methods

### `extractDetails()`
- This method triggers the `CardController` to process the selected image for OCR and extract the card details. It is an asynchronous operation and involves updating the UI with either the extracted details or an error message based on the result.

### `build(BuildContext context)`
The `build` method creates the UI of the `ExtractCardView` using the following structure:
- A `Scaffold` that defines the app's structure, including an `AppBar`.
- A `SingleChildScrollView` to ensure that the content scrolls if the screen is too small.
- A `Column` containing:
  - The picked image of the card.
  - The extract button or a loading indicator based on the current state.
  - The extracted card details (if available) or an error message.
  - A button to navigate to the `SavedCardsView`.

### Obx Reactive Listeners:
- **Image Display**: Reactively listens to `CardController.image.value` to show the selected card image.
- **Extract Button or Progress Indicator**: Based on the `CardController.isProcessing.value` state, it either shows the `Extract` button or a loading indicator.
- **Extracted Details or Error**: Reactively displays either the extracted details in the `ContactCard` widget or an error message depending on the state of the `CardController`.

## Notes
- The `CardController` handles all the logic for processing the image and extracting the card details using OCR.
- This widget assumes that a card image is available in the `CardController.image` when the user navigates to this view.
- The `Saved Cards` button navigates the user to a different view where previously saved cards are listed.

## Usage Example
ExtractCardView();
This will present the user with a UI to extract details from the selected visiting card image and display the extracted details or errors accordingly.






### Documentation for `SavedCardsView` class

The `SavedCardsView` class in this Flutter project is a stateless widget that displays all the saved business cards. It uses the `CardController` to retrieve and display the list of saved cards using `GetX` for state management.

#### Properties:
- **`cardController`**: An instance of `CardController` is obtained using `Get.find()`, which provides access to the saved cards managed by the controller.

#### Methods:

1. **`build(BuildContext context)`**:
   - This method builds the user interface of the `SavedCardsView`.
   - It returns a `Scaffold` widget containing an `AppBar` with the title "Saved Cards" and a body that observes the `savedCards` list from the `CardController`.

   - **Body**:
      - The body uses `Obx` to reactively rebuild whenever the `savedCards` list changes.
      - If there are no saved cards, it displays a `Center` widget with the text "No saved cards."
      - If there are saved cards, it builds a `ListView` that displays each saved card using the `ContactCard` widget.

2. **`ListView.builder`**:
   - Builds the list of saved cards dynamically based on the length of the `savedCards` list.
   - Each item in the list corresponds to a saved card, and the `ContactCard` widget is used to display the card details (name, phone, email).

#### Dependencies:
- **CardController**: The controller that manages the saved cards and handles the logic for adding and retrieving cards.
- **GetX**: Used for state management and to observe the `savedCards` list.
- **ContactCard**: A custom widget used to display the details of each card (name, phone, email).

#### Usage:
The `SavedCardsView` is intended to be a screen in a Flutter app that shows all the saved business cards. It:
- Displays a list of cards saved by the user.
- Reactively updates the list whenever a new card is added or removed.
- Provides a simple UI with a list of `ContactCard` widgets, each showing the name, phone, and email extracted from the business cards.