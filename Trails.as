namespace Trails
{
	array<Trail@> Items;

	Trail@ CreateNew()
	{
		Trail@ newTrail = Trail();
		Items.InsertLast(newTrail);
		return newTrail;
	}

	Trail@ GetCurrent()
	{
		if (Items.Length == 0) {
			return CreateNew();
		}
		return Items[Items.Length - 1];
	}

	void RemoveCurrent()
	{
		if (Items.Length == 0) {
			return;
		}
		Items.RemoveAt(Items.Length - 1);
	}

	void Clear()
	{
		Items.RemoveRange(0, Items.Length);
		ResetEppTrails();
	}
}
