namespace EditorTrails
{
    interface ITrail
    {
        // Note: ITrail::get_Samples must return an array of handles, otherwise we get:
        // > ERR : The subtype has no default factory

        // The vehicle samples in the trail.
        const array<ISample@>@ get_Samples() const;
        const array<IEvent@>@ get_Events() const;
	    double get_Duration() const;
        string ToJsonString() const;
    }

    interface ISample
    {
        Json::Value@ ToJson() const;
        double get_Time() const;
        vec3 get_Position() const;
        vec3 get_Velocity() const;
        quat get_Dir() const;
    }

    interface IEvent
    {
        Json::Value@ ToJson() const;
        double get_Time() const;
        vec3 get_Position() const;
        string Text() const;
        void Render();
    }
}
