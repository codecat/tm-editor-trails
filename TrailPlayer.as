class TrailPlayer
{
	private Trail@ m_trail;

	double m_currentTime = 0;
	Sample m_interpolatedSample;

	private uint m_currentSampleIndex = 0;

	TrailPlayer(Trail@ trail)
	{
		@m_trail = trail;
	}

	void SetCurrentTime(double time)
	{
		// Should never be allowed to happen
		if (m_trail.m_samples.Length == 0) {
			throw("We have no samples in the trail!");
			return;
		}

		double startTime = m_trail.GetStartTime();
		double endTime = m_trail.GetEndTime();

		if (time <= startTime) {
			// Seek to start
			time = startTime;
			m_currentSampleIndex = 0;
		} else if (time >= endTime) {
			// Seek to end
			time = endTime;
			m_currentSampleIndex = m_trail.m_samples.Length - 1;
		} else if (time < m_currentTime) {
			// Seek backwards
			for (int i = int(m_currentSampleIndex); i >= 0; i--) {
				Sample@ sample = m_trail.m_samples[i];
				if (sample.m_time <= time) {
					m_currentSampleIndex = i;
					if (m_currentSampleIndex >= m_trail.m_samples.Length) {
						m_currentSampleIndex = m_trail.m_samples.Length - 1;
					}
					break;
				}
			}
		} else if (time > m_currentTime) {
			// Seek forwards
			for (uint i = m_currentSampleIndex + 1; i < m_trail.m_samples.Length; i++) {
				Sample@ sample = m_trail.m_samples[i];
				if (sample.m_time > time) {
					m_currentSampleIndex = i - 1;
					break;
				}
			}
		}

		m_currentTime = time;

		auto currentSample = GetCurrentSample();
		auto nextSample = GetNextSample();

		if (currentSample is nextSample) {
			m_interpolatedSample = currentSample;
		} else {
			float factor = Math::InvLerp(currentSample.m_time, nextSample.m_time, time);
			m_interpolatedSample = currentSample.Interpolate(nextSample, factor);
		}
	}

	Sample@ GetCurrentSample()
	{
		return m_trail.m_samples[m_currentSampleIndex];
	}

	Sample@ GetNextSample()
	{
		if (m_currentSampleIndex + 1 >= m_trail.m_samples.Length) {
			return GetCurrentSample();
		}
		return m_trail.m_samples[m_currentSampleIndex + 1];
	}
}
