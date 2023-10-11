namespace Events
{
	class GearChange : Event
	{
		int m_prev;
		int m_new;

		string get_Type() const override
		{
			return "GearChange";
		}

		string Text() const override
		{
			return Icons::Cog + " " + tostring(m_new);
		}

		Json::Value@ ToJson() const override
		{
			auto data = Event::ToJson();
			data['gear'] = Json::Object();
			data['gear']['prev'] = m_prev;
			data['gear']['new'] = m_new;
			return data;
		}

		vec4 Color() const override
		{
			if (m_new > m_prev) {
				return vec4(0.5f, 1, 0.5f, 1);
			} else {
				return vec4(1, 0.5f, 0.5f, 1);
			}
		}

		void PopulateHoverTextLines() override
		{
			if (hoverTextLines.Length > 0) return;
			hoverTextLines.InsertLast(Time::Format(m_time));
			hoverTextLines.InsertLast("Gear " + m_prev + Icons::ArrowRight + m_new);
		}
	}
}
