namespace Upload {
	void OnReenteredEditorAsync()
	{
		if (!Setting_EnableUploadTrails) return;
		trace('Serializing trails for upload');
		array<Trail@>@ trails = Trails::Items;
		auto postdata = GenerateUploadJson(trails);
		trace('Generated postdata for upload; length: ' + postdata.Length);
		RunUpload(postdata);
	}

	string GenerateUploadJson(Trail@[]@ trails)
	{
		string data = '[';
		uint lastYield = Time::Now;
		for (uint i = 0; i < trails.Length; i++) {
			data += (i > 0 ? ", " : "") + trails[i].ToJsonString();
			// avoid doing more than 5ms of processing at one time
			if (Time::Now - lastYield > 5) {
				yield();
				lastYield = Time::Now;
			}
		}
		return data + ']';
	}

	void RunUpload(const string &in data)
	{
		trace("Uploading editor trails to " + Setting_UploadTrailsURL);
		auto request = Net::HttpPost(Setting_UploadTrailsURL, data, "application/json");
		while (!request.Finished()) yield();
		auto status = request.ResponseCode();
		if (200 <= status && status < 300) {
			trace("Uploading editor trails succeeded.");
			return;
		}
		string msg = "Uploading editor trails to URL failed! Status code: " + status + ". Response body: `" + request.String() + "`.";
		warn(msg);
		UI::ShowNotification(Meta::ExecutingPlugin().Name, msg, vec4(.7, .2, .2, .7));
	}
}
