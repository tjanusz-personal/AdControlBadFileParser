AdControlBadFileParser
==================

The AdControlBadFileParser project is a bunch of ruby classes, specs, cucumber features utilized to help in my daily support of the 80+ production servers and all their crazy errors, logs, etc. Most of these servers are old Win 2003/2008 servers that don't have ruby on them so these scripts all run locally on a Windows laptop.

There are three categories of scripts:

1. **ProdServer Monitoring** - Figure out if something is wrong with server/application 
	* **prod_drive_connect** - creates all local connections to prod servers
	* **prod_drive_disconnect** - disconnects all existing connections (use this when passwords change) 
	* **prod_drive_size** - lists,verifies all server disk usages and compares to desired size

2. **Ad Server Error Processing** - resolve ad control errors 
	* **AdControlBadFileParser** - parses a directory full of 'bad' ad control records and collates to help determine patterns of root cause

3. **Historical Report Generation Utils**  - help historical reporting errors/scaling
	* **HistoricalReportFileUtils** - reads report logs to determine total time sizes to help estimate total report running time
	* **HistoricalReportErrorLogParser** - parses a directory of historical report logs looking for errors and collating results

## Getting Started

* Get all source from this git repo
* Connect to DC3 production environment
* Copy error logs to local machine/directory for processing

### Dependencies

* ruby installed (1.9.2 or greater) *(Need windows version since these all connect and read from legacy windows servers)*
* Connection to DC3 Production environment

### Configuring the Project

* **cucumber.yml** - create local file with these profiles:
	* **default**: `--format pretty USER="UNK" PASSWORD="UNK"`
	* **prod**: `--format pretty USER=domain\myUser PASSWORD=MyPass`
	* **prodconnect**: `features/connectionsWork.feature --format pretty USER=domain\myUser PASSWORD=MyPass`


* **bundler** - `bundle install` to get all gem dependencies

### Running the Project
There are numerous scripts/classes this lists out the command line invocation examples

* `ruby prod_drive_connect.rb "domain\username" "password"`
* `ruby prod_drive_disconnect.rb`
* `ruby prod_drive_size.rb`
* `ruby AdControlBadFileParser.rb "C://temp//FolderWithBadAdControlLogs" "C://temp//SpreadsheetName.csv"`
* `ruby HistoricalReportFileUtils.rb "C://temp//HistoricalLogDir"`
* `ruby HistoricalReportErrorLogUtils.rb "C://temp//HistoricalReportErrors"`

## Testing

- Rspec tests 
	- HistoricalReport scripts, AdControlReader
	- `rspec . --format documentation`

- Cucumber Features
	- Define the ideal existing drive usage sizes for each of the various servers in production
	- `cucumber --profile prod`

## Deployment

N/A

## Getting Help

### Documentation

* None
