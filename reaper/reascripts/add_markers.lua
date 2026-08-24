local track_count = reaper.CountTracks(0)

for i = 0, track_count-1 do
  local track = reaper.GetTrack(0, i)
  _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

  if name:find("Click") then
    local item_count = reaper.CountTrackMediaItems(track)
    for j = 0, item_count-1 do
      local item = reaper.GetTrackMediaItem(track, j)
      local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      reaper.AddProjectMarker(0, true, pos, 0, name, -1)
    end
  end
end
