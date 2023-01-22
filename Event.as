class Event
{
	double m_time;
	vec3 m_position;

	string Text() { return "?"; }
	vec4 Color() { return vec4(1); }

	void Render()
	{
		vec3 screenPos = Camera::ToScreen(m_position);
		if (screenPos.z > 0) {
			return;
		}

		vec2 pa = screenPos.xy;
		pa.x = Math::Round(pa.x);
		pa.y = Math::Round(pa.y);

		vec2 pb = pa - vec2(0, Math::Round(64 * Setting_EventScale));

		vec4 color = Color();

		nvg::BeginPath();
		nvg::Circle(pb, Math::Round(32 * Setting_EventScale));
		nvg::FillColor(color);
		nvg::Fill();

		nvg::BeginPath();
		nvg::MoveTo(pb);
		nvg::LineTo(pa);
		nvg::StrokeWidth(3);
		nvg::StrokeColor(color);
		nvg::Stroke();

		nvg::BeginPath();
		nvg::FontFace(TrailView::FontBold);
		nvg::FontSize(Math::Round(22 * Setting_EventScale));
		nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
		nvg::FillColor(vec4(0, 0, 0, 1));
		nvg::Text(pb + vec2(0, 2), Text());
	}
}
