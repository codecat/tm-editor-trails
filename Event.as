class Event : EditorTrails::IEvent
{
	double m_time;
	vec3 m_position;
	float lastDistanceSqFromCamera = 0.0;

	string get_Type() const
	{
		return "Generic";
	}

	string Text() const { return "?"; }
	vec4 Color() const { return vec4(1); }

	Json::Value@ ToJson() const
	{
		auto data = Json::Object();
		data['t'] = m_time;
		data['p'] = Json::Array();
		data['p'].Add(m_position.x);
		data['p'].Add(m_position.y);
		data['p'].Add(m_position.z);
		return data;
	}

	double get_Time() const
	{
		return m_time;
	}

	vec3 get_Position() const
	{
		return m_position;
	}

	void Render()
	{
		vec3 screenPos = Camera::ToScreen(m_position);
		if (screenPos.z > 0) {
			return;
		}

		lastDistanceSqFromCamera = (Camera::GetCurrentPosition() - m_position).LengthSquared();
		vec2 pa = screenPos.xy;
		pa.x = Math::Round(pa.x);
		pa.y = Math::Round(pa.y);

		float stickHeight = Math::Round(64 * Setting_EventScale);
		vec2 pb = pa - vec2(0, stickHeight);
		float radius = Math::Round(32 * Setting_EventScale);
		float radiusSquared = radius * radius;
		bool hovered = (g_MouseCoords - pb).LengthSquared() < radiusSquared;
		if (hovered) g_EventHovered = true;

		vec4 color = Color();

		nvg::BeginPath();
		nvg::Circle(pb, radius);
		nvg::FillColor(color);
		nvg::Fill();
		nvg::StrokeWidth(hovered ? 3 : 0);
		nvg::StrokeColor(vec4(0, 0, 0, 1));
		nvg::Stroke();

		nvg::BeginPath();
		RenderLineSegment(pb, pa, color);

		nvg::BeginPath();
		RenderText(Text(), pb, 22.0f * Setting_EventScale);

		if (hovered || animProgress > 0) {
			RenderOnHover(hovered, pa, radius, stickHeight, color);
		}
	}

	void RenderText(const string &in text, vec2 pos, float fontSize)
	{
		nvg::FontFace(TrailView::FontBold);
		nvg::FontSize(Math::Round(fontSize));
		nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
		nvg::FillColor(vec4(0, 0, 0, 1));
		nvg::Text(pos + vec2(0, Math::Round(fontSize / 11.0)), text);
	}

	void RenderLineSegment(vec2 &in from, vec2 &in to, vec4 &in color)
	{
		nvg::MoveTo(from);
		nvg::LineTo(to);
		nvg::StrokeWidth(3);
		nvg::StrokeColor(color);
		nvg::Stroke();
	}

	float animProgress = 0.0;
	float lastAnimTime = 0.0;
	void RenderOnHover(bool hovered, vec2 &in pa, float radius, float stickHeight, vec4 &in color)
	{
		auto sign = hovered ? 1.0 : -1.0;
		animProgress += sign * State::DeltaTime / float(Setting_HoverAnimDuration);
		animProgress = Math::Clamp(animProgress, 0.0, 1.0);
		if (animProgress == 0) return;
		// break progress up into drawing the stick and drawing the
		auto t1 = Math::Clamp(animProgress * 3.0, 0.0, 1.0);
		auto t2 = Math::Clamp((animProgress - 0.33333) * 3.0, 0.0, 2.0) / 2.0;
		RenderHoverDetailsStick(t1, pa, radius, stickHeight, color);
		RenderHoverDetailsBox(t2, pa, radius, stickHeight, color);
	}

	void RenderHoverDetailsStick(float t, vec2 &in pa, float radius, float stickHeight, vec4 &in color)
	{
		if (t <= 0) return;
		vec2 pb = pa + vec2(0, stickHeight * t);
		RenderLineSegment(pa, pb, color);
	}
	void RenderHoverDetailsBox(float t, vec2 &in pa, float radius, float stickHeight, vec4 &in color)
	{
		if (t <= 0) return;

		if (hoverTextLines.Length == 0)
			PopulateHoverTextLines();

		auto timeEventScale = t * Setting_EventScale;
		vec2 size = vec2(196., 128.) * timeEventScale;
		float fontSize = Math::Round(22. * timeEventScale);
		float maxTextWidth = CalcMaxTextWidth(fontSize);
		// add some padding to maxTextWidth
		size.x = Math::Max(size.x, maxTextWidth + fontSize);
		vec2 pb = pa + vec2(0, stickHeight);
		vec2 tl = pb - size / 2.;

		nvg::BeginPath();
		nvg::RoundedRect(tl, size, radius);
		nvg::FillColor(color);
		nvg::Fill();
		nvg::StrokeWidth(3);
		nvg::StrokeColor(vec4(0, 0, 0, 1));
		nvg::Stroke();

		nvg::BeginPath();
		float nbLines = hoverTextLines.Length;
		float lineHeight = fontSize * 1.15;
		float textHeight = lineHeight * nbLines;
		// offset for text lines
		vec2 pc = pb - vec2(0, (textHeight - fontSize) / 2.);
		for (uint i = 0; i < hoverTextLines.Length; i++) {
			RenderText(hoverTextLines[i], pc, fontSize);
			pc += vec2(0, lineHeight);
		}
	}

	string[] hoverTextLines;
	void PopulateHoverTextLines()
	{
		if (hoverTextLines.Length > 0) return;
		hoverTextLines.InsertLast("Generic Event");
		hoverTextLines.InsertLast("Overload PopulateHoverTextLines");
	}

	float CalcMaxTextWidth(float fontSize)
	{
		nvg::FontSize(fontSize);
		float max = 0.;
		for (uint i = 0; i < hoverTextLines.Length; i++) {
			max = Math::Max(max, nvg::TextBounds(hoverTextLines[i]).x);
		}
		return max;
	}
}
