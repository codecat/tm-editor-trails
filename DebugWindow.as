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
