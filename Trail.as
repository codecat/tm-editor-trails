class Trail
{
	array<Sample> m_samples;

	TrailPlayer@ m_player; //TODO: Do we need this here? It's a circular reference!

	Trail()
	{
		m_samples.Reserve(1000);

		@m_player = TrailPlayer(this);
	}

	void AddSample(CSmScriptPlayer@ scriptPlayer)
	{
		// There is no reason to save a sample if we're still in the same position as the last sample
		if (m_samples.Length > 0) {
			//TODO: We should also check vehicle rotation when we do this
			auto lastSample = m_samples[m_samples.Length - 1];
			if ((lastSample.m_position - scriptPlayer.Position).LengthSquared() < 0.1) {
				return;
			}
		}

		// Create a sample and store it in the trail
		Sample newSample;
		newSample.m_time = scriptPlayer.CurrentRaceTime / 1000.0;
		newSample.m_position = scriptPlayer.Position;
		newSample.m_dir = quat(scriptPlayer.AimDirection);
		newSample.m_velocity = scriptPlayer.Velocity;
		m_samples.InsertLast(newSample);
	}

	double GetStartTime()
	{
		if (m_samples.Length == 0) {
			return 0;
		}
		return m_samples[0].m_time;
	}

	double GetEndTime()
	{
		// Subtract the last sample time with the first sample time to get the duration of the trail
		if (m_samples.Length == 0) {
			return 0;
		}
		return m_samples[m_samples.Length - 1].m_time;
	}

	double GetDuration()
	{
		// Subtract the last sample time with the first sample time to get the duration of the trail
		if (m_samples.Length == 0) {
			return 0;
		}
		double firstTime = m_samples[0].m_time;
		double lastTime = m_samples[m_samples.Length - 1].m_time;
		return lastTime - firstTime;
	}
}
