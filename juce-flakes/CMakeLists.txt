cmake_minimum_required(VERSION 3.25)
project(juce-flakes VERSION 0.0.1)
set(CMAKE_PREFIX_PATH ${PROJECT_SOURCE_DIR}/result/Build/CMake)
message("CPP: ${CMAKE_PREFIX_PATH}")
find_package(JUCE CONFIG REQUIRED)
juce_add_console_app(${PROJECT_NAME}
    PRODUCT_NAME ${PROJECT_NAME})
target_sources(${PROJECT_NAME}
    PRIVATE
        Main.cpp)
target_compile_definitions(${PROJECT_NAME}
    PRIVATE
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0)  
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        juce::juce_core
    PUBLIC
        juce::juce_recommended_config_flags
        juce::juce_recommended_warning_flags)

