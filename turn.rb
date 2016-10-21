$turn = 0
def newturn
  $turn += 1
  Msg.puts "Turn #{$turn} started"
  $buildings.each{|b| b.produce}
  moveitems
  report = "stock\n"
  $castle.resources.each{|h,k| report+="#{h}: #{k}\n"}
  popup(report)

  grow_forest
end
