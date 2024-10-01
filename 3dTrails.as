namespace EppState {
    int lastTrailsCount = 0;
    int[] lastTrailSampleCounts;
    bool trailsChanged = false;
    bool resetDrawInstance = true;

    void BeforeDraw()
    {
        if (!ShouldUseEditorPlusPlus()) return;
        trailsChanged = false;
        if (lastTrailsCount != Trails::Items.Length) {
            lastTrailsCount = Trails::Items.Length;
            trailsChanged = true;
        }
        lastTrailSampleCounts.Resize(lastTrailsCount);
        for (int i = 0; i < lastTrailsCount; i++) {
            auto count = Trails::Items[i].m_samples.Length;
            if (lastTrailSampleCounts[i] != count) {
                lastTrailSampleCounts[i] = count;
                trailsChanged = true;
            }
        }
        resetDrawInstance = trailsChanged;
    }
}


#if DEPENDENCY_EDITOR

void ResetEppTrails()
{
    auto di = Editor::DrawLinesAndQuads::GetOrCreateDrawInstance("editor-trails");
    di.Reset();
}

bool ShouldUseEditorPlusPlus()
{
    auto epp = Meta::GetPluginFromID("Editor");
    if (epp is null) {
        return false;
    }
    return epp.Enabled;
}

void RenderTrailLineEpp(Trail@ trail)
{
    auto di = Editor::DrawLinesAndQuads::GetOrCreateDrawInstance("editor-trails");
    di.Draw();
    if (!EppState::trailsChanged) return;
    if (EppState::resetDrawInstance) {
        di.Reset();
        EppState::resetDrawInstance = false;
    }
    vec3[] path;
    for (uint j = 0; j < trail.m_samples.Length; j++) {
        path.InsertLast(trail.m_samples[j].m_position + vec3(0, 64.25, 0));
    }
    di.PushLineSegmentsFromPath(path);
    di.RequestLineColor(Setting_TrailColor.xyz);
}


#else


void ResetEppTrails()
{
}

bool ShouldUseEditorPlusPlus()
{
    return false;
}

void RenderTrailLineEpp(Trail@ trail)
{
    throw("Should never be called");
}


#endif
