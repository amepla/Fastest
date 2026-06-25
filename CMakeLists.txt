cmake_minimum_required(VERSION 3.16)
project(MacBrowser LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_CXX_EXTENSIONS NO)

set(SOURCES
    src/main.mm
    src/BrowserApp.mm
)

add_executable(MacBrowser ${SOURCES})

target_link_libraries(MacBrowser
    PRIVATE
    "-framework Cocoa"
    "-framework WebKit"
)

set_target_properties(MacBrowser PROPERTIES
    MACOSX_BUNDLE YES
)
