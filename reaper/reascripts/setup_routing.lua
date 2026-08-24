function create_bus(name)
  reaper.InsertTrackInProject(-1, true)
  local track = reaper.GetTrack(0, reaper.CountTracks(0)-1)
  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
  return track
end

iem_bus = create_bus("IEM Bus")
cue_bus = create_bus("Cue Bus")
foh_bus = create_bus("FOH Bus")

local track_count = reaper.CountTracks(0)
for i = 0, track_count-1 do
  local track = reaper.GetTrack(0, i)
  _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

  if name:find("Click") then
    reaper.CreateTrackSend(track, iem_bus)
  elseif name:find("Cue") then
    reaper.CreateTrackSend(track, cue_bus)
  else
    reaper.CreateTrackSend(track, foh_bus)
  end
end
