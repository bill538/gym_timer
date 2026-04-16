# gym_timer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Architecture

This project was built iteratively with the assistance of an AI agent. Below is the system architecture showing the relationship between the Flutter application, the native Android code (for Chromecast), and the web receiver.

```mermaid
flowchart TB

    %% Styling
    classDef flutter fill:#42A5F5,stroke:#1565C0,stroke-width:2px,color:white;
    classDef native fill:#3DDC84,stroke:#2E7D32,stroke-width:2px,color:black;
    classDef cast fill:#FBBC04,stroke:#F57F17,stroke-width:2px,color:black;
    classDef user fill:#FF7043,stroke:#D84315,stroke-width:2px,color:white;

    User((User)):::user

    subgraph Flutter App [Flutter Cross-Platform Layer]
        UI[Flutter UI Widgets\nScreens: AMRAP, EMOM, etc.]:::flutter
        BLoC[TimerBloc\nState Management]:::flutter
        Audio[AudioService\nFresh AudioPlayer per sound]:::flutter
        CastService[CastService\nflutter_chrome_cast]:::flutter
    end

    subgraph Android Native [Android Native Layer]
        KotlinPlugin[Flutter Plugin Bridge]:::native
        CastOptions[CastOptionsProvider\nInjects Custom App ID]:::native
        AndroidCastSDK[Google Cast SDK]:::native
    end

    subgraph TV/Display [Chromecast Receiver]
        WebReceiver[Custom Web Receiver Application]:::cast
        TV_UI[TV Display UI\nTimer, Type, Round]:::cast
        TV_Audio[Native TV Audio\nZero-latency Beeps]:::cast
    end

    %% Flow of Data and Interactions
    User -->|Selects Timer & Starts| UI
    UI -->|Sends Timer Events| BLoC
    BLoC -->|Yields UI States| UI
    
    BLoC -->|Triggers Local Sounds| Audio
    BLoC -->|Sends Timer Payload\n(Time, State, Type)| CastService
    
    CastService -->|Method Channel| KotlinPlugin
    KotlinPlugin --> AndroidCastSDK
    CastOptions -.->|Configures| AndroidCastSDK
    
    AndroidCastSDK == WebSockets / Cast Protocol ==> WebReceiver
    
    WebReceiver -->|Updates| TV_UI
    WebReceiver -->|Plays| TV_Audio
```
