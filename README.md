[RU](README.ru.md) | **EN**

# Geo Album

## Description

This application is a functional mobile photo gallery for Aurora OS, designed to read geotags from your photos and visualize their locations on an interactive map. It allows users to browse photos from their device's `~/Pictures` directory, view them individually, and explore their geographical context.

This project highlights several key technical features:

*   **Advanced State Management:** Utilizes the `provider` package to efficiently manage and distribute application state.
*   **Asynchronous Processing:** Employs `compute` (Isolates) for heavy background tasks like EXIF parsing and thumbnail generation, ensuring a smooth, non-blocking UI.
*   **Performance Optimization:** Creates and caches lightweight, square-cropped image thumbnails for a fast and fluid grid scrolling experience.
*   **Offline-Ready Maps:** Implements a custom `CachedTileProvider` for the `flutter_map` package, which caches map tiles on the device. This improves performance and allows the map to function without an active internet connection (once tiles are cached).
*   **Custom Navigation:** Features a custom state machine-based navigation (`HomeScreen` with a conditional builder) that preserves the state of the main screens when switching between them.

## Table of Contents

*   [Build features](#build-features)
*   [Install and launch](#install-and-launch)
*   [Screenshots](#screenshots)
*   [Project Structure](#project-structure)
*   [Geotagging Test Photos](#geotagging-test-photos)

<a name="build-features"></a>
## Build features

Go to the project directory and update the dependencies first:

```shell
flutter-aurora pub get
```

To build and run the application:

```shell
flutter-aurora run
```

To run static analysis:

```shell
flutter-aurora analyze
```

<a name="install-and-launch"></a>
## Install and launch

The application requires `UserDirs` and `Internet` permissions to function correctly. These permissions are declared in the `aurora/desktop/geo_album.desktop` file.

To test the application, you need to place photo files (JPEG, PNG) into the `~/Pictures` folder on the Aurora OS emulator or device. For the map functionality, it is crucial that these photos contain GPS metadata (geotags).

<a name="screenshots"></a>
## Screenshots

*Please note: Some screenshots may display visually identical images. This is intentional and was used for testing purposes, as the application was tested with multiple versions of the same image file at different quality levels and compression rates.*

**Gallery Screen**  
![Gallery Screen](screenshots/gallery.png)

**Photo View (GPS Available)**  
![Photo View GPS](screenshots/photo_show_close_and_gps.png)

**Photo View (No GPS)**  
![Photo View No GPS](screenshots/photo_show_no_gps.png)

**Map (All Markers)**  
![Map All Markers](screenshots/map_not_focused.png)

**Map (Focused on Photo)**  
![Map Focused](screenshots/map_focused_on_photo.png)

**Map (Offline from Cache)**  
![Map Offline](screenshots/map_cached_no_internet.png)

<a name="project-structure"></a>
## Project Structure

The project has a standard application structure for Flutter on Aurora OS.

*   **[aurora](aurora)**: Contains C++ source code and resources needed for building and installing on Aurora OS.
*   **[lib](lib)**: Contains all the Dart source code.
    *   **[providers](lib/providers)**: Contains the business logic and state management.
    *   **[screens](lib/screens)**: Contains the UI for each of the application screens.
    *   **[utils](lib/utils)**: Contains helper classes and functions.
    *   **[main.dart](lib/main.dart)**: The entry point of the application.
*   **[screenshots](screenshots)**: Contains screenshots of the application.
*   **[pubspec.yaml](pubspec.yaml)**: Describes the project's dependencies and metadata.
*   **[AUTHORS.md](AUTHORS.md)**: Lists the project contributors.
*   **[LICENSE](LICENSE)**: Contains the project's BSD-3-Clause license.

<a name="geotagging-test-photos"></a>
## Geotagging Test Photos

If your test photos do not have GPS data, you can add random geotags using the provided Python utility, available at the link below.

*   **Utility Link:** [add_geotags.py](https://gitverse.ru/olegg000/add_geotags_util/content/master/add_geotags.py)

**Usage:**

1.  **Install `exiftool`:**
    ```shell
    sudo apt install libimage-exiftool-perl
    ```
2.  **Download and run the script:**
    ```shell
    python3 add_geotags.py
    ```
    The script will ask for the path to the directory with your images. 