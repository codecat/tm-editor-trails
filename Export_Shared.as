namespace EditorTrails {
    interface ITrail {
        const array<Sample>@ GetSamples() const;
        const array<Sample>@ GetEvents() const;
    }
}
