namespace DebugWindow
{
	void Render()
	{
		if (UI::Begin("Editor Trails Debug", Setting_ShowDebugWindow)) {
			Setting_CaptureSamples = UI::Checkbox("Capture samples", Setting_CaptureSamples);
			Setting_ClearOnStart = UI::Checkbox("Clear trails on editor play start", Setting_ClearOnStart);

			if (UI::Button("Clear trails")) {
				Trails::Clear();
			}

			UI::BeginDisabled(!Setting_EnableUploadTrails);
			if (UI::Button("Upload Trails to Blender")) {
				startnew(Upload::OnReenteredEditorAsync);
			}
			UI::EndDisabled();

			UI::Separator();

			UI::Text("State::InEditor: \\$f39" + tostring(State::InEditor));
			UI::Text("State::InEditorPlay: \\$f39" + tostring(State::InEditorPlay));
			UI::Text("State::MenuButtonDown: \\$f39" + tostring(State::MenuButtonDown));
			UI::Text("State::CurrentRaceTime: \\$f39" + tostring(State::CurrentRaceTime));
			UI::Text("State::DeltaTime: \\$f39" + tostring(State::DeltaTime));
			UI::Text("g_EventHovered: \\$f39" + tostring(g_EventHovered));
			UI::Text("g_MouseCoords: \\$f39" + tostring(g_MouseCoords));

			UI::Separator();

			UI::Text("Trail count: \\$f39" + Trails::Items.Length);
			for (int i = int(Trails::Items.Length) - 1; i >= 0; i--) {
				auto trail = Trails::Items[i];

				UI::Separator();
				UI::Text("Replay " + i + ":");
				UI::Text("-- Samples: \\$f39" + trail.m_samples.Length);
				UI::Text("-- Duration: \\$f39" + Text::Format("%.02f", trail.GetDuration()) + " seconds");
				UI::Text("-- Events: \\$f39" + trail.m_events.Length);
				for (uint j = 0; j < trail.m_events.Length; j++) {
					auto event = trail.m_events[j];
					UI::Text("-- Event[" + j + "] = \\$f39\"" + event.Text() + "\"");
				}
			}
		}
		UI::End();
	}
}
