class Sample
{
	double m_time;
	vec3 m_position;
	quat m_dir;
	vec3 m_velocity;

	Sample Interpolate(const Sample &in other, float factor)
	{
		Sample ret;
		ret.m_time = Math::Lerp(m_time, other.m_time, factor);
		ret.m_position = Math::Lerp(m_position, other.m_position, factor);
		ret.m_dir = Math::Slerp(m_dir, other.m_dir, factor);
		ret.m_velocity = Math::Lerp(m_velocity, other.m_velocity, factor);
		return ret;
	}
}
