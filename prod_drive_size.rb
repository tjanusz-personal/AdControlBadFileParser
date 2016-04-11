require "Win32API"
require "./ProdDriveSize"

## invoke this script to list out the current hard disk sizes for all the ad servers in prod
## You must invoke the prod_drive_connect.rb file first to connect the network resources
sizer = ProdDriveSize.new
ads_results = sizer.get_disk_sizes("P-PR-ADS", 6, 29)
sizer.print_disk_sizes("AD SERVERS", ads_results, 9, 100)

track_results = sizer.get_disk_sizes("P-PR-TRK", 21, 40)
sizer.print_disk_sizes("TRACK", track_results, 8, 60)

click_results = sizer.get_disk_sizes("P-PR-CLK", 11, 14)
sizer.print_disk_sizes("CLICK", click_results, 20, 49)

med_results = sizer.get_disk_sizes("P-PR-MED", 11, 12)
sizer.print_disk_sizes("MED", med_results, 12, 10)

onp_results = sizer.get_disk_sizes("P-PR-ONP", 11, 14)
sizer.print_disk_sizes("ONP", onp_results, 23, 40)

ccb_results = sizer.get_disk_sizes("P-PR-CCB", 11, 12, false)
sizer.print_disk_sizes("CCB", ccb_results, 25, 0)

clt_results = sizer.get_disk_sizes("P-PR-CLT", 11, 18, false)
sizer.print_disk_sizes("CLT", clt_results, 20, 0)

vcon_results = sizer.get_disk_sizes("P-PR-VCON", 11, 12, false)
sizer.print_disk_sizes("VCON", vcon_results, 15, 0)

util_list = ["DS01", "AS01", "MS01", "WEB03", "WEB04"]
util_results = sizer.query_disk_sizes("P-PR-UTL", util_list, true)
sizer.print_disk_sizes("UTIL", util_results, 9, 20)

adp_list = ["BAT11", "DFA11", "WEB21", "WEB22", "WEB23", "WEB24"]
adp_results = sizer.query_disk_sizes("P-PR-ADP", adp_list, false)
sizer.print_disk_sizes("ADP", adp_results, 18, 0)
