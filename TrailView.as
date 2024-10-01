namespace TrailView
{
	int FontBold;

	bool Playing = false;
	double CurrentTime;

	double MinTime = -1;
	double MaxTime = -1;

	vec3 SmoothCameraTarget = vec3();
	bool SmoothCameraTargetFirstFrame = true;

	void SetCurrentTime(double time)
	{
		if (MinTime != -1 && time < MinTime) {
			time = MinTime;
		}
		if (MaxTime != -1 && time > MaxTime) {
			if (Setting_Loop) {
				time = MinTime;
				SmoothCameraTargetFirstFrame = true;
			} else {
				time = MaxTime;
				Playing = false;
			}
		}

		CurrentTime = time;

		for (uint i = 0; i < Trails::Items.Length; i++) {
			Trails::Items[i].m_player.SetCurrentTime(time);
		}
	}

	void Reset()
	{
		Playing = false;

		MinTime = -1;
		MaxTime = -1;

		SmoothCameraTargetFirstFrame = true;

		SetCurrentTime(0);
	}

	void Update(float dt)
	{
		if (Playing) {
			SetCurrentTime(CurrentTime + dt / 1000.0);
		}
	}

	void Render()
	{
		MinTime = -1;
		MaxTime = -1;

		double sumX = 0;
		double sumY = 0;
		double sumZ = 0;
		int numPos = 0;

		EppState::BeforeDraw();

		for (uint i = 0; i < Trails::Items.Length; i++) {
			auto trail = Trails::Items[i];

			double startTime = trail.GetStartTime();
			double endTime = trail.GetEndTime();

			if (MinTime == -1 || startTime < MinTime) { MinTime = startTime; }
			if (MaxTime == -1 || endTime > MaxTime) { MaxTime = endTime; }

			// Render the trail's line
			RenderTrailLine(trail);

			// Render events on trail
			if (Setting_Events) {
				RenderTrailEvents(trail);
			}

			// If the current time is within this trail's time
			if (CurrentTime >= startTime && CurrentTime <= endTime) {
				auto carSample = trail.m_player.m_interpolatedSample;

				// Render the trail's car
				RenderCar(carSample);

				if (Setting_Follow) {
					sumX += double(carSample.m_position.x);
					sumY += double(carSample.m_position.y);
					sumZ += double(carSample.m_position.z);
					numPos++;
				}
			}
		}

		if (Setting_Follow && numPos > 0) {
			sumX /= double(numPos);
			sumY /= double(numPos);
			sumZ /= double(numPos);

			vec3 middle = vec3(float(sumX), float(sumY), float(sumZ));

			if (Trails::Items.Length == 1 || SmoothCameraTargetFirstFrame) {
				SmoothCameraTarget = middle;
				SmoothCameraTargetFirstFrame = false;
			} else {
				SmoothCameraTarget = Math::Lerp(SmoothCameraTarget, middle, 0.1f);
			}

			Camera::SetEditorOrbitalTarget(SmoothCameraTarget);
		}

		if (CurrentTime < MinTime) {
			SetCurrentTime(MinTime);
		} else if (CurrentTime > MaxTime) {
			SetCurrentTime(MaxTime);
		}

		RenderWindow();
	}

	void RenderTrailLine(Trail@ trail)
	{
		if (ShouldUseEditorPlusPlus()) {
			RenderTrailLineEpp(trail);
		} else {
			RenderTrailLineNvg(trail);
		}
	}


	void RenderTrailLineNvg(Trail@ trail)
	{
		nvg::BeginPath();
		bool firstPoint = true;
		for (uint i = 0; i < trail.m_samples.Length - 1; i++) {
			vec3 pos = trail.m_samples[i].m_position;

			if (firstPoint) {
				vec3 pa = Camera::ToScreen(pos);
				if (pa.z <= 0) {
					nvg::MoveTo(pa.xy);
					firstPoint = false;
				} else {
					continue;
				}
			}

			vec3 pb = Camera::ToScreen(trail.m_samples[i + 1].m_position);
			if (pb.z > 0) {
				firstPoint = true;
			} else {
				nvg::LineTo(pb.xy);
			}
		}
		nvg::StrokeWidth(Setting_TrailWidth);
		nvg::StrokeColor(Setting_TrailColor);
		nvg::Stroke();
	}

	void RenderTrailEvents(Trail@ trail)
	{
		for (uint i = 0; i < trail.m_events.Length; i++) {
			trail.m_events[i].Render();
		}
	}

	void RenderCar(const Sample &in sample)
	{
		vec3 screenPos = Camera::ToScreen(sample.m_position);
		if (screenPos.z <= 0) {
			nvg::BeginPath();
			nvg::Circle(screenPos.xy, 5);
			nvg::FillColor(Setting_CarPositionColor);
			nvg::Fill();

			if (Setting_DisplayVelocity) {
				vec3 ahead = sample.m_position + sample.m_velocity * Setting_VelocityOverTime;
				vec3 aheadScreenPos = Camera::ToScreen(ahead);
				if (aheadScreenPos.z <= 0) {
					nvg::BeginPath();
					nvg::MoveTo(screenPos.xy);
					nvg::LineTo(aheadScreenPos.xy);
					nvg::StrokeWidth(Setting_VelocityTrailWidth);
					nvg::StrokeColor(Setting_CarVelocityColor);
					nvg::Stroke();
				}
			}
		}
	}

	void RenderWindow()
	{
		UI::SetNextWindowSize(550, 130, UI::Cond::Appearing);
		if (UI::Begin(Icons::PlayCircleO + " Editor Trails###EditorTrails", Setting_EnableTrails)) {
			if (Trails::Items.Length == 0) {
				UI::Text("Enter test mode to record a trail.");
			} else {
				UI::PushItemWidth(-1);
				double time = UI::SliderDouble("##PlayPosition", CurrentTime, MinTime, MaxTime);
				if (time != CurrentTime) {
					SetCurrentTime(time);
					Playing = false;
				}
				UI::PopItemWidth();

				if (UI::Button(Playing ? Icons::Pause : Icons::Play)) {
					Playing = !Playing;
					if (Playing && CurrentTime == MaxTime) {
						SetCurrentTime(MinTime);
					}
				}
				UI::SameLine();
				if (UI::Button(Icons::Stop)) {
					Reset();
				}
				UI::SameLine();
				Setting_Loop = UI::Checkbox("Looping", Setting_Loop);
				UI::SameLine();
				Setting_Follow = UI::Checkbox("Follow", Setting_Follow);
				UI::SameLine();
				Setting_Events = UI::Checkbox("Events", Setting_Events);

				UI::SameLine();
				if (MinTime < 0.5) {
					UI::Text("Duration: \\$f39" + Text::Format("%.03f", MaxTime - MinTime));
				} else {
					UI::Text("\\$666(" + MinTime + " - " + MaxTime + ")\\$z Duration: \\$f39" + Text::Format("%.03f", MaxTime - MinTime));
				}

				if (UI::Button("Remove trails")) {
					Trails::Clear();
				}
			}
		}
		UI::End();
	}
}
