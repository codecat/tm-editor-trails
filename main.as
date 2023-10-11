namespace State
{
	bool InEditor = false;
	bool InEditorPlay = false;
	bool MenuButtonDown = false;

	int CurrentRaceTime = 0;

	float DeltaTime = 10.;
}

void OnEditorLeave()
{
	trace("Editor leave");

	// Remove all trails
	Trails::Clear();
}

void OnEditorPlayEnter()
{
	trace("Just entered editor play");

	// Clear trails if the settings want to
	if (Setting_ClearOnStart) {
		Trails::Clear();
	}
}

void OnEditorPlayLeave()
{
	trace("Editor play leave");

	// Remove last trail if there's not enough samples
	if (Trails::Items.Length > 0) {
		auto lastTrail = Trails::Items[Trails::Items.Length - 1];
		if (lastTrail.GetDuration() < Setting_MinimumDuration) {
			Trails::Items.RemoveAt(Trails::Items.Length - 1);
		}
	}

	// Upload trails to blender if the setting is enabled
	trace("DEBUG calling Upload::OnReenteredEditorAsync");
	startnew(Upload::OnReenteredEditorAsync);

	// Reset trail view
	TrailView::Reset();
}

void OnKeyPress(bool down, VirtualKey key)
{
	if (key == VirtualKey::Menu) {
		State::MenuButtonDown = down;
	}
}

void OnMouseButton(bool down, int button, int x, int y)
{
	if (button == 0 && down && State::MenuButtonDown) {
		Setting_Follow = false;
	}
}

void Main()
{
	// Load font for trail events
	TrailView::FontBold = nvg::LoadFont("DroidSans-Bold.ttf", true);

	// Some states we need to keep track of
	bool lastEntityStateAvailable = false;
	int lastStartTime = 0;
	int lastCurrentRaceTime = 0;

	while (true) {
		yield();

		if (!Setting_EnableTrails) {
			lastEntityStateAvailable = false;
			lastStartTime = 0;
			lastCurrentRaceTime = 0;
			continue;
		}

		// Get the editor if we're currently in it
		auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
		if (editor is null) {
			if (State::InEditor) {
				OnEditorLeave();
				lastEntityStateAvailable = false;
				lastStartTime = 0;
				lastCurrentRaceTime = 0;
			}
			State::InEditor = false;
			State::InEditorPlay = false;
			continue;
		}
		State::InEditor = true;

		// Get the playground if we're currently in it
#if TMNEXT
		auto pg = cast<CSmArenaClient>(GetApp().CurrentPlayground);
#else
		auto pg = cast<CTrackManiaRace1P>(GetApp().CurrentPlayground);
#endif
		if (pg is null) {
			if (State::InEditorPlay) {
				OnEditorPlayLeave();
			}
			State::InEditorPlay = false;
			continue;
		}

		// Make sure a player object actually exists
		if (pg.Players.Length == 0) {
			continue;
		}

#if !TMNEXT
		// Make sure the player object has spawned
		if (!cast<CTrackManiaPlayer>(pg.Players[0]).IsSpawned) {
			if (State::InEditorPlay) {
				OnEditorPlayLeave();
			}
			State::InEditorPlay = false;
			continue;
		}
#endif

		// If we weren't previously in editor play mode, we know that we have just entered it
		if (!State::InEditorPlay) {
			OnEditorPlayEnter();
		}
		State::InEditorPlay = true;

#if TMNEXT
		// Get player information in Trackmania
		auto player = cast<CSmPlayer>(pg.Players[0]);
		auto scriptPlayer = cast<CSmScriptPlayer>(player.ScriptAPI);

		bool entityStateAvailable = scriptPlayer.IsEntityStateAvailable;
		int startTime = scriptPlayer.StartTime;
		State::CurrentRaceTime = scriptPlayer.CurrentRaceTime;

#else
		// Get player information in Maniaplanet
		auto player = cast<CTrackManiaPlayer>(pg.Players[0]);
		auto scriptPlayer = player.ScriptAPI;

		bool entityStateAvailable = (scriptPlayer.RaceState == CTrackManiaPlayer::ERaceState::Running);
		int startTime = int(scriptPlayer.RaceStartTime);
		State::CurrentRaceTime = scriptPlayer.CurRace.Time;
#endif

		// Do nothing if the entity state is not available
		if (!entityStateAvailable) {
			lastEntityStateAvailable = false;
			continue;
		}

		// After the entity state becomes available, we have to wait 1 frame before the state has been
		// updated at least once, so we delay execution by 1 more iteration here
		if (!lastEntityStateAvailable) {
			lastEntityStateAvailable = true;
			continue;
		}

		// Get the current trail
		auto currentTrail = Trails::GetCurrent();

		// If the start time has increased since the last time we stored it, we have started a new run
		if (startTime > lastStartTime) {
			trace("Starting a new run");

			// Keep track of our start time and our starting current race time
			lastStartTime = startTime;
			lastCurrentRaceTime = State::CurrentRaceTime;

			// Check if we need to remove the current trail because there are not enough samples
			if (currentTrail.GetDuration() < Setting_MinimumDuration) {
				Trails::RemoveCurrent();
			}

			// Create a new trail
			@currentTrail = Trails::CreateNew();
		}

		// If we haven't elapsed any time, don't save a sample (for example, if we pressed escape and
		// the "Return to Editor?" window is visible)
		int elapsedTime = State::CurrentRaceTime - lastCurrentRaceTime;
		if (elapsedTime < (1000 / Setting_SamplesPerSecond)) {
			continue;
		}
		lastCurrentRaceTime = State::CurrentRaceTime;

		// Don't add sample if the settings say we don't need to
		if (!Setting_CaptureSamples) {
			continue;
		}

		// Don't add samples if we're counting down (usually between 300 to 400 milliseconds in editor)
		if (State::CurrentRaceTime < 0) {
			continue;
		}

		// Add sample
		currentTrail.Update(scriptPlayer);
	}
}

void Update(float dt)
{
	if (State::InEditor && !State::InEditorPlay) {
		State::DeltaTime = dt;
		// Update trail view
		TrailView::Update(dt);
	}
}

void RenderMenu()
{
	if (UI::MenuItem("\\$f39" + Icons::PlayCircleO + "\\$z Editor Trails", "", Setting_EnableTrails)) {
		Setting_EnableTrails = !Setting_EnableTrails;
		if (!Setting_EnableTrails) {
			TrailView::Reset();
			Trails::Clear();
		}
	}
}

void Render()
{
	// Render the debug window if wanted and if we're currently in the editor
	if (Setting_ShowDebugWindow && State::InEditor) {
		DebugWindow::Render();
	}

	// Render the trail view if wanted and if we're currently in the editor, but not in play
	if (Setting_EnableTrails && State::InEditor && !State::InEditorPlay) {
		TrailView::Render();
	}
}
