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

				uint numSamples = trail.m_samples.Length;
				double duration = trail.GetDuration();

				UI::Separator();
				UI::Text("Replay " + i + ":");
				UI::Text("-- Samples: \\$f39" + numSamples);
				UI::Text("-- Duration: \\$f39" + Text::Format("%.02f", duration) + " seconds");
			}
		}
		UI::End();
	}
}
