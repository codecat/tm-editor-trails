class Trail : EditorTrails::ITrail
{
	array<Sample> m_samples;
	array<EditorTrails::ISample@> m_samplesHandles;
	array<EditorTrails::IEvent@> m_events;

	TrailPlayer@ m_player; //TODO: Do we need this here? It's a circular reference!

	vec3 m_lastPosition;
	int m_lastGear = 1;

	Trail()
	{
		m_samples.Reserve(1000);
		m_samplesHandles.Reserve(1000);
		m_events.Reserve(25);

		@m_player = TrailPlayer(this);
	}

#if TMNEXT
	void Update(CSmScriptPlayer@ scriptPlayer)
#else
	void Update(CTrackManiaScriptPlayer@ scriptPlayer)
#endif
	{
		UpdateSample(scriptPlayer);
		UpdateEvents(scriptPlayer);
	}

#if TMNEXT
	void UpdateSample(CSmScriptPlayer@ scriptPlayer)
#else
	void UpdateSample(CTrackManiaScriptPlayer@ scriptPlayer)
#endif
	{
		// There is no reason to save a sample if we're still in the same position as the last time
		if (m_samples.Length > 0) {
			//TODO: We should also check vehicle rotation when we do this
			if ((m_lastPosition - scriptPlayer.Position).LengthSquared() < 0.1) {
				return;
			}
		}

		// Get velocity
#if TMNEXT
		vec3 velocity = scriptPlayer.Velocity;
#else
		// Maniaplanet doesn't have the Velocity property, so we must manually calculate it
		vec3 velocity;
		if (m_samples.Length > 0) {
			velocity = (scriptPlayer.Position - m_lastPosition).Normalized() * scriptPlayer.Speed;
		}
#endif

		// Remember our last position
		m_lastPosition = scriptPlayer.Position;

		// Create a sample and store it in the trail
		Sample newSample;
		newSample.m_time = State::CurrentRaceTime / 1000.0;
		newSample.m_position = scriptPlayer.Position;
		newSample.m_dir = quat(scriptPlayer.AimDirection);
		newSample.m_velocity = velocity;
		m_samples.InsertLast(newSample);
		m_samplesHandles.InsertLast(m_samples[m_samples.Length - 1]);
	}

#if TMNEXT
	void UpdateEvents(CSmScriptPlayer@ scriptPlayer)
#else
	void UpdateEvents(CTrackManiaScriptPlayer@ scriptPlayer)
#endif
	{
		// If our gear changed
		int gear = scriptPlayer.EngineCurGear;
		if (m_lastGear != gear) {
			// Create a gear change event
			auto newGearChangeEvent = Events::GearChange();
			newGearChangeEvent.m_time = State::CurrentRaceTime / 1000.0;
			newGearChangeEvent.m_position = scriptPlayer.Position;
			newGearChangeEvent.m_prev = m_lastGear;
			newGearChangeEvent.m_new = gear;
			m_events.InsertLast(newGearChangeEvent);

			// Remember our last gear
			m_lastGear = scriptPlayer.EngineCurGear;
		}
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

	double GetDuration() const
	{
		// Subtract the last sample time with the first sample time to get the duration of the trail
		if (m_samples.Length == 0) {
			return 0;
		}
		double firstTime = m_samples[0].m_time;
		double lastTime = m_samples[m_samples.Length - 1].m_time;
		return lastTime - firstTime;
	}

	string ToJsonString() const
	{
		auto data = Json::Object();
		data['samples'] = Json::Array();
		data['events'] = Json::Array();
		data['samples'].Add("__TAG__");
		for (uint i = 0; i < m_events.Length; i++) {
			data['events'].Add(m_events[i].ToJson());
		}
		// without a method like the below, we can easily take 10+ seconds to serialize a very large json document.
		auto dataStr = Json::Write(data);
		string samplesStr = "";
		auto lastPause = Time::Now;
		for (uint i = 0; i < m_samples.Length; i++) {
			samplesStr += (i > 0 ? ", " : "") + Json::Write(m_samples[i].ToJson());
			if (Time::Now - lastPause > 5) {
				yield();
				lastPause = Time::Now;
			}
		}
		auto parts = dataStr.Split('"__TAG__"');
		parts.InsertAt(1, samplesStr);
		return string::Join(parts, samplesStr);
	}

	double get_Duration() const
	{
		return GetDuration();
	}

	const array<EditorTrails::ISample@>@ get_Samples() const
	{
		return m_samplesHandles;
	}

	const array<EditorTrails::IEvent@>@ get_Events() const
	{
		return m_events;
	}
}
