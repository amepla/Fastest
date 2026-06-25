cmake_minimum_required(VERSION 3.16)
project(MacBrowser LANGUAGES CXX OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_CXX_EXTENSIONS NO)

set(SOURCES
    src/main.mm
    src/BrowserApp.mm
)

add_executable(MacBrowser MACOSX_BUNDLE ${SOURCES})

target_link_libraries(MacBrowser
    PRIVATE
    "-framework Cocoa"
    "-framework WebKit"
)

target_compile_options(MacBrowser PRIVATE -fobjc-arc)

set_target_properties(MacBrowser PROPERTIES
    MACOSX_BUNDLE_BUNDLE_NAME "MacBrowser"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.amepla.MacBrowser"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.0"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/resources/Info.plist"
)
