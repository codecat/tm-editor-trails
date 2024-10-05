class Sample : EditorTrails::ISample
{
	double m_time;
	vec3 m_position;
	quat m_dir;
	vec3 m_velocity;
	bool m_didRespawn;

	Sample Interpolate(const Sample &in other, float factor)
	{
		Sample ret;
		ret.m_time = Math::Lerp(m_time, other.m_time, factor);
		ret.m_position = Math::Lerp(m_position, other.m_position, factor);
		ret.m_dir = Math::Slerp(m_dir, other.m_dir, factor);
		ret.m_velocity = Math::Lerp(m_velocity, other.m_velocity, factor);
		return ret;
	}

	void SetRotation(CSmScriptPlayer@ scriptPlayer) {
		vec3 forward = scriptPlayer.AimDirection.Normalized();
		vec3 up = scriptPlayer.UpDirection;
		up -= forward * Math::Dot(up, forward);
		up = up.Normalized();
		vec3 right = Math::Cross(up, forward).Normalized();

		quat q;
		q.w = Math::Sqrt(1.f + right.x + up.y + forward.z) / 2.f;

		if (Math::Abs(q.w) < 1e-5f) {
			q = quat(0.f, 0.f, 0.f, 1.f);
		} else {
			float t = 1.f / (4.f * q.w);
			q.x = (up.z - forward.y) * t;
			q.y = (forward.x - right.z) * t;
			q.z = (right.y - up.x) * t;
		}

		this.m_dir = q.Normalized();
	}

	Json::Value@ ToJson() const
	{
		auto data = Json::Object();
		data['t'] = m_time;
		data['p'] = Json::Array();
		data['p'].Add(m_position.x);
		data['p'].Add(m_position.y);
		data['p'].Add(m_position.z);
		data['q'] = Json::Array();
		data['q'].Add(m_dir.x);
		data['q'].Add(m_dir.y);
		data['q'].Add(m_dir.z);
		data['q'].Add(m_dir.w);
		data['v'] = Json::Array();
		data['v'].Add(m_velocity.x);
		data['v'].Add(m_velocity.y);
		data['v'].Add(m_velocity.z);
		if (m_didRespawn) {
			data['respawn'] = m_didRespawn;
		}
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

	vec3 get_Velocity() const
	{
		return m_velocity;
	}

	quat get_Dir() const
	{
		return m_dir;
	}
}
