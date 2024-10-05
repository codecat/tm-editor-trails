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

		for (uint i = 0; i < Trails::Items.Length; i++) {
			auto trail = Trails::Items[i];

			double startTime = trail.GetStartTime();
			double endTime = trail.GetEndTime();

			if (MinTime == -1 || startTime < MinTime) { MinTime = startTime; }
			if (MaxTime == -1 || endTime > MaxTime) { MaxTime = endTime; }

			// Render the trail's line
			if (Setting_DisplayTrails) {
				RenderTrailLine(trail);
			}

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
		if (screenPos.z > 0) return;

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

		if (Setting_DisplayGizmo) {
			quat dir = sample.m_dir;

			array<vec3> axes(3);
			axes[0] = vec3(0, 0, 1) * Setting_GizmoScale;
			axes[1] = vec3(0, 1, 0) * Setting_GizmoScale;
			axes[2] = vec3(1, 0, 0) * Setting_GizmoScale;

			array<vec4> cols(3);
			cols[0] = vec4(1, 0, 0, 1);
			cols[1] = vec4(0, 1, 0, 1);
			cols[2] = vec4(0, 0, 1, 1);

			for(uint aIdx = 0; aIdx < 3; aIdx++) {
				vec3 v = sample.m_position + dir * axes[aIdx];
				vec3 vSS = Camera::ToScreen(v);
				
				if (vSS.z > 0) { continue; }

				nvg::BeginPath();
				nvg::MoveTo(screenPos.xy);
				nvg::LineTo(vSS.xy);
				nvg::StrokeWidth(Setting_GizmoWidth);
				nvg::StrokeColor(cols[aIdx]);
				nvg::Stroke();
			}
		}

		if (Setting_DisplayBox) {
			quat dir = sample.m_dir;

			const float carHalfWidth = 2.1f;
			const float carHeightUp = 1.75f;
			const float carHeightDown = 0.0f;
			const float carLengthFront = 4.37f;
			const float carLengthBack = 3.2f;

			// Cube vertices scaled to match car box
			array<vec3> verts(8);
			verts[0] = vec3(-.5f,  .5f, -.5f) * vec3(carHalfWidth, carHeightUp, carLengthBack);
			verts[1] = vec3( .5f,  .5f, -.5f) * vec3(carHalfWidth, carHeightUp, carLengthBack);
			verts[2] = vec3( .5f, -.5f, -.5f) * vec3(carHalfWidth, carHeightDown, carLengthBack);
			verts[3] = vec3(-.5f, -.5f, -.5f) * vec3(carHalfWidth, carHeightDown, carLengthBack);
			verts[4] = vec3( .5f,  .5f,  .5f) * vec3(carHalfWidth, carHeightUp, carLengthFront);
			verts[5] = vec3(-.5f,  .5f,  .5f) * vec3(carHalfWidth, carHeightUp, carLengthFront);
			verts[6] = vec3(-.5f, -.5f,  .5f) * vec3(carHalfWidth, carHeightDown, carLengthFront);
			verts[7] = vec3( .5f, -.5f,  .5f) * vec3(carHalfWidth, carHeightDown, carLengthFront);

			/*
			 * Indices to cube verts ordered to draw cube with 12 lines
			 * 0-<-1 1-<-4 4-<-5 5-<-0
			 *     |     |     |     |
			 * 3---2 2---7 7---6 6---3
			 */
			array<array<uint>> indices = {{3, 2, 1, 0}, {2, 7, 4, 1}, {7, 6, 5, 4}, {6, 3, 0, 5}};

			for(uint sIdx = 0; sIdx < 4; sIdx++) {
				vec3 v0 = sample.m_position + dir * verts[indices[sIdx][0]];
				vec3 v0SS = Camera::ToScreen(v0);
				if (v0SS.z > 0) { continue; }

				nvg::BeginPath();
				nvg::MoveTo(v0SS.xy);
				for(uint vIdx = 1; vIdx < 4; vIdx++) {
					vec3 v = sample.m_position + dir * verts[indices[sIdx][vIdx]];
					vec3 vSS = Camera::ToScreen(v);
					if (vSS.z > 0) { continue; }
					nvg::LineTo(vSS.xy);
				}
				nvg::StrokeWidth(Setting_BoxWidth);
				nvg::StrokeColor(Setting_CarBoxColor);
				nvg::Stroke();
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

				Setting_DisplayTrails = UI::Checkbox("Display Trails", Setting_DisplayTrails);

				UI::SameLine();
				Setting_DisplayVelocity = UI::Checkbox("Display Velocity", Setting_DisplayVelocity);

				UI::SameLine();
				Setting_DisplayGizmo = UI::Checkbox("Display Gizmo", Setting_DisplayGizmo);

				UI::SameLine();
				Setting_DisplayBox = UI::Checkbox("Display Box", Setting_DisplayBox);

				if (UI::Button("Remove trails")) {
					Trails::Clear();
				}
			}
		}
		UI::End();
	}
}
