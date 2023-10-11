namespace Events
{
	class Respawn : Event
	{
        bool m_standing = false;
        int m_number;

		string get_Type() const override
		{
			return "Respawn";
		}

		string Text() const override
		{
			return Icons::Undo + " " + tostring(m_number);
		}

		Json::Value@ ToJson() const override
		{
			auto data = Event::ToJson();
			data['respawn'] = Json::Object();
			data['respawn']['standing'] = m_standing;
			return data;
		}

		vec4 Color() const override
		{
			if (m_standing) {
				return vec4(0.2f, 0.2f, 0.8f, 1);
			} else {
				return vec4(0.55f, 0.82f, 1, 1);
			}
		}

		void PopulateHoverTextLines() override
		{
			if (hoverTextLines.Length > 0) return;
			hoverTextLines.InsertLast(Time::Format(m_time * 1000.));
			hoverTextLines.InsertLast("Respawn " + m_number);
			if (m_standing) hoverTextLines.InsertLast("Standing Respawn");
		}
	}
}
