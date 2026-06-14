import XCTest

final class WCS_InsightUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Home Tab

    @MainActor
    func test_home_screen_shows_all_core_elements() throws {
        XCTAssertTrue(app.staticTexts["Memory Atlas"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["WCS Dementia-Care Reminiscence"].exists)
        XCTAssertTrue(app.staticTexts["Ready for a gentle reminiscence session?"].exists)
        XCTAssertTrue(app.staticTexts["TODAY'S SESSION"].exists)
        XCTAssertTrue(app.staticTexts["At a Glance"].exists)
        XCTAssertTrue(app.staticTexts["Active Profile"].exists)
        XCTAssertTrue(app.staticTexts["Favourite Items"].exists)
        XCTAssertTrue(app.staticTexts["Sessions This Week"].exists)
    }

    @MainActor
    func test_home_quote_banner_and_start_session_button() throws {
        XCTAssertTrue(app.staticTexts["Small moments. Lasting connections. Your care makes a world of difference."]
            .waitForExistence(timeout: 5))
        let startBtn = app.buttons["Start Session"].firstMatch
        XCTAssertTrue(startBtn.exists)
    }

    // MARK: - Tab Navigation

    @MainActor
    func test_all_tab_bar_buttons_are_tappable() throws {
        for tab in ["Profiles", "Sessions", "Library", "More"] {
            let btn = app.buttons[tab]
            XCTAssertTrue(btn.waitForExistence(timeout: 5), "Tab \(tab) not found")
            btn.tap()
        }
        app.buttons["Home"].tap()
        XCTAssertTrue(app.staticTexts["Memory Atlas"].waitForExistence(timeout: 3))
    }

    // MARK: - Profiles Tab

    @MainActor
    func test_profiles_list_displays_maggie() throws {
        app.buttons["Profiles"].tap()
        XCTAssertTrue(app.staticTexts["Maggie"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Belfast, Northern Ireland"].exists)
        XCTAssertTrue(app.staticTexts["Active profile"].exists)
    }

    @MainActor
    func test_profile_detail_shows_header_and_tabs() throws {
        app.buttons["Profiles"].tap()
        app.staticTexts["Maggie"].tap()

        XCTAssertTrue(app.staticTexts["Born 12 May 1936"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Belfast, Northern Ireland"].exists)
        let quote = app.staticTexts["\"Faith, family and flowers have always been my joy.\""]
        XCTAssertTrue(quote.exists)

        XCTAssertTrue(app.buttons["Memories"].exists)
        XCTAssertTrue(app.buttons["About"].exists)
        XCTAssertTrue(app.buttons["Preferences"].exists)
    }

    @MainActor
    func test_profile_memories_tab_shows_artifacts() throws {
        app.buttons["Profiles"].tap()
        app.staticTexts["Maggie"].tap()
        XCTAssertTrue(app.staticTexts["Wedding Day"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["How Great Thou Art"].exists)
        XCTAssertTrue(app.staticTexts["Our Home Garden"].exists)
    }

    @MainActor
    func test_profile_about_tab() throws {
        app.buttons["Profiles"].tap()
        app.staticTexts["Maggie"].tap()
        app.buttons["About"].tap()
        let aboutText = app.staticTexts["About Maggie"]
        XCTAssertTrue(aboutText.waitForExistence(timeout: 3))
        let notes = app.staticTexts["Early-stage dementia. Responds well to music and familiar places."]
        XCTAssertTrue(notes.exists)
    }

    @MainActor
    func test_profile_preferences_tab() throws {
        app.buttons["Profiles"].tap()
        app.staticTexts["Maggie"].tap()
        app.buttons["Preferences"].tap()
        let lang = app.staticTexts["EN"]
        XCTAssertTrue(lang.waitForExistence(timeout: 3))
    }

    @MainActor
    func test_profile_add_memory_item() throws {
        app.buttons["Profiles"].tap()
        app.staticTexts["Maggie"].tap()
        app.buttons["Add Memory Item"].tap()
        XCTAssertTrue(app.staticTexts["New Memory"].waitForExistence(timeout: 3))
    }

    // MARK: - Sessions Tab

    @MainActor
    func test_sessions_list_shows_both_sessions() throws {
        app.buttons["Sessions"].tap()
        XCTAssertTrue(app.staticTexts["Evening Calm"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Morning Connection"].exists)
    }

    @MainActor
    func test_sessions_tab_start_journey() throws {
        app.buttons["Sessions"].tap()
        app.buttons["Start Session"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Step 2 of 5"].waitForExistence(timeout: 5))
    }

    // MARK: - Session Player

    @MainActor
    func test_session_player_step_forward() throws {
        app.buttons["Sessions"].tap()
        app.buttons["Start Session"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Step 2 of 5"].waitForExistence(timeout: 5))

        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["Step 3 of 5"].waitForExistence(timeout: 3))
    }

    @MainActor
    func test_session_player_step_back() throws {
        app.buttons["Sessions"].tap()
        app.buttons["Start Session"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Step 2 of 5"].waitForExistence(timeout: 5))

        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["Step 3 of 5"].waitForExistence(timeout: 3))
        app.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Step 2 of 5"].waitForExistence(timeout: 3))
    }

    @MainActor
    func test_session_player_pause_resume() throws {
        app.buttons["Sessions"].tap()
        app.buttons["Start Session"].firstMatch.tap()

        let pauseBtn = app.buttons["Pause"]
        XCTAssertTrue(pauseBtn.waitForExistence(timeout: 5))
        pauseBtn.tap()

        let playBtn = app.buttons["Play"]
        XCTAssertTrue(playBtn.waitForExistence(timeout: 3))
        playBtn.tap()

        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 3))
    }

    @MainActor
    func test_session_player_mood_picker() throws {
        app.buttons["Sessions"].tap()
        app.buttons["Start Session"].firstMatch.tap()

        let howText = app.staticTexts["How is Maggie feeling?"]
        XCTAssertTrue(howText.waitForExistence(timeout: 5))

        for mood in ["Very calm", "Calm", "Okay", "Anxious", "Upset"] {
            let btn = app.buttons[mood]
            XCTAssertTrue(btn.exists, "Mood button \(mood) not found")
            btn.tap()
        }
    }

    @MainActor
    func test_session_player_dismiss() throws {
        app.buttons["Sessions"].tap()
        app.buttons["Start Session"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Evening Calm"].waitForExistence(timeout: 5))

        app.buttons["Close"].tap()
        XCTAssertTrue(app.buttons["Sessions"].waitForExistence(timeout: 3))
    }

    // MARK: - Library Tab

    @MainActor
    func test_library_shows_all_memory_artifacts() throws {
        app.buttons["Library"].tap()
        XCTAssertTrue(app.staticTexts["Memory Library"].waitForExistence(timeout: 5))

        let artifacts = ["Wedding Day", "How Great Thou Art", "Our Home Garden", "Harbour Walk", "Grandchildren's Visit"]
        for artifact in artifacts {
            XCTAssertTrue(app.staticTexts[artifact].exists, "Artifact \(artifact) not found")
        }
    }

    @MainActor
    func test_library_shows_profile_names_and_tags() throws {
        app.buttons["Library"].tap()
        XCTAssertTrue(app.staticTexts["Memory Library"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Maggie"].exists)
        XCTAssertTrue(app.staticTexts["Family"].exists)
        XCTAssertTrue(app.staticTexts["Joy"].exists)
    }

    // MARK: - More Tab

    @MainActor
    func test_more_screen_structure() throws {
        app.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Care Team"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Workspace"].exists)
        XCTAssertTrue(app.staticTexts["Apple-native roadmap"].exists)
    }

    @MainActor
    func test_more_screen_caregiver_info() throws {
        app.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Claire"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Family caregiver"].exists)
    }

    @MainActor
    func test_more_screen_workspace_stats() throws {
        app.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Workspace"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Profiles"].exists)
        XCTAssertTrue(app.staticTexts["Memory items"].exists)
        XCTAssertTrue(app.staticTexts["Guided sessions"].exists)
    }

    @MainActor
    func test_more_screen_roadmap_labels() throws {
        app.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Apple-native roadmap"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["CloudKit backup scaffold"].exists)
        XCTAssertTrue(app.staticTexts["WidgetKit daily memory prompts"].exists)
        XCTAssertTrue(app.staticTexts["visionOS spatial scenes (Phase 2)"].exists)
    }

    // MARK: - Full End-to-End Journey

    @MainActor
    func test_full_e2e_journey() throws {
        let tabBar = app.tabBars.firstMatch

        tabBar.buttons["Sessions"].tap()
        XCTAssertTrue(app.staticTexts["Evening Calm"].waitForExistence(timeout: 10))
        app.buttons["Start Session"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Evening Calm"].waitForExistence(timeout: 5))
        app.buttons["Close"].tap()

        tabBar.buttons["Library"].tap()
        XCTAssertTrue(app.staticTexts["Memory Library"].waitForExistence(timeout: 5))

        tabBar.buttons["More"].tap()
        XCTAssertTrue(app.staticTexts["Care Team"].waitForExistence(timeout: 5))

        tabBar.buttons["Home"].tap()
        XCTAssertTrue(app.staticTexts["Memory Atlas"].waitForExistence(timeout: 5))
    }
}
