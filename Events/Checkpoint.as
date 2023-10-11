namespace Events
{
	class Checkpoint : Event
	{
        int m_number;
        int m_respawns;
        int m_noRespawnTime;
        bool m_isEndLap = false;
        bool m_isFinish = false;
        int m_lapTime;
        int m_lapEndNb;


		string get_Type() const override
		{
			return "Checkpoint";
		}

		string Text() const override
		{
            if (m_isFinish)
				return Icons::Trophy;
			if (m_isEndLap)
				return "Lap " + m_lapEndNb;
			return Icons::ClockO + " " + m_number;
		}

		Json::Value@ ToJson() const override
		{
			auto data = Event::ToJson();
			auto inner = Json::Object();

			inner['respawns'] = m_respawns;
			inner['noRespawnTime'] = m_noRespawnTime;

			if (m_isFinish || m_isEndLap) {
				inner['lapTime'] = m_lapTime;
				inner['lapNumber'] = m_lapEndNb;
			}

			if (m_isFinish)
				data['finish'] = inner;
			else if (m_isEndLap)
				data['lap'] = inner;
			else
				data['cp'] = inner;
			return data;
		}

		vec4 Color() const override
		{
            if (m_isFinish)
                // gold
			    return vec4(0.95f, 0.73f, 0, 1);
            if (m_isEndLap)
                // silver
			    return vec4(0.655f, 0.665f, 0.68f, 1);
            // checkpoint, pale green
            return vec4(0.25f, 0.98f, 0.25f, 1);
		}

		void PopulateHoverTextLines() override
		{
			if (hoverTextLines.Length > 0) return;
			hoverTextLines.InsertLast(Time::Format(m_time));
			hoverTextLines.InsertLast("No Respawn: " + Time::Format(m_noRespawnTime));
			hoverTextLines.InsertLast("Nb Respawns: " + Time::Format(m_respawns));
		}
	}
}
